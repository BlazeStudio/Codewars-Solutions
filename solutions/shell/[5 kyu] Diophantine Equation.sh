# Diophantine Equation
# https://www.codewars.com/kata/554f76dca89983cc400000bb

# In mathematics, a Diophantine equation (https://en.wikipedia.org/wiki/Diophantine_equation) is a polynomial equation, usually with two or more unknowns, such that only the integer solutions are sought or studied.
#
# In this kata we want to find all integers x, y (x >= 0, y >= 0) solutions of a diophantine equation of the form:
#
# $\quad x^2 - 4y^2 = n$
#
# (where the unknowns are x and y; and n is a given positive number)
# in decreasing order of the positive $x_i$.
#
# If there is no solution return [] or "[]" or "". (See "RUN SAMPLE TESTS" for examples of returns).
#
# Examples:
#
# 90005 --> [[45003, 22501], [9003, 4499], [981, 467], [309, 37]]
# 90002 --> []
#
# Hint:
#
# $\quad x^2 - 4y^2 = (x - 2y) \cdot (x + 2y)$

#!/bin/bash
sol_equa () {
    n=$1
    out="["
    first=1
    # x^2 - 4y^2 = n => (x-2y)(x+2y) = n
    # let a = x-2y, b = x+2y, a*b = n, a<=b
    # x = (a+b)/2, y = (b-a)/4
    for ((a=1; a*a<=n; a++)); do
        if [ $((n % a)) -eq 0 ]; then
            b=$((n / a))
            if [ $(( (a+b) % 2 )) -eq 0 ] && [ $(( (b-a) % 4 )) -eq 0 ]; then
                x=$(( (a+b) / 2 ))
                y=$(( (b-a) / 4 ))
                if [ $first -eq 0 ]; then out+=", "; fi
                out+="[$x, $y]"
                first=0
            fi
        fi
    done
    out+="]"
    echo "$out"
}
sol_equa "$1"
