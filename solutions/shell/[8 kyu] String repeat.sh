# String repeat
# https://www.codewars.com/kata/57a0e5c372292dd76d000d7e

# Write a function that accepts a non-negative integer n and a string s as parameters, and returns a string of s repeated exactly n times.
#
# Examples (input -> output)
#
# 6, "I"     -> "IIIIII"
# 5, "Hello" -> "HelloHelloHelloHelloHello"

#!/bin/bash
n=$1
s="$2"

result=""
for ((i=0; i<n; i++)); do
    result+="$s"
done
echo "$result"
