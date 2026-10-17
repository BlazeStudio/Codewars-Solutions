# Primorial Of a Number
# https://www.codewars.com/kata/5a99a03e4a6b34bb3c000124

# Definition (Primorial Of a Number)
#
# Is similar to factorial of a number, In primorial, not all the natural numbers get multiplied, only prime numbers are multiplied to calculate the primorial of a number. It's denoted with P__# and it is the product of the first n prime numbers.
#
# Task
#
# Given a number N , calculate its primorial.
#
# Notes
#
# * Only positive numbers will be passed (N > 0) .
#
# Input >> Output Examples:
#
# 1- numPrimorial (3) ==> return (30)
#
# Explanation:
#
# Since the passed number is (3) ,Then the primorial should obtained by multiplying  2 * 3 * 5 = 30 .
#
# Mathematically written as , P_3#_ = 30 .
#
# 2- numPrimorial (5) ==> return (2310)
#
# Explanation:
#
# Since the passed number is (5) ,Then the primorial should obtained by multiplying   2 * 3 * 5 * 7 * 11 = 2310 .
#
# Mathematically written as , P_5#_ = 2310 .
#
# 3- numPrimorial (6) ==> return (30030)
#
# Explanation:
#
# Since the passed number is (6) ,Then the primorial should obtained by multiplying   2 * 3 * 5 * 7 * 11 * 13 = 30030 .
#
# Mathematically written as , P_6#_ = 30030 .
#
# Playing with Numbers Series (https://www.codewars.com/collections/playing-with-numbers)
#
# Playing With Lists/Arrays Series (https://www.codewars.com/collections/playing-with-lists-slash-arrays)
#
# For More Enjoyable Katas (http://www.codewars.com/users/MrZizoScream/authored)

#!/usr/bin/env bash

numPrimorial ()
{
    local numPrimes=$1
    local count=0
    local n=2
    local result=1
    local i
    local prime

    while (( count < numPrimes )); do
        prime=1

        for ((i=2; i*i<=n; i++)); do
            if (( n % i == 0 )); then
                prime=0
                break
            fi
        done

        if (( prime )); then
            result=$((result * n))
            ((count++))
        fi

        ((n++))
    done

    echo "$result"
}

numPrimorial "$1"
