# Going to zero or to infinity?
# https://www.codewars.com/kata/55a29405bc7d2efaff00007c

# Consider the following numbers (where n! is factorial(n)):
# u1 = (1 / 1!) * (1!)
# u2 = (1 / 2!) * (1! + 2!)
# u3 = (1 / 3!) * (1! + 2! + 3!)
# ...
# un = (1 / n!) * (1! + 2! + 3! + ... + n!)
#
# Which will win: 1 / n! or (1! + 2! + 3! + ... + n!)?
#
# Are these numbers going to 0 because of 1/n! or to infinity due
# to the sum of factorials or to another number?
#
# Task
# Calculate (1 / n!) * (1! + 2! + 3! + ... + n!)
# for a given n, where n is an integer greater or equal to 1.
#
# Your result should be within 10^-6 of the expected one.
#
# Remark
# Keep in mind that factorials grow rather rapidly, and you need to handle large inputs.
#
# Hint
# You could try to simplify the expression.

#!/bin/bash
going() {
    n=$1
    awk -v n="$n" 'BEGIN {
        result = 0.0
        term = 1.0
        for (i = 0; i < n; i++) {
            result += term
            term /= (n - i)
        }
        printf "%.10f\n", result
    }'
}
going $1
