# Transform
# https://www.codewars.com/kata/5e1f2234c5772a000fe7f7ce

# Let us consider, as an example, strings like the following:
# s='"Title"
# Date class
# .
# .
# "Connected"
# fifo,
# isoYear,
# daynum,
# argfirst,
# monthend,
# weeknum,
# assoc.quantity,
# yearstart,
# rank,
# today.'
# or:
# s="\"Title\"\nDate class \n.\n.\n\"Connected\"\nfifo, \nisoYear, \ndaynum, \nargfirst, \nmonthend, \nweeknum, \nassoc.quantity, \nyearstart, \nrank, \ntoday."
# s has two parts; the first one before "Connected"  (between double quotes) can include any substrings, the second one after "Connected" includes substrings separated by comma and white-space(s), on one or several lines.
#
# We want to transform s into the following string  t:
# t='"Title"
# Date class
# .
# .
# "Connected"
#  1 argfirst
#  2 assoc.quantity
#  3 daynum
#  4 fifo
#  5 isoYear
#  6 monthend
#  7 rank
#  8 today
#  9 weeknum
# 10 yearstart.
# or:
# t="\"Title\"\nDate class \n.\n.\n\"Connected\"\n 1 argfirst\n 2 assoc.quantity\n 3 daynum\n 4 fifo\n 5 isoYear\n 6 monthend\n 7 rank\n 8 today\n 9 weeknum\n10 yearstart."
# t has two parts. The only difference between s and t is that in t all substrings following "Connected" are in alphabetical order, each on its own line, without duplicates and preceded by their ranks in the second part of t (these numbers are in a field of two, right aligned, followed by a space).
#
# Task
# Let us call trans the function with parameter s which transforms s into t.
# The parameter s will always be a string including the substring "Connected". What you have to do to get t is to reproduce the first part of s, keep "Connected", get the substrings of the second part of s in
# - alphabetical order,
# - each on its own line,
# - without duplicates
# - and preceded by their ranks in the second part of t.
#
# Notes:
# - The first part of t is the same as in s.
# - s and t end with a dot.
# - You can see more examples in "RUN".
# - Please ask before translating.

#!/bin/bash
s="$1"

before="${s%%\"Connected\"*}"
after="${s#*\"Connected\"}"

after="${after#$'\n'}"

after="${after%.}"

words=$(echo "$after" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' | sort -u)

result="${before}\"Connected\""

rank=1
while IFS= read -r word; do
    result+=$'\n'"$(printf '%2d' $rank) $word"
    rank=$((rank + 1))
done <<< "$words"

result+="."

echo "$result"
