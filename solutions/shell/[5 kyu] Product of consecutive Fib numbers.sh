# Product of consecutive Fib numbers
# https://www.codewars.com/kata/5541f58a944b85ce6d00006a

# The Fibonacci numbers are the numbers in the following integer sequence (Fn):
# 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, ...
#
# such that:
#
# F(0) = 0\\F(1) = 1\\F(n) = F(n-1) + F(n-2)
#
# Given a number, say prod (for product), we search two Fibonacci numbers F(n) and F(n+1) verifying:
# F(n) * F(n+1) = prod
#
# Your function takes an integer (prod) and returns
# an array/tuple (check the function signature/sample tests for the return type in your language):
# * if F(n) * F(n+1) = prod:
#   (F(n), F(n+1), true)
# * If you do not find two consecutive F(n) verifying F(n) * F(n+1) = prod:
#   (F(n), F(n+1), false)
#   where F(n) is the smallest one such as F(n) * F(n+1) > prod.
#
# Examples:
#
# 714 ---> (21, 34, true)
# --> since F(8) = 21, F(9) = 34 and 714 = 21 * 34
#
# 800 --->  (34, 55, false)
# --> since F(8) = 21, F(9) = 34, F(10) = 55 and 21 * 34 < 800 < 34 * 55

#!/bin/bash
productFib() {
    prod=$1
    a=0
    b=1
    while [ $((a * b)) -lt $prod ]; do
        t=$((a + b))
        a=$b
        b=$t
    done
    if [ $((a * b)) -eq $prod ]; then
        echo "$a $b true"
    else
        echo "$a $b false"
    fi
}
productFib $1
