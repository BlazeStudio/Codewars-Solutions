#!/usr/bin/env bash
set -euo pipefail

REPO="."
SINCE=""
UNTIL=""
TOP=10
OUTPUT=""
BRANCH="HEAD"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    -r|--repo) REPO="${2:?}"; shift 2 ;;
    -b|--branch) BRANCH="${2:?}"; shift 2 ;;
    --since) SINCE="${2:?}"; shift 2 ;;
    --until) UNTIL="${2:?}"; shift 2 ;;
    -n|--top) TOP="${2:?}"; shift 2 ;;
    -o|--output) OUTPUT="${2:?}"; shift 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done

command -v git >/dev/null || die "git is not installed"
[[ "$TOP" =~ ^[1-9][0-9]*$ ]] || die "--top must be a positive number"
git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "$REPO is not a git repository"
git -C "$REPO" rev-parse --verify --quiet "$BRANCH^{commit}" >/dev/null || die "unknown revision: $BRANCH"

ROOT="$(git -C "$REPO" rev-parse --show-toplevel)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

RANGE_ARGS=("$BRANCH")
[[ -n "$SINCE" ]] && RANGE_ARGS+=("--since=$SINCE")
[[ -n "$UNTIL" ]] && RANGE_ARGS+=("--until=$UNTIL")

g() {
  git -C "$ROOT" -c core.quotepath=off "$@"
}

g log "${RANGE_ARGS[@]}" --no-merges --date=format:'%Y-%m-%d %u %H' \
  --pretty=format:'@@%x09%H%x09%an%x09%ae%x09%ad' --numstat > "$WORK/log"

awk -F'\t' -v work="$WORK" '
  /^@@/ {
    commits++
    author = $3
    split($5, d, " ")
    day = d[1]; weekday = d[2]; hour = d[3]
    month = substr(day, 1, 7)
    by_author[author]++
    by_weekday[weekday]++
    by_hour[hour]++
    by_month[month]++
    if (first == "" || day < first) first = day
    if (last == "" || day > last) last = day
    if (!(author in first_seen) || day < first_seen[author]) first_seen[author] = day
    if (!(author in last_seen) || day > last_seen[author]) last_seen[author] = day
    next
  }
  NF == 3 {
    added = ($1 == "-") ? 0 : $1
    removed = ($2 == "-") ? 0 : $2
    file = $3
    if (file ~ / => /) {
      gsub(/\{[^}]* => /, "", file)
      gsub(/\}/, "", file)
      sub(/^.* => /, "", file)
    }
    total_added += added
    total_removed += removed
    author_added[author] += added
    author_removed[author] += removed
    churn[file] += added + removed
    touches[file]++
    if ($1 == "-") binary[file] = 1
  }
  END {
    printf "%d\t%d\t%d\t%s\t%s\n", commits, total_added, total_removed, first, last > work "/summary"
    for (a in by_author) printf "%d\t%s\t%d\t%d\t%s\t%s\n", by_author[a], a, author_added[a], author_removed[a], first_seen[a], last_seen[a] > work "/authors"
    for (w in by_weekday) printf "%s\t%d\n", w, by_weekday[w] > work "/weekdays"
    for (h in by_hour) printf "%s\t%d\n", h, by_hour[h] > work "/hours"
    for (m in by_month) printf "%s\t%d\n", m, by_month[m] > work "/months"
    for (f in churn) printf "%d\t%s\t%d\t%s\n", churn[f], f, touches[f], (f in binary) ? "binary" : "" > work "/churn"
  }
' "$WORK/log"

for f in authors weekdays hours months churn; do
  touch "$WORK/$f"
done

g ls-tree -r -l --full-tree -z "$BRANCH" | tr '\0' '\n' | awk -F'\t' '
  { split($1, m, " "); if (m[2] == "blob") printf "%s\t%s\n", $2, m[4] }
' > "$WORK/sizes"

