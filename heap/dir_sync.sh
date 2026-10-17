#!/usr/bin/env bash
set -euo pipefail

SRC=""
DST=""
APPLY=0
DELETE=0
QUICK=0
VERBOSE=0
BACKUP_DIR=""
REPORT=""
EXCLUDES=()

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

say() {
  printf '%s\n' "$*" >&2
}

while (($#)); do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --delete) DELETE=1; shift ;;
    --quick) QUICK=1; shift ;;
    -v|--verbose) VERBOSE=1; shift ;;
    -x|--exclude) EXCLUDES+=("${2:?}"); shift 2 ;;
    --backup-dir) BACKUP_DIR="${2:?}"; shift 2 ;;
    --report) REPORT="${2:?}"; shift 2 ;;
    -*) die "unknown option: $1" ;;
    *)
      if [[ -z "$SRC" ]]; then SRC="$1"
      elif [[ -z "$DST" ]]; then DST="$1"
      else die "unexpected argument: $1"
      fi
      shift ;;
  esac
done

[[ -n "$SRC" && -n "$DST" ]] || die "source and destination directories are required"
[[ -d "$SRC" ]] || die "not a directory: $SRC"
((DELETE)) && ((!APPLY)) && die "--delete requires --apply"
SRC="$(cd -- "$SRC" && pwd)"
if [[ -d "$DST" ]]; then
  DST="$(cd -- "$DST" && pwd)"
elif ((APPLY)); then
  mkdir -p -- "$DST"
  DST="$(cd -- "$DST" && pwd)"
else
  die "not a directory: $DST"
fi
[[ "$SRC" != "$DST" ]] || die "source and destination are the same"
case "$DST/" in "$SRC/"*) die "destination is inside source" ;; esac
case "$SRC/" in "$DST/"*) die "source is inside destination" ;; esac

if command -v sha256sum >/dev/null; then
  HASH=(sha256sum)
elif command -v shasum >/dev/null; then
  HASH=(shasum -a 256)
else
  die "sha256sum or shasum is required"
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

is_excluded() {
  local path="$1" pattern
  for pattern in "${EXCLUDES[@]}"; do
    if [[ "$path" == $pattern || "$path" == */$pattern || "$path" == $pattern/* || "$path" == */$pattern/* ]]; then
      return 0
    fi
  done
  return 1
}

file_stat() {
  if stat -c '%s %Y' -- "$1" 2>/dev/null; then
    return
  fi
  stat -f '%z %m' -- "$1"
}

manifest() {
  local root="$1" out="$2" rel size mtime hash count=0
  : > "$out"
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    if ((${#EXCLUDES[@]})) && is_excluded "$rel"; then
      continue
    fi
    read -r size mtime < <(file_stat "$root/$rel")
    if ((QUICK)); then
      hash="$size:$mtime"
    else
      hash="$("${HASH[@]}" < "$root/$rel" | awk '{ print $1 }')"
    fi
    printf '%s\t%s\t%s\t%s\n' "$rel" "$size" "$mtime" "$hash" >> "$out"
    count=$((count + 1))
    if ((count % 200 == 0)); then
      say "  ${root##*/}: $count files scanned"
    fi
  done < <(cd -- "$root" && find . -type f -print0)
  LC_ALL=C sort -t$'\t' -k1,1 -o "$out" "$out"
}

human_bytes() {
  awk -v b="$1" 'BEGIN {
    split("B KB MB GB TB", u, " ")
    i = 1
    while (b >= 1024 && i < 5) { b /= 1024; i++ }
    printf (i == 1 ? "%d %s" : "%.1f %s"), b, u[i]
  }'
}

say "scanning $SRC"
manifest "$SRC" "$WORK/src"
say "scanning $DST"
manifest "$DST" "$WORK/dst"

LC_ALL=C join -t$'\t' -a1 -a2 -e '-' -o '0,1.2,1.3,1.4,2.2,2.3,2.4' "$WORK/src" "$WORK/dst" | awk -F'\t' -v work="$WORK" '
  $4 == "-" { print $1 "\t" $5 > work "/only_dst"; next }
  $7 == "-" { print $1 "\t" $2 > work "/only_src"; next }
  $4 != $7 {
    state = ($3 > $6) ? "newer" : (($3 < $6) ? "older" : "same-time")
    print $1 "\t" $2 "\t" $5 "\t" state > work "/changed"
    next
  }
  { print $1 "\t" $2 > work "/same" }
'
for f in only_src only_dst changed same; do
  touch "$WORK/$f"
done

count_of() {
  wc -l < "$WORK/$1" | tr -d ' '
}

bytes_of() {
  awk -F'\t' -v col="$2" '{ s += $col } END { print s + 0 }' "$WORK/$1"
}

