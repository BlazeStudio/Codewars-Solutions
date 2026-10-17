# Show multiples of 2 numbers within a range
# https://www.codewars.com/kata/583989556754d6f4c700018e

# Given 3 positive parameters a, b, limit, return all positive numbers that are a multiple of both a and b up to and including limit.
#
# Examples
#
# 1, 5, 15 --> [5, 10, 15]
# 3, 5, 15 --> [15]
# 3, 5, 40 --> [15, 30]
# 2, 4, 40 --> [4, 8, 12, 16, 20, 24, 28, 32, 36, 40]

#!/bin/bash
a=$1
b=$2
limit=$3

lcm=$((a * b))
g=$((a > b ? a : b))
h=$((a < b ? a : b))
while [ $h -ne 0 ]; do
    t=$h
    h=$((g % h))
    g=$t
done
lcm=$((a / g * b))

result=""
for ((i=lcm; i<=limit; i+=lcm)); do
    if [ -z "$result" ]; then
        result="$i"
    else
        result="$result"$'\n'"$i"
    fi
done

echo "$result"
