# Statistics for an Athletic Association
# https://www.codewars.com/kata/55b3425df71c1201a800009c

# You are the "computer expert" of a local Athletic Association (C.A.A.).
# Many teams of runners come to compete. Each time you get a string of
# all race results of every team who has run.
# For example here is a string showing the individual results of a team of 5 runners:
#
# "01|15|59, 1|47|6, 01|17|20, 1|32|34, 2|3|17"
#
# Each part of the string is of the form: h|m|s
# where h, m, s (h for hour, m for minutes, s for seconds) are positive or null integer (represented as strings) with one or two digits. Substrings in the input string are separated by ,  or ,.
#
# To compare the results of the teams you are asked for giving
# three statistics; range, average and median.
#
# - Range : difference between the lowest and highest values.
# In {4, 6, 9, 3, 7} the lowest value is 3, and the highest is 9,
# so the range is 9 − 3 = 6.
#
# - Mean or Average : To calculate mean, add together all of the numbers
# and then divide the sum by the total count of numbers.
#
# - Median : In statistics, the median is the number separating the higher half
# of a data sample from the lower half.
# The median of a finite list of numbers can be found by arranging all
# the observations from lowest value to highest value and picking the middle one
# (e.g., the median of {3, 3, 5, 9, 11} is 5) when there is an odd number of observations.
# If there is an even number of observations, then there is no single middle value;
# the median is then defined to be the mean of the two middle values
# (the median of {3, 5, 6, 9} is (5 + 6) / 2 = 5.5).
#
# Your task is to return a string giving these 3 values.  For the example given above,
# the string result will be
#
# "Range: 00|47|18 Average: 01|35|15 Median: 01|32|34"
#
# of the form:
#  "Range: hh|mm|ss Average: hh|mm|ss Median: hh|mm|ss"`
#
# where hh, mm, ss are integers (represented by strings) with each 2 digits.
#
# Remarks:
#
# 1. if a result in seconds is ab.xy... it will be given truncated as ab.
# 2. if the given string is "" you will return ""

#!/bin/bash
s="$1"

if [ -z "$s" ]; then
    echo ""
    exit 0
fi

IFS=', ' read -ra parts <<< "$s"

times=()
for p in "${parts[@]}"; do
    p=$(echo "$p" | xargs)
    IFS='|' read -r h m sec <<< "$p"
    total=$((10#$h * 3600 + 10#$m * 60 + 10#$sec))
    times+=($total)
done

IFS=$'\n' sorted=($(printf '%s\n' "${times[@]}" | sort -n))

min=${sorted[0]}
max=${sorted[${#sorted[@]}-1]}
range=$((max - min))

sum=0
for t in "${times[@]}"; do
    sum=$((sum + t))
done
avg=$((sum / ${#times[@]}))

cnt=${#sorted[@]}
if [ $((cnt % 2)) -eq 1 ]; then
    median=${sorted[$((cnt / 2))]}
else
    a=${sorted[$((cnt / 2 - 1))]}
    b=${sorted[$((cnt / 2))]}
    median=$(((a + b) / 2))
fi

fmt() {
    local t=$1
    printf "%02d|%02d|%02d" $((t / 3600)) $(((t % 3600) / 60)) $((t % 60))
}

echo "Range: $(fmt $range) Average: $(fmt $avg) Median: $(fmt $median)"
