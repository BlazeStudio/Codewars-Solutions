#!/usr/bin/env bash
set -euo pipefail

SOURCES=()
EXCLUDES=()
DEST=""
LABEL="backup"
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6
LEVEL=6
DRY_RUN=0
VERIFY=0
SKIP_BACKUP=0
LOG_FILE=""

die() {
  log ERROR "$*"
  exit 1
}

log() {
  local level="$1"
  shift
  local line
  line="$(date '+%Y-%m-%d %H:%M:%S') [$level] $*"
  printf '%s\n' "$line" >&2
  if [[ -n "$LOG_FILE" ]]; then
    printf '%s\n' "$line" >> "$LOG_FILE"
  fi
}

run() {
  if ((DRY_RUN)); then
    log DRY "$*"
  else
    "$@"
  fi
}

while (($#)); do
  case "$1" in
    -s|--source) SOURCES+=("${2:?}"); shift 2 ;;
    -x|--exclude) EXCLUDES+=("${2:?}"); shift 2 ;;
    -d|--dest) DEST="${2:?}"; shift 2 ;;
    -l|--label) LABEL="${2:?}"; shift 2 ;;
    --daily) KEEP_DAILY="${2:?}"; shift 2 ;;
    --weekly) KEEP_WEEKLY="${2:?}"; shift 2 ;;
    --monthly) KEEP_MONTHLY="${2:?}"; shift 2 ;;
    --level) LEVEL="${2:?}"; shift 2 ;;
    --log) LOG_FILE="${2:?}"; shift 2 ;;
    -n|--dry-run) DRY_RUN=1; shift ;;
    --verify) VERIFY=1; shift ;;
    --rotate-only) SKIP_BACKUP=1; shift ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ -n "$DEST" ]] || die "--dest is required"
[[ "$LABEL" =~ ^[A-Za-z0-9._-]+$ ]] || die "--label may contain only letters, digits, dot, dash and underscore"
for n in "$KEEP_DAILY" "$KEEP_WEEKLY" "$KEEP_MONTHLY"; do
  [[ "$n" =~ ^[0-9]+$ ]] || die "keep counts must be non-negative integers"
