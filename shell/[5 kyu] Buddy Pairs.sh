# Buddy Pairs
# https://www.codewars.com/kata/59ccf051dcc4050f7800008f

# Buddy pairs
#
# You know what divisors of a number are. The divisors of a positive integer n are said to be proper when you consider only the divisors other than n itself. In the following description, divisors will mean proper divisors.  For example for  100 they are 1, 2, 4, 5, 10, 20, 25, and 50.
#
# Let s(n) be the sum of these proper divisors of n.  Call buddy two positive integers such that the sum of the proper divisors of each number is one more than the other number:
#
# (n, m) are a pair of buddy if s(m) = n + 1 and s(n) = m + 1
#
# For example 48 & 75 is such a pair:
# * Divisors of 48 are: 1, 2, 3, 4, 6, 8, 12, 16, 24 --> sum: 76 = 75 + 1
# * Divisors of 75 are: 1, 3, 5, 15, 25 --> sum: 49 = 48 + 1
#
# Task
#
# Given two positive integers start and limit, the function buddy(start, limit) should return the first pair (n m) of buddy pairs  such that n (positive integer) is between start (inclusive) and limit (inclusive);  m can be greater than limit and has to be greater than n
#
# If there is no buddy pair satisfying the conditions, then return "Nothing" or (for Go lang) nil or (for Dart) null; (for Lua, Pascal, Perl, D) [-1, -1]; (for Erlang {-1, -1}).
# Examples
#
# (depending on the languages)
# buddy(10, 50) returns [48, 75]
# buddy(48, 50) returns [48, 75]
# or
# buddy(10, 50) returns "(48 75)"
# buddy(48, 50) returns "(48 75)"
#
# Notes
#
# - for C: The returned string will be free'd.
# - See more examples in "Sample Tests:" of your language.

#!/bin/bash

buddy() {
    local start="$1"
    local limit="$2"

    awk -v start="$start" -v limit="$limit" '
    # Sum of all positive divisors, using prime factorization.
    # Return proper-divisor sum (sum of divisors minus x).
    function proper_sum(x,    rem, p, power, sigma, i, last, step) {
        if (x <= 1) return 0

        rem = x
        sigma = 1

        for (i = 1; i <= prime_count; i++) {
            p = primes[i]
            if (p * p > rem) break

            if (rem % p == 0) {
                power = 1
                while (rem % p == 0) {
                    rem /= p
                    power *= p
                }

                # Geometric sum: 1 + p + p^2 + ... + p^e
                sigma *= (power * p - 1) / (p - 1)
            }
        }

        # If a prime factor remains, it contributes (1 + rem).
        if (rem > 1)
            sigma *= (1 + rem)

        return sigma - x
    }

    BEGIN {
        # Generate primes up to sqrt(limit), enough to factor n <= limit.
        maxp = int(sqrt(limit))
        if (maxp < 2) maxp = 2

        for (i = 2; i <= maxp; i++) {
            if (!composite[i]) {
                primes[++prime_count] = i
                if (i * i <= maxp) {
                    for (j = i * i; j <= maxp; j += i)
                        composite[j] = 1
                }
            }
        }

        for (n = start; n <= limit; n++) {
            sn = proper_sum(n)
            m = sn - 1

            if (m > n && proper_sum(m) == n + 1) {
                printf "(%.0f %.0f)\n", n, m
                exit
            }
        }

        print "Nothing"
    }
    '
}

buddy "$1" "$2"
