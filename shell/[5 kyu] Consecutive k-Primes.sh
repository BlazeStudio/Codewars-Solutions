# Consecutive k-Primes
# https://www.codewars.com/kata/573182c405d14db0da00064e

# A natural number is called k-prime if it has exactly k prime factors, counted with multiplicity. A natural number is thus prime if and only if it is 1-prime.
# Examples:
# k = 2 -> 4, 6, 9, 10, 14, 15, 21, 22, …
# k = 3 -> 8, 12, 18, 20, 27, 28, 30, …
# k = 5 -> 32, 48, 72, 80, 108, 112, …
# Task:
#
# Given an integer k and a list arr of positive integers the function consec_kprimes (or its variants in other languages) returns
# how many times in the sequence arr numbers come up twice in a row with exactly k prime factors?
#
# Examples:
# arr = [10005, 10030, 10026, 10008, 10016, 10028, 10004]
# consec_kprimes(4, arr) => 3 because 10005 and 10030 are consecutive 4-primes, 10030 and 10026 too as well as 10028 and 10004 but 10008 and 10016 are 6-primes.
#
# consec_kprimes(4, [10175, 10185, 10180, 10197]) => 3 because 10175-10185 and 10185- 10180 and 10180-10197 are all consecutive 4-primes.
#
# Note:
#
# It could be interesting to begin with:
# https://www.codewars.com/kata/k-primes

#!/bin/bash

consec_kprimes() {
    local k="$1"
    local list="$2"

    read -ra nums <<< "$list"

    declare -A cache
    local prev=-1 count=0 i v f

    prime_factors() {
        local n="$1"
        local c=0
        local d=2

        while (( n % 2 == 0 )); do
            ((c++))
            ((n /= 2))
        done

        d=3
        while (( d <= n / d )); do
            while (( n % d == 0 )); do
                ((c++))
                ((n /= d))
            done
            ((d += 2))
        done

        ((n > 1)) && ((c++))
        echo "$c"
    }

    for v in "${nums[@]}"; do
        if [[ ${cache[$v]+_} ]]; then
            f=${cache[$v]}
        else
            f=$(prime_factors "$v")
            cache[$v]=$f
        fi

        if (( prev == k && f == k )); then
            ((count++))
        fi

        prev=$f
    done

    echo "$count"
}

consec_kprimes "$1" "$2"