done
[[ "$LEVEL" =~ ^[1-9]$ ]] || die "--level must be 1..9"
((SKIP_BACKUP)) || ((${#SOURCES[@]})) || die "at least one --source is required"
for src in "${SOURCES[@]}"; do
  [[ -e "$src" ]] || die "source does not exist: $src"
done
command -v tar >/dev/null || die "tar not found"
command -v gzip >/dev/null || die "gzip not found"

if command -v sha256sum >/dev/null; then
  SHA=(sha256sum)
elif command -v shasum >/dev/null; then
  SHA=(shasum -a 256)
else
  die "sha256sum or shasum is required"
fi

mkdir -p -- "$DEST"
DEST="$(cd -- "$DEST" && pwd)"
LOCK="$DEST/.$LABEL.lock"

if ! mkdir -- "$LOCK" 2>/dev/null; then
  if [[ -f "$LOCK/pid" ]] && ! kill -0 "$(cat "$LOCK/pid")" 2>/dev/null; then
    log WARN "removing stale lock $LOCK"
    rm -rf -- "$LOCK"
    mkdir -- "$LOCK"
  else
    die "another backup with label '$LABEL' is running ($LOCK)"
  fi
fi
echo $$ > "$LOCK/pid"

TMP=""
cleanup() {
  local code=$?
  [[ -n "$TMP" && -e "$TMP" ]] && rm -f -- "$TMP"
  rm -rf -- "$LOCK"
  exit "$code"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

human_size() {
  awk -v b="$1" 'BEGIN {
    split("B KB MB GB TB", u, " ")
    i = 1
    while (b >= 1024 && i < 5) { b /= 1024; i++ }
    printf (i == 1 ? "%d %s" : "%.1f %s"), b, u[i]
  }'
}

file_size() {
  wc -c < "$1" | tr -d ' '
}

checksum_file() {
  (cd -- "$(dirname -- "$1")" && "${SHA[@]}" -- "$(basename -- "$1")")
}

verify_archive() {
  local archive="$1"
  if [[ -f "$archive.sha256" ]]; then
    (cd -- "$(dirname -- "$archive")" && "${SHA[@]}" -c --status -- "$(basename -- "$archive").sha256") \
      || { log ERROR "checksum mismatch: $archive"; return 1; }
  else
    log WARN "no checksum file for $archive"
  fi
  gzip -t -- "$archive" || { log ERROR "gzip stream is broken: $archive"; return 1; }
  tar -tzf "$archive" > /dev/null || { log ERROR "tar listing failed: $archive"; return 1; }
}

create_backup() {
  local stamp archive tar_args=() src parent name pattern started finished size entries
  stamp="$(date '+%Y%m%d-%H%M%S')"
  archive="$DEST/${LABEL}_${stamp}.tar.gz"
  [[ -e "$archive" ]] && die "archive already exists: $archive"

  for pattern in "${EXCLUDES[@]}"; do
    tar_args+=("--exclude=$pattern")
  done
  for src in "${SOURCES[@]}"; do
    src="$(cd -- "$(dirname -- "$src")" && pwd)/$(basename -- "$src")"
    parent="$(dirname -- "$src")"
    name="$(basename -- "$src")"
    tar_args+=(-C "$parent" "$name")
  done

  log INFO "creating $archive from ${#SOURCES[@]} source(s)"
  if ((DRY_RUN)); then
    log DRY "tar -cf - ${tar_args[*]} | gzip -$LEVEL > $archive"
    return 0
  fi

  started=$(date +%s)
  TMP="$archive.partial"
  tar -cf - "${tar_args[@]}" | gzip "-$LEVEL" > "$TMP"
  mv -- "$TMP" "$archive"
  TMP=""
  checksum_file "$archive" > "$archive.sha256"
  finished=$(date +%s)

  size="$(file_size "$archive")"
  entries="$(tar -tzf "$archive" | wc -l | tr -d ' ')"
  log INFO "done in $((finished - started))s: $(human_size "$size"), $entries entries"

  if ((VERIFY)); then
    verify_archive "$archive" && log INFO "verified $archive"
  fi
}

archive_date() {
  local base="${1##*/}"
  base="${base#"${LABEL}"_}"
  base="${base%.tar.gz}"
  [[ "$base" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{6})$ ]] || return 1
  printf '%s-%s-%s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
}

iso_week() {
  date -d "$1" '+%G-W%V' 2>/dev/null || date -j -f '%Y-%m-%d' "$1" '+%G-W%V'
}

rotate() {
  local archives=() archive day week month keep reason
  local -A seen_day=() seen_week=() seen_month=() keep_reason=()
  local days=0 weeks=0 months=0 removed=0 freed=0 kept=0

  while IFS= read -r archive; do
    archives+=("$archive")
  done < <(find "$DEST" -maxdepth 1 -type f -name "${LABEL}_*.tar.gz" | sort -r)

  if ((${#archives[@]} == 0)); then
    log INFO "nothing to rotate"
    return 0
  fi

  for archive in "${archives[@]}"; do
    day="$(archive_date "$archive")" || { log WARN "skipping unrecognized file $archive"; keep_reason[$archive]="unknown"; continue; }
    week="$(iso_week "$day")"
    month="${day%-*}"
    reason=""

    if ((days < KEEP_DAILY)) && [[ -z "${seen_day[$day]:-}" ]]; then
      seen_day[$day]=1
      days=$((days + 1))
      reason="daily"
    fi
    if ((weeks < KEEP_WEEKLY)) && [[ -z "${seen_week[$week]:-}" ]]; then
      seen_week[$week]=1
      weeks=$((weeks + 1))
      reason="${reason:+$reason,}weekly"
    fi
    if ((months < KEEP_MONTHLY)) && [[ -z "${seen_month[$month]:-}" ]]; then
      seen_month[$month]=1
      months=$((months + 1))
      reason="${reason:+$reason,}monthly"
    fi
    keep_reason[$archive]="$reason"
  done

  for archive in "${archives[@]}"; do
    reason="${keep_reason[$archive]:-}"
    if [[ -n "$reason" ]]; then
      kept=$((kept + 1))
      log INFO "keep   ${archive##*/} ($reason)"
      continue
    fi
    freed=$((freed + $(file_size "$archive")))
    removed=$((removed + 1))
    log INFO "remove ${archive##*/}"
    run rm -f -- "$archive" "$archive.sha256"
  done

  log INFO "rotation: kept $kept, removed $removed, freed $(human_size "$freed")"
}

report_usage() {
  local total=0 count=0 archive
  while IFS= read -r archive; do
    total=$((total + $(file_size "$archive")))
    count=$((count + 1))
  done < <(find "$DEST" -maxdepth 1 -type f -name "${LABEL}_*.tar.gz")
  log INFO "$count archive(s) in $DEST, $(human_size "$total") total"
  if command -v df >/dev/null; then
    log INFO "free space: $(df -Pk "$DEST" | awk 'NR == 2 { printf "%.1f GB", $4 / 1048576 }')"
  fi
}

log INFO "label=$LABEL dest=$DEST daily=$KEEP_DAILY weekly=$KEEP_WEEKLY monthly=$KEEP_MONTHLY dry_run=$DRY_RUN"
((SKIP_BACKUP)) || create_backup
rotate
report_usage
