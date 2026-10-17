# Multiples of 3 or 5
# https://www.codewars.com/kata/514b92a657cdc65150000006

# If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
#
# Finish the solution so that it returns the sum of all the multiples of 3 or 5 below the number passed in.
#
# Additionally, if the number is negative, return 0.
#
# Note: If a number is a multiple of both 3 and 5, only count it once.
#
# Courtesy of projecteuler.net (Problem 1 (https://projecteuler.net/problem=1))

#!/bin/bash
n=$1

if [ $n -le 0 ]; then
    echo 0
    exit 0
fi

sum=0
for ((i=1; i<n; i++)); do
    if [ $((i % 3)) -eq 0 ] || [ $((i % 5)) -eq 0 ]; then
        sum=$((sum + i))
    fi
done

echo $sum
