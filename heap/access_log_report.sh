#!/usr/bin/env bash
set -euo pipefail

TOP=10
OUTPUT=""
FORMAT="text"
STATUS_FILTER=""
DAY_FILTER=""
FILES=()

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    -n|--top) TOP="${2:?}"; shift 2 ;;
    -o|--output) OUTPUT="${2:?}"; shift 2 ;;
    -f|--format) FORMAT="${2:?}"; shift 2 ;;
    -s|--status) STATUS_FILTER="${2:?}"; shift 2 ;;
    -d|--day) DAY_FILTER="${2:?}"; shift 2 ;;
    --) shift; FILES+=("$@"); break ;;
    -*) die "unknown option: $1" ;;
    *) FILES+=("$1"); shift ;;
  esac
done

((${#FILES[@]})) || die "no log files given"
[[ "$TOP" =~ ^[1-9][0-9]*$ ]] || die "--top must be a positive number"
[[ -z "$STATUS_FILTER" || "$STATUS_FILTER" =~ ^[1-5]([0-9x]{2})?$ ]] || die "--status must look like 404, 5xx or 4"
[[ -z "$DAY_FILTER" || "$DAY_FILTER" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "--day must be YYYY-MM-DD"
case "$FORMAT" in text|markdown) ;; *) die "--format must be text or markdown" ;; esac

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

read_logs() {
  local f
  for f in "${FILES[@]}"; do
    [[ -r "$f" ]] || die "cannot read $f"
    case "$f" in
      *.gz) gzip -dc -- "$f" ;;
      *) cat -- "$f" ;;
    esac
  done
}

read_logs | awk -v work="$WORK" -v status_filter="${STATUS_FILTER//x/}" -v day_filter="$DAY_FILTER" '
BEGIN {
  months = "JanFebMarAprMayJunJulAugSepOctNovDec"
  FS = " "
}
{
  n = split($0, q, "\"")
  if (n < 3 || substr($4, 1, 1) != "[") { bad++; next }

  ip = $1
  stamp = substr($4, 2)
  split(stamp, t, /[\/:]/)
  m = (index(months, t[2]) + 2) / 3
  day = sprintf("%04d-%02d-%02d", t[3], m, t[1])
  hour = t[4]
  if (day_filter != "" && day != day_filter) next

  split(q[2], req, " ")
  method = req[1]
  path = req[2]
  sub(/\?.*/, "", path)
  if (path == "") path = "-"

  split(q[3], sb, " ")
  status = sb[1]
  bytes = (sb[2] ~ /^[0-9]+$/) ? sb[2] : 0
  if (status !~ /^[1-5][0-9][0-9]$/) { bad++; next }
  if (status_filter != "" && index(status, status_filter) != 1) next

  agent = (n >= 6) ? q[6] : "-"
  lower_agent = tolower(agent)
  if (lower_agent ~ /bot|crawl|spider|slurp/) family = "bot"
  else if (lower_agent ~ /curl|wget|python|go-http|java\//) family = "script"
  else if (agent ~ /Edg\//) family = "edge"
  else if (agent ~ /Chrome\//) family = "chrome"
  else if (agent ~ /Firefox\//) family = "firefox"
  else if (agent ~ /Safari\//) family = "safari"
  else family = "other"

  rt = $NF
  if (rt ~ /^[0-9]+\.[0-9]+$/) {
    timed++
    rt_sum += rt
    path_rt[path] += rt
    path_rt_n[path]++
    if (rt > path_rt_max[path]) path_rt_max[path] = rt
  }

  total++
  total_bytes += bytes
  ips[ip]++
  ip_bytes[ip] += bytes
  paths[path]++
  path_bytes[path] += bytes
  statuses[status]++
  classes[substr(status, 1, 1) "xx"]++
  methods[method]++
  hours[hour]++
  days[day]++
  agents[family]++
  if (status >= 400) errors[status "\t" path]++
  if (first == "" || day " " hour < first) first = day " " hour
  if (last == "" || day " " hour > last) last = day " " hour
}
END {
  printf "%d\t%d\t%d\t%d\t%.6f\t%s\t%s\n", total, total_bytes, bad, timed, rt_sum, first, last > work "/summary"
  for (k in ips) printf "%d\t%s\t%d\n", ips[k], k, ip_bytes[k] > work "/ips"
  for (k in paths) printf "%d\t%s\t%d\n", paths[k], k, path_bytes[k] > work "/paths"
  for (k in statuses) printf "%d\t%s\n", statuses[k], k > work "/statuses"
  for (k in classes) printf "%d\t%s\n", classes[k], k > work "/classes"
  for (k in methods) printf "%d\t%s\n", methods[k], k > work "/methods"
  for (k in hours) printf "%s\t%d\n", k, hours[k] > work "/hours"
  for (k in days) printf "%s\t%d\n", k, days[k] > work "/days"
  for (k in agents) printf "%d\t%s\n", agents[k], k > work "/agents"
  for (k in errors) printf "%d\t%s\n", errors[k], k > work "/errors"
  for (k in path_rt) printf "%.6f\t%s\t%d\t%.3f\n", path_rt[k] / path_rt_n[k], k, path_rt_n[k], path_rt_max[k] > work "/latency"
}
'

for f in ips paths statuses classes methods hours days agents errors latency; do
  touch "$WORK/$f"
done

IFS=$'\t' read -r TOTAL TOTAL_BYTES BAD TIMED RT_SUM FIRST LAST < "$WORK/summary"

human_bytes() {
  awk -v b="$1" 'BEGIN {
    split("B KB MB GB TB", u, " ")
    i = 1
    while (b >= 1024 && i < 5) { b /= 1024; i++ }
    printf (i == 1 ? "%d %s" : "%.1f %s"), b, u[i]
  }'
}

percent() {
  awk -v a="$1" -v b="$2" 'BEGIN { printf "%.1f%%", (b ? a * 100 / b : 0) }'
}

heading() {
  if [[ "$FORMAT" == markdown ]]; then
    printf '\n## %s\n\n' "$1"
  else
    printf '\n%s\n%s\n' "$1" "$(printf '%*s' "${#1}" '' | tr ' ' '=')"
  fi
}

table() {
  local header="$1"
  if [[ "$FORMAT" == markdown ]]; then
    awk -F'\t' -v header="$header" '
      BEGIN {
        n = split(header, h, "|")
        line = "|"; sep = "|"
        for (i = 1; i <= n; i++) { line = line " " h[i] " |"; sep = sep "---|" }
        print line; print sep
      }
      { row = "|"; for (i = 1; i <= NF; i++) row = row " " $i " |"; print row }
    '
  else
    awk -F'\t' -v header="$header" '
      { rows[NR] = $0; for (i = 1; i <= NF; i++) if (length($i) > w[i]) w[i] = length($i); if (NF > nf) nf = NF }
      END {
        n = split(header, h, "|")
        for (i = 1; i <= n; i++) if (length(h[i]) > w[i]) w[i] = length(h[i])
        for (i = 1; i <= n; i++) printf "%-*s  ", w[i], h[i]; printf "\n"
        for (i = 1; i <= n; i++) { s = ""; for (j = 0; j < w[i]; j++) s = s "-"; printf "%s  ", s }; printf "\n"
        for (r = 1; r <= NR; r++) {
          split(rows[r], f, "\t")
          for (i = 1; i <= nf; i++) printf "%-*s  ", w[i], f[i]
          printf "\n"
        }
      }
    '
  fi
}

top_counts() {
  sort -t$'\t' -k1,1nr -k2,2 "$1" | head -n "$TOP"
}

bar_chart() {
  awk -F'\t' -v md="$FORMAT" '
    { k[NR] = $1; v[NR] = $2; if ($2 > max) max = $2 }
    END {
      if (md == "markdown") print "```"
      for (i = 1; i <= NR; i++) {
        len = max ? int(v[i] * 40 / max) : 0
        bar = ""
        for (j = 0; j < len; j++) bar = bar "#"
        printf "%-10s %8d  %s\n", k[i], v[i], bar
      }
      if (md == "markdown") print "```"
    }
  '
}

report() {
  if [[ "$FORMAT" == markdown ]]; then
    printf '# Access log report\n'
  else
    printf 'ACCESS LOG REPORT\n'
  fi

  heading "Summary"
  {
    printf 'Files\t%s\n' "${#FILES[@]}"
    printf 'Requests\t%s\n' "$TOTAL"
    printf 'Unparsed lines\t%s\n' "$BAD"
    printf 'Transferred\t%s\n' "$(human_bytes "$TOTAL_BYTES")"
    printf 'Unique IPs\t%s\n' "$(wc -l < "$WORK/ips" | tr -d ' ')"
    printf 'Unique paths\t%s\n' "$(wc -l < "$WORK/paths" | tr -d ' ')"
    if [[ -n "$FIRST" ]]; then
      printf 'Period\t%s:00 .. %s:59\n' "$FIRST" "$LAST"
    fi
    if ((TIMED > 0)); then
      printf 'Avg response time\t%s s\n' "$(awk -v s="$RT_SUM" -v n="$TIMED" 'BEGIN { printf "%.3f", s / n }')"
    fi
    if [[ -n "$STATUS_FILTER" ]]; then
      printf 'Status filter\t%s\n' "$STATUS_FILTER"
    fi
    if [[ -n "$DAY_FILTER" ]]; then
      printf 'Day filter\t%s\n' "$DAY_FILTER"
    fi
  } | table "Metric|Value"

  ((TOTAL > 0)) || return 0

  heading "Status classes"
  sort -t$'\t' -k2,2 "$WORK/classes" | while IFS=$'\t' read -r count cls; do
    printf '%s\t%s\t%s\n' "$cls" "$count" "$(percent "$count" "$TOTAL")"
  done | table "Class|Requests|Share"

  heading "Status codes"
  top_counts "$WORK/statuses" | while IFS=$'\t' read -r count code; do
    printf '%s\t%s\t%s\n' "$code" "$count" "$(percent "$count" "$TOTAL")"
  done | table "Code|Requests|Share"

  heading "Methods"
  top_counts "$WORK/methods" | while IFS=$'\t' read -r count method; do
    printf '%s\t%s\t%s\n' "$method" "$count" "$(percent "$count" "$TOTAL")"
  done | table "Method|Requests|Share"

  heading "Top $TOP IPs"
  top_counts "$WORK/ips" | while IFS=$'\t' read -r count ip bytes; do
    printf '%s\t%s\t%s\t%s\n' "$ip" "$count" "$(percent "$count" "$TOTAL")" "$(human_bytes "$bytes")"
  done | table "IP|Requests|Share|Bytes"

  heading "Top $TOP paths"
  top_counts "$WORK/paths" | while IFS=$'\t' read -r count path bytes; do
    printf '%s\t%s\t%s\n' "$path" "$count" "$(human_bytes "$bytes")"
  done | table "Path|Requests|Bytes"

  heading "Heaviest paths by traffic"
  sort -t$'\t' -k3,3nr "$WORK/paths" | head -n "$TOP" | while IFS=$'\t' read -r count path bytes; do
    printf '%s\t%s\t%s\n' "$path" "$(human_bytes "$bytes")" "$count"
  done | table "Path|Bytes|Requests"

  if [[ -s "$WORK/errors" ]]; then
    heading "Top $TOP errors"
    sort -t$'\t' -k1,1nr "$WORK/errors" | head -n "$TOP" | while IFS=$'\t' read -r count code path; do
      printf '%s\t%s\t%s\n' "$code" "$path" "$count"
    done | table "Code|Path|Requests"
  fi

  if [[ -s "$WORK/latency" ]]; then
    heading "Slowest paths"
    sort -t$'\t' -k1,1nr "$WORK/latency" | head -n "$TOP" | while IFS=$'\t' read -r avg path n max; do
      printf '%s\t%.3f\t%s\t%s\n' "$path" "$avg" "$max" "$n"
    done | table "Path|Avg s|Max s|Requests"
  fi

  heading "Clients"
  top_counts "$WORK/agents" | while IFS=$'\t' read -r count family; do
    printf '%s\t%s\t%s\n' "$family" "$count" "$(percent "$count" "$TOTAL")"
  done | table "Client|Requests|Share"

  heading "Requests per hour"
  sort "$WORK/hours" | bar_chart

  if (($(wc -l < "$WORK/days") > 1)); then
    heading "Requests per day"
    sort "$WORK/days" | bar_chart
  fi
}

if [[ -n "$OUTPUT" ]]; then
  mkdir -p -- "$(dirname -- "$OUTPUT")"
  report > "$OUTPUT"
  printf 'report written to %s (%s requests)\n' "$OUTPUT" "$TOTAL"
else
  report
fi
