# Primes in numbers
# https://www.codewars.com/kata/54d512e62a5e54c96200019e

# Given a positive number n > 1 find the prime factor decomposition of n.
# The result will be a string with the following form :
#  "(p1**n1)(p2**n2)...(pk**nk)"
# with the p(i) in increasing order and n(i) empty if
# n(i) is 1.
# Example: n = 86240 should return "(2**5)(5)(7**2)(11)"

#!/bin/bash
primeFactors() {
    n=$1
    out=""
    d=2
    while [ $((d * d)) -le $n ]; do
        if [ $((n % d)) -eq 0 ]; then
            c=0
            while [ $((n % d)) -eq 0 ]; do
                n=$((n / d))
                c=$((c + 1))
            done
            if [ $c -eq 1 ]; then
                out+="($d)"
            else
                out+="($d**$c)"
            fi
        fi
        d=$((d + 1))
    done
    if [ $n -gt 1 ]; then
        out+="($n)"
    fi
    echo "$out"
}
primeFactors $1
