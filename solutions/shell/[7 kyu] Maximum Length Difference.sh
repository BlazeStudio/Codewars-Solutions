# Maximum Length Difference
# https://www.codewars.com/kata/5663f5305102699bad000056

# You are given two arrays a1 and a2 of strings. Each string is composed with letters from a to z.
# Let x be any string in the first array and y be any string in the second array.
#
#   Find max(abs(length(x) − length(y)))
#
# If a1 and/or a2 are empty return -1 in each language
# except in Haskell (F#) where you will return Nothing (None).
#
# Example:
# a1 = ["hoqq", "bbllkw", "oox", "ejjuyyy", "plmiis", "xxxzgpsssa", "xxwwkktt", "znnnnfqknaz", "qqquuhii", "dvvvwz"]
# a2 = ["cccooommaaqqoxii", "gggqaffhhh", "tttoowwwmmww"]
# mxdiflg(a1, a2) --> 13
#
# Bash note:
#  - input : 2 strings with substrings separated by ,
#  - output: number as a string

#!/bin/bash
a1="$1"
a2="$2"

if [ -z "$a1" ] || [ -z "$a2" ]; then
    echo "-1"
    exit 0
fi

IFS=',' read -ra arr1 <<< "$a1"
IFS=',' read -ra arr2 <<< "$a2"

min1=999999; max1=0
for x in "${arr1[@]}"; do
    l=${#x}
    [ $l -lt $min1 ] && min1=$l
    [ $l -gt $max1 ] && max1=$l
done

min2=999999; max2=0
for x in "${arr2[@]}"; do
    l=${#x}
    [ $l -lt $min2 ] && min2=$l
    [ $l -gt $max2 ] && max2=$l
done

d1=$((max1 - min2))
d2=$((max2 - min1))
[ $d1 -lt 0 ] && d1=$((-d1))
[ $d2 -lt 0 ] && d2=$((-d2))

if [ $d1 -gt $d2 ]; then
    echo $d1
else
    echo $d2
fi
