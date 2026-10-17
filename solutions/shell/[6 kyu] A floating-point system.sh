# A floating-point system
# https://www.codewars.com/kata/5df754981f177f0032259090

# A ﬂoating-point number can be represented as mantissa * radix ^ exponent (^ is raising radix to power exponent).
# In this kata we will be given a positive floating-point number aNumber and we want to decompose it into a positive integer mantissa
# composed of a given number of digits (called digitsNumber) and of an exponent.
# Example:
#
# aNumber = 0.06
#
# If the number of digits asked for the mantissa is digitsNumber = 10
# one can write
# aNumber : 6000000000 * 10 ^ -11
#
# the exponent in this example est -11.
# Task
#
# The function mantExp(aNumber, digitsNumber) will return aNumber in the form of a string: "mantissaPexponent" (concatenation of "mantissa", "P", "exponent"). So:
# Examples:
# mantExp(0.06, 10) returns "6000000000P-11".
# mantExp(72.0, 12)   returns "720000000000P-10"
# mantExp(1.0, 5) returns "10000P-4"
# mantExp(123456.0, 4) returns "1234P2"
# Notes:
# - In some languages aNumber could be given in the form of a string:
# mantExp("0.06", 10) returns "6000000000P-11".
# - 1 <= digitsNumber <= 15
# - 0 < aNumber < 5.0 ^ 128
# - Please ask before translating

#!/bin/bash
function mant_exp () {
    local num="$1"
    local digits="$2"
    local s int frac all first pos exp mant

    s="${num#+}"
    s="${s%%e*}"
    s="${s%%E*}"

    if [[ "$s" == *.* ]]; then
        int="${s%%.*}"
        frac="${s#*.}"
    else
        int="$s"
        frac=""
    fi

    int="${int##+(0)}"
    [[ -z "$int" ]] && int=""

    all="${int}${frac}"

    first=0
    while (( first < ${#all} )) && [[ "${all:first:1}" == "0" ]]; do
        ((first++))
    done

    if [[ -n "$int" ]]; then
        pos=$(( ${#int} - first - 1 ))
    else
        pos=$(( -first - 1 ))
    fi

    mant="${all:first:digits}"
    while (( ${#mant} < digits )); do
        mant+="0"
    done

    mant="${mant#0}"

    exp=$((pos - digits + 1))

    echo "${mant}P${exp}"
}

mant_exp "$1" "$2"