strip_rev() {
  awk -v prefix="$BRANCH:" '
    index($0, prefix) == 1 {
      line = substr($0, length(prefix) + 1)
      n = match(line, /:[0-9]+$/)
      if (n) printf "%s\t%s\n", substr(line, 1, n - 1), substr(line, n + 1)
    }
  '
}

{ g grep -I -c -e '' "$BRANCH" -- || true; } | strip_rev > "$WORK/linecounts"
{ g grep -I -c -E '[^[:space:]]' "$BRANCH" -- || true; } | strip_rev > "$WORK/nonblankcounts"

awk -F'\t' '
  FILENAME == ARGV[1] { lines[$1] = $2; next }
  FILENAME == ARGV[2] { nonblank[$1] = $2; next }
  {
    file = $1
    base = file
    sub(/^.*\//, "", base)
    ext = (index(base, ".") ? base : "(none)")
    if (ext != "(none)") sub(/^.*\./, "", ext)
    printf "%s\t%d\t%d\t%d\t%s\n", ext, lines[file], lines[file] - nonblank[file], $2, file
  }
' "$WORK/linecounts" "$WORK/nonblankcounts" "$WORK/sizes" > "$WORK/files"

awk -F'\t' '
  { files[$1]++; lines[$1] += $2; blank[$1] += $3; bytes[$1] += $4 }
  END { for (e in files) printf "%d\t%s\t%d\t%d\t%d\n", lines[e], e, files[e], blank[e], bytes[e] }
' "$WORK/files" > "$WORK/extensions"

{ g grep -n -I -E '\b(TODO|FIXME|HACK|XXX)\b' "$BRANCH" -- 2>/dev/null || true; } \
  | awk -v prefix="$BRANCH:" 'index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }' > "$WORK/todos"

IFS=$'\t' read -r COMMITS ADDED REMOVED FIRST LAST < "$WORK/summary"
COMMITS="${COMMITS:-0}"

human_bytes() {
  awk -v b="$1" 'BEGIN {
    split("B KB MB GB TB", u, " ")
    i = 1
    while (b >= 1024 && i < 5) { b /= 1024; i++ }
    printf (i == 1 ? "%d %s" : "%.1f %s"), b, u[i]
  }'
}

