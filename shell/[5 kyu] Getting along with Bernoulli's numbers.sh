# Getting along with Bernoulli's numbers
# https://www.codewars.com/kata/5a02cf76c9fc0ee71d0000d5

# Let us define a function fsuch as:
#
# - (1) for k positive odd integer > 2 :
#
# - (2) for k positive even integer >= 2 :
#
# - (3) for k positive integer > 1 :
#
# where |x| is abs(x) and Bk the kth Bernoulli number.
#
# f is not defined for 0, 1, -1. These values will not be tested.
#
# Guidelines for Bernoulli numbers:
#
# https://en.wikipedia.org/wiki/Bernoulli_number
#
# http://mathworld.wolfram.com/BernoulliNumber.html
#
# https://www.codewars.com/kata/bernoulli-numbers-1
#
# There is more than one way to calculate them. You can make Pascal triangle and then with the basic formula below generate all Bernoulli numbers.
#
# 1 + 2B1 = 0 ... gives ...
#   B1 = - 1/2
#
# 1 + 3B1 + 3B2 = 0 ... gives ...    B2        = 1/6
#
# 1 + 4B1 + 6B2 + 4B3 = 0 ... gives ... B3 = 0
#
# 1 + 5B1 + 10B2 + 10B3 + 5B4 = 0 ... gives ... B4 = - 1/30
#
# ... and so on
#
# Task
#
# Function series(k, nb) returns (1), (2) or (3) where k is the k parameter of f and nb the upper bound in the summation of (1). nb is of no use for (2) and (3) but for the sake of simplicity it will always appear in the tests even for cases (2) and (3) with a value of 0.
#
# Examples
# S(2, 0) = 1.644934066848224....
# S(3, 100000) = 1.20205690310973....
# S(4, 0) = 1.08232323371113.....
# S(-5, 0) = -0.003968253968....
# S(-11, 0) = 0.02109279609279....
#
# Notes
#
# - For Java, C#, C++: k should be such as -27 <= k <= 20; otherwise -30 <= k <= 30 and be careful of 32-bit integer overflow.
# - Translators are welcome.

#!/bin/bash

series () {
    local k="$1"
    local nb="$2"

    awk -v k="$k" -v nb="$nb" '
    function binom(n, r,    i, x) {
        if (r < 0 || r > n) return 0
        if (r > n-r) r = n-r

        x = 1
        for (i = 1; i <= r; i++)
            x *= (n-r+i) / i

        return x
    }

    BEGIN {
        pi = 3.1415926535897932384626433832795

        # Case 1: positive odd k > 2
        if (k > 2 && k % 2 != 0) {
            s = 0
            for (n = 1; n <= nb; n++)
                s += 1 / (n ^ k)

            printf "%.17g\n", s
            exit
        }

        # Bernoulli numbers B_0 ... B_(abs(k)+1)
        maxb = (k < 0 ? -k + 1 : k)

        B[0] = 1

        for (m = 1; m <= maxb; m++) {
            sum = 0

            for (j = 0; j < m; j++)
                sum += binom(m + 1, j) * B[j]

            B[m] = -sum / (m + 1)
        }

        # Case 2: positive even k >= 2
        if (k >= 2 && k % 2 == 0) {
            b = B[k]
            if (b < 0) b = -b

            # 1/2 * |B_k| * (2*pi)^k / k!
            fact = 1
            for (i = 2; i <= k; i++)
                fact *= i

            result = 0.5 * b * ((2 * pi) ^ k) / fact

            printf "%.17g\n", result
            exit
        }

        # Case 3: negative k, where k here is the positive value
        # in f(-k).
        if (k < -1) {
            p = -k

            result = ((p % 2 == 0) ? 1 : -1) * B[p + 1] / (p + 1)

            printf "%.17g\n", result
            exit
        }
    }
    '
}

series "$1" "$2"
