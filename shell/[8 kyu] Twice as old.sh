# Twice as old
# https://www.codewars.com/kata/5b853229cfde412a470000d0

# Your function takes two arguments:
# 1. current father's age (years)
# 2. current age of his son (years)
#
# Calculate how many years ago the father was twice as old as his son (or in how many years he will be twice as old). The answer is always greater or equal to 0, no matter if it was in the past or it is in the future.

#!/bin/sh

dad_years_old=$1
son_years_old=$2

diff=$((dad_years_old - 2 * son_years_old))
if [ "$diff" -lt 0 ]; then
    diff=$((-diff))
fi

echo "$diff"

exit
