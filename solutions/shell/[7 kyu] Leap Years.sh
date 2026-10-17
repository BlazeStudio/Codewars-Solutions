# Leap Years
# https://www.codewars.com/kata/526c7363236867513f0005ca

# In this kata you should simply determine, whether a given year is a leap year or not. In case you don't know the rules, here they are:
#
# * Years divisible by 4 are leap years,
# * but years divisible by 100 are not leap years,
# * but years divisible by 400 are leap years.
#
# Tested years are in range 1600 ≤ year ≤ 4000.
#
# Echo out 1 if year passed in is a leap year, or 0 otherwise.

#!/bin/bash
y=$1
if [ $((y % 400)) -eq 0 ]; then
    echo 1
elif [ $((y % 100)) -eq 0 ]; then
    echo 0
elif [ $((y % 4)) -eq 0 ]; then
    echo 1
else
    echo 0
fi
