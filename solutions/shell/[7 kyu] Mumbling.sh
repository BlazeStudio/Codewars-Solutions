# Mumbling
# https://www.codewars.com/kata/5667e8f4e3f572a8f2000039

# This time no story, no theory. The examples below show you how to write function accum:
#
# Examples:
# accum("abcd") -> "A-Bb-Ccc-Dddd"
# accum("RqaEzty") -> "R-Qq-Aaa-Eeee-Zzzzz-Tttttt-Yyyyyyy"
# accum("cwAt") -> "C-Ww-Aaa-Tttt"
#
# The parameter of accum is a string which includes only letters from a..z and A..Z.

#!/bin/bash
s="$1"
result=""

for ((i=0; i<${#s}; i++)); do
    c="${s:i:1}"
    upper="${c^^}"
    lower="${c,,}"
    part="$upper"
    for ((j=0; j<i; j++)); do
        part+="$lower"
    done
    if [ -z "$result" ]; then
        result="$part"
    else
        result="$result-$part"
    fi
done

echo "$result"