md_table() {
  awk -F'\t' -v header="$1" '
    BEGIN {
      n = split(header, h, "|")
      line = "|"; sep = "|"
      for (i = 1; i <= n; i++) { line = line " " h[i] " |"; sep = sep (h[i] ~ /^[#0-9]|Commits|Lines|Files|Added|Removed|Churn|Size|Count|Share|Blank|Touches/ ? "---:|" : "---|") }
      print line; print sep
    }
    { gsub(/\|/, "\\|"); row = "|"; for (i = 1; i <= NF; i++) row = row " " $i " |"; print row }
  '
}

bars() {
  awk -F'\t' '
    { k[NR] = $1; v[NR] = $2; if ($2 > max) max = $2 }
    END {
      print "```"
      for (i = 1; i <= NR; i++) {
        len = max ? int(v[i] * 40 / max + 0.5) : 0
        bar = ""
        for (j = 0; j < len; j++) bar = bar "█"
        printf "%-9s %6d %s\n", k[i], v[i], bar
      }
      print "```"
    }
  '
}

report() {
  local name branch_name head tags branches contributors tracked total_lines total_bytes
  name="$(basename -- "$ROOT")"
  branch_name="$(g rev-parse --abbrev-ref "$BRANCH")"
  head="$(g log -1 --format='%h %s (%ar)' "$BRANCH")"
  tags="$(g tag | wc -l | tr -d ' ')"
  branches="$(g branch -a | wc -l | tr -d ' ')"
  contributors="$(wc -l < "$WORK/authors" | tr -d ' ')"
  tracked="$(wc -l < "$WORK/files" | tr -d ' ')"
  total_lines="$(awk -F'\t' '{ s += $2 } END { print s + 0 }' "$WORK/files")"
  total_bytes="$(awk -F'\t' '{ s += $4 } END { print s + 0 }' "$WORK/files")"

  printf '# Repository report: %s\n\n' "$name"
  printf '_Generated %s for `%s`' "$(date '+%Y-%m-%d %H:%M')" "$branch_name"
  [[ -n "$SINCE" ]] && printf ', since %s' "$SINCE"
  [[ -n "$UNTIL" ]] && printf ', until %s' "$UNTIL"
  printf '_\n\n'

  printf '## Summary\n\n'
  {
    printf 'Head\t%s\n' "$head"
    printf 'Commits (no merges)\t%s\n' "$COMMITS"
    printf 'Contributors\t%s\n' "$contributors"
    printf 'First / last commit\t%s / %s\n' "${FIRST:--}" "${LAST:--}"
    printf 'Lines added / removed\t+%s / -%s\n' "${ADDED:-0}" "${REMOVED:-0}"
    printf 'Tracked files\t%s\n' "$tracked"
    printf 'Lines in tracked files\t%s\n' "$total_lines"
    printf 'Size of tracked files\t%s\n' "$(human_bytes "$total_bytes")"
    printf 'Branches / tags\t%s / %s\n' "$branches" "$tags"
    printf 'TODO / FIXME markers\t%s\n' "$(wc -l < "$WORK/todos" | tr -d ' ')"
  } | md_table "Metric|Value"

  printf '\n## Contributors\n\n'
  sort -t$'\t' -k1,1nr "$WORK/authors" | head -n "$TOP" | awk -F'\t' -v total="$COMMITS" '
    { printf "%s\t%d\t%.1f%%\t+%d\t-%d\t%s\t%s\n", $2, $1, total ? $1 * 100 / total : 0, $3, $4, $5, $6 }
  ' | md_table "Author|Commits|Share|Added|Removed|First|Last"

  printf '\n## Languages by extension\n\n'
  sort -t$'\t' -k1,1nr "$WORK/extensions" | head -n "$TOP" | while IFS=$'\t' read -r lines ext files blank bytes; do
    printf '%s\t%s\t%s\t%s\t%s\n' "$ext" "$files" "$lines" "$blank" "$(human_bytes "$bytes")"
  done | md_table "Extension|Files|Lines|Blank|Size"

  printf '\n## Largest files\n\n'
  sort -t$'\t' -k4,4nr "$WORK/files" | head -n "$TOP" | while IFS=$'\t' read -r ext lines blank bytes file; do
    printf '%s\t%s\t%s\n' "$file" "$(human_bytes "$bytes")" "$lines"
  done | md_table "File|Size|Lines"

  printf '\n## Hotspots (most churn)\n\n'
  sort -t$'\t' -k1,1nr "$WORK/churn" | head -n "$TOP" | while IFS=$'\t' read -r churn file touches kind; do
    printf '%s\t%s\t%s\t%s\n' "$file" "$touches" "$churn" "$kind"
  done | md_table "File|Touches|Churn|Note"

  printf '\n## Activity by month\n\n'
  sort "$WORK/months" | tail -n 24 | bars

  printf '\n## Activity by weekday\n\n'
  sort "$WORK/weekdays" | awk -F'\t' '
    BEGIN { split("Mon Tue Wed Thu Fri Sat Sun", n, " ") }
    { printf "%s\t%s\n", n[$1], $2 }
  ' | bars

  printf '\n## Activity by hour\n\n'
  sort "$WORK/hours" | bars

  if [[ -s "$WORK/todos" ]]; then
    printf '\n## TODO / FIXME\n\n'
    head -n "$TOP" "$WORK/todos" | awk '
      {
        split($0, p, ":")
        text = $0
        sub(/^[^:]*:[^:]*:[[:space:]]*/, "", text)
        if (length(text) > 100) text = substr(text, 1, 97) "..."
        printf "%s:%s\t%s\n", p[1], p[2], text
      }
    ' | md_table "Location|Text"
  fi
}

if [[ -n "$OUTPUT" ]]; then
  mkdir -p -- "$(dirname -- "$OUTPUT")"
  report > "$OUTPUT"
  printf 'report written to %s\n' "$OUTPUT"
else
  report
fi
