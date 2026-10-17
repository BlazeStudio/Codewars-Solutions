# Factorial decomposition
# https://www.codewars.com/kata/5a045fee46d843effa000070

# The aim of the kata is to decompose n! (factorial n) into its prime factors.
#
# Examples:
# n = 12; decomp(12) -> "2^10 * 3^5 * 5^2 * 7 * 11"
# since 12! is divisible by 2 ten times, by 3 five times, by 5 two times and by 7 and 11 only once.
#
# n = 22; decomp(22) -> "2^19 * 3^9 * 5^4 * 7^3 * 11^2 * 13 * 17 * 19"
#
# n = 25; decomp(25) -> 2^22 * 3^10 * 5^6 * 7^3 * 11^2 * 13 * 17 * 19 * 23
#
# Prime numbers should be in increasing order. When the exponent of a prime is 1 don't put the exponent.
#
# Notes
#
# - the function is decomp(n) and should return the decomposition of n! into its prime factors in increasing order of the primes, as a string.
# - factorial can be a very big number (4000! has 12674 digits, n can go from 300 to 4000).
# - In Fortran - as in any other language - the returned string is not permitted to contain any redundant trailing whitespace: you can use dynamically allocated character strings.

#!/bin/bash

decomp () {
    local n=$1
    local -a primes=()
    local i p e q
    local result=""
    local first=1

    # Sieve of Eratosthenes
    local -a composite
    for ((i=2; i<=n; i++)); do
        if [[ -z ${composite[i]} ]]; then
            primes+=("$i")

            # Mark multiples as composite
            if (( i * i <= n )); then
                for ((q=i*i; q<=n; q+=i)); do
                    composite[q]=1
                done
            fi
        fi
    done

    # Calculate exponent of every prime in n!
    for p in "${primes[@]}"; do
        e=0
        q=$p

        while ((q <= n)); do
            e=$((e + n / q))

            # Prevent q*q overflow (not really an issue for n <= 4000,
            # but keeps the calculation safe).
            if ((q > n / p)); then
                break
            fi
            q=$((q * p))
        done

        if ((first)); then
            first=0
        else
            result+=" * "
        fi

        if ((e == 1)); then
            result+="$p"
        else
            result+="$p^$e"
        fi
    done

    printf '%s\n' "$result"
}

decomp "$1"
