# Backwards Read Primes
# https://www.codewars.com/kata/5539fecef69c483c5a000015

# Backwards-read-primes are primes that when read backwards in base 10 (from right to left) are a different prime. (This rules out primes which are palindromes.)
#
# Examples:
# 13 17 31 37 71 73
#
# 13 is such because it's prime and read from right to left writes 31 which is prime too. Same for the others.
#
# Task
#
# Find all Backwards-read-primes between two positive given numbers (both inclusive), the second one always being greater than or equal to the first one. The resulting array or the resulting string will be ordered following the natural order of the prime numbers.
#
# Examples (in general form):
#
# (start = 2, end = 100) => [13, 17, 31, 37, 71, 73, 79, 97]
# (start = 9900, end = 10000) => [9923, 9931, 9941, 9967]
# (start = 501, end = 599) => []
#
# See "Sample Tests" for your language.
#
# Notes
#
# - Forth:
#   Return only the first backwards-read prime between start and end
#   or 0 if you don't find any
# - Ruby:
#   Don't use the Prime class, it's disabled.

#!/bin/bash
start=$1
end=$2

is_prime() {
    local n=$1
    if [ $n -lt 2 ]; then return 1; fi
    if [ $n -eq 2 ]; then return 0; fi
    if [ $((n % 2)) -eq 0 ]; then return 1; fi
    local i=3
    while [ $((i * i)) -le $n ]; do
        if [ $((n % i)) -eq 0 ]; then return 1; fi
        i=$((i + 2))
    done
    return 0
}

reverse_num() {
    local n=$1
    local rev=0
    while [ $n -gt 0 ]; do
        rev=$((rev * 10 + n % 10))
        n=$((n / 10))
    done
    echo $rev
}

result=""
for ((i=start; i<=end; i++)); do
    if is_prime $i; then
        rev=$(reverse_num $i)
        if [ $rev -ne $i ] && is_prime $rev; then
            result="$result $i"
        fi
    fi
done

echo "${result# }"
