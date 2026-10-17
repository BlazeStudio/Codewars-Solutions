# Sum by Factors
# https://www.codewars.com/kata/54d496788776e49e6b00052f

# Given an array of positive or negative integers
#
#  I= [i1,..,in]
#
# you have to produce a sorted array P of the form
#
# [ [p, sum of all ij of I for which p is a prime factor (p positive) of ij] ...]
#
# P will be sorted by increasing order of the prime numbers.
# The final result has to be given as a string in Java, C#, C, C++ and as an array of arrays in other languages.
#
# Example:
#
# I = (/12, 15/); // result = "(2 12)(3 27)(5 15)"
# [2, 3, 5] is the list of all prime factors of the elements of I, hence the result.
#
# Notes:
# - It can happen that a sum is 0 if some numbers are negative!
#
# Example: I = [15, 30, -45]
# 5 divides 15, 30 and (-45) so 5 appears in the result, the sum of the numbers for which 5 is a factor is 0 so we have [5, 0] in the result amongst others.
#
# - In Fortran - as in any other language - the returned string is not permitted to contain any redundant trailing whitespace: you can use dynamically allocated character strings.

#!/bin/bash

sumOfDivided() {
    local input="$1"

    # Empty input -> empty result
    [[ -z "$input" ]] && return

    local -A sums=()
    local -a nums
    local n x p

    read -r -a nums <<< "$input"

    for n in "${nums[@]}"; do
        # Ignore empty elements
        [[ -z "$n" ]] && continue

        x=$n
        (( x < 0 )) && x=$(( -x ))

        # 0 and 1 have no prime factors
        (( x < 2 )) && continue

        for ((p = 2; p * p <= x; p++)); do
            if (( x % p == 0 )); then
                sums["$p"]=$(( ${sums["$p"]:-0} + n ))

                # Count each prime only once for this number
                while (( x % p == 0 )); do
                    x=$(( x / p ))
                done
            fi
        done

        # Remaining factor is prime
        if (( x > 1 )); then
            sums["$x"]=$(( ${sums["$x"]:-0} + n ))
        fi
    done

    # No prime factors
    (( ${#sums[@]} == 0 )) && return

    local -a primes
    mapfile -t primes < <(
        printf '%s\n' "${!sums[@]}" | sort -n
    )

    local p
    local first=1

    for p in "${primes[@]}"; do
        if (( first )); then
            first=0
        else
            printf ' '
        fi

        printf '(%s %s)' "$p" "${sums["$p"]}"
    done

    printf '\n'
}

sumOfDivided "$1"
