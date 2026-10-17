# k-Primes
# https://www.codewars.com/kata/5726f813c8dcebf5ed000a6b

# A natural number is called k-prime if it has exactly k prime factors, counted with multiplicity. For example:
# k = 2  -->  4, 6, 9, 10, 14, 15, 21, 22, ...
# k = 3  -->  8, 12, 18, 20, 27, 28, 30, ...
# k = 5  -->  32, 48, 72, 80, 108, 112, ...
# A natural number is thus prime if and only if it is 1-prime.
#
# Task:
# Complete the function count_Kprimes (or countKprimes, count-K-primes, kPrimes) which is given parameters k, start, end (or nd) and returns an array (or a list or a string depending on the language - see "Solution" and "Sample Tests") of the k-primes between start (inclusive) and end (inclusive).
#
# Example:
# countKprimes(5, 500, 600) --> [500, 520, 552, 567, 588, 592, 594]
#
# Notes:
# - The first function would have been better named: findKprimes or kPrimes :-)
# - In C some helper functions are given (see declarations in 'Solution').
# - For Go: nil slice is expected when there are no k-primes between start and end.
#
# Second Task: puzzle (not for Shell)
# Given a positive integer s, find the total number of solutions of the equation a + b + c = s, where a is 1-prime, b is 3-prime, and c is 7-prime.
#
# Call this function puzzle(s).
#
# Examples:
# puzzle(138)  -->  1  because [2 + 8 + 128] is the only solution
# puzzle(143)  -->  2  because [3 + 12 + 128] and [7 + 8 + 128] are the solutions


#!/bin/bash

count_kprimes() {
    local k=$1
    local start=$2
    local end=$3
    local n x p count first=1

    for ((n = start; n <= end; n++)); do
        x=$n
        count=0

        for ((p = 2; p * p <= x; p++)); do
            while ((x % p == 0)); do
                ((count++))
                ((x /= p))
            done
        done

        if ((x > 1)); then
            ((count++))
        fi

        if ((count == k)); then
            if ((first)); then
                printf "%d" "$n"
                first=0
            else
                printf " %d" "$n"
            fi
        fi
    done

    printf "\n"
}

count_kprimes "$1" "$2" "$3"