N_NEW=$(count_of only_src)
N_EXTRA=$(count_of only_dst)
N_CHANGED=$(count_of changed)
N_SAME=$(count_of same)

summary() {
  printf 'source:       %s\n' "$SRC"
  printf 'destination:  %s\n' "$DST"
  printf 'compare by:   %s\n' "$( ((QUICK)) && echo 'size + mtime' || echo 'sha256')"
  printf '\n'
  printf '%-22s %8s %12s\n' "category" "files" "size"
  printf '%-22s %8s %12s\n' "identical" "$N_SAME" "$(human_bytes "$(bytes_of same 2)")"
  printf '%-22s %8s %12s\n' "missing in destination" "$N_NEW" "$(human_bytes "$(bytes_of only_src 2)")"
  printf '%-22s %8s %12s\n' "changed" "$N_CHANGED" "$(human_bytes "$(bytes_of changed 2)")"
  printf '%-22s %8s %12s\n' "only in destination" "$N_EXTRA" "$(human_bytes "$(bytes_of only_dst 2)")"
}

details() {
  local limit="$1"
  if ((N_NEW)); then
    printf '\nmissing in destination:\n'
    head -n "$limit" "$WORK/only_src" | awk -F'\t' '{ printf "  + %s\n", $1 }'
    ((N_NEW > limit)) && printf '  ... and %d more\n' $((N_NEW - limit))
  fi
  if ((N_CHANGED)); then
    printf '\nchanged:\n'
    head -n "$limit" "$WORK/changed" | awk -F'\t' '{ printf "  ~ %s (%s -> %s bytes, source is %s)\n", $1, $3, $2, $4 }'
    ((N_CHANGED > limit)) && printf '  ... and %d more\n' $((N_CHANGED - limit))
  fi
  if ((N_EXTRA)); then
    printf '\nonly in destination:\n'
    head -n "$limit" "$WORK/only_dst" | awk -F'\t' '{ printf "  - %s\n", $1 }'
    ((N_EXTRA > limit)) && printf '  ... and %d more\n' $((N_EXTRA - limit))
  fi
  return 0
}

LIMIT=20
((VERBOSE)) && LIMIT=1000000
summary
details "$LIMIT"

if [[ -n "$REPORT" ]]; then
  mkdir -p -- "$(dirname -- "$REPORT")"
  { summary; details 1000000; } > "$REPORT"
  say "report written to $REPORT"
fi

if ((!APPLY)); then
  if ((N_NEW + N_CHANGED + (DELETE ? N_EXTRA : 0))); then
    say ""
    say "dry run: nothing changed, use --apply to synchronize"
  fi
  exit 0
fi

STAMP="$(date '+%Y%m%d-%H%M%S')"
[[ -n "$BACKUP_DIR" ]] && BACKUP_DIR="$BACKUP_DIR/$STAMP"

backup() {
  local rel="$1"
  [[ -n "$BACKUP_DIR" && -f "$DST/$rel" ]] || return 0
  mkdir -p -- "$BACKUP_DIR/$(dirname -- "$rel")"
  cp -p -- "$DST/$rel" "$BACKUP_DIR/$rel"
}

copy_file() {
  local rel="$1" tmp
  mkdir -p -- "$DST/$(dirname -- "$rel")"
  tmp="$DST/$rel.sync-tmp.$$"
  cp -p -- "$SRC/$rel" "$tmp"
  mv -f -- "$tmp" "$DST/$rel"
}

COPIED=0
UPDATED=0
REMOVED=0
FAILED=0

while IFS=$'\t' read -r rel _; do
  if copy_file "$rel"; then
    COPIED=$((COPIED + 1))
    ((VERBOSE)) && say "copied  $rel"
  else
    FAILED=$((FAILED + 1))
    say "failed  $rel"
  fi
done < "$WORK/only_src"

while IFS=$'\t' read -r rel _; do
  if backup "$rel" && copy_file "$rel"; then
    UPDATED=$((UPDATED + 1))
    ((VERBOSE)) && say "updated $rel"
  else
    FAILED=$((FAILED + 1))
    say "failed  $rel"
  fi
done < "$WORK/changed"

if ((DELETE)); then
  while IFS=$'\t' read -r rel _; do
    if backup "$rel" && rm -f -- "$DST/$rel"; then
      REMOVED=$((REMOVED + 1))
      ((VERBOSE)) && say "removed $rel"
    else
      FAILED=$((FAILED + 1))
      say "failed  $rel"
    fi
  done < "$WORK/only_dst"
  find "$DST" -mindepth 1 -type d -empty -delete 2>/dev/null || true
fi

say ""
say "copied $COPIED, updated $UPDATED, removed $REMOVED, failed $FAILED"
[[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]] && say "previous versions saved to $BACKUP_DIR"
((FAILED == 0))
