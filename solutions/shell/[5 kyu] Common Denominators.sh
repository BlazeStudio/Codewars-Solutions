# Common Denominators
# https://www.codewars.com/kata/54d7660d2daf68c619000d95

# Common denominators
#
# You will have a list of rationals in the form
# { {numer_1, denom_1} , ... {numer_n, denom_n} }
# or
# [ [numer_1, denom_1] , ... [numer_n, denom_n] ]
# or
# [ (numer_1, denom_1) , ... (numer_n, denom_n) ]
#
#  where all numbers are positive ints.
#  You have to produce a result in the form:
# (N_1, D) ... (N_n, D)
# or
# [ [N_1, D] ... [N_n, D] ]
# or
# [ (N_1', D) , ... (N_n, D) ]
# or
# {{N_1, D} ... {N_n, D}}
# or
# "(N_1, D) ... (N_n, D)"
#
# depending on the language (See Example tests) in which D is as small as possible and
#
# N_1/D == numer_1/denom_1 ... N_n/D == numer_n,/denom_n.
# Example:
# convertFracs [(1, 2), (1, 3), (1, 4)] `shouldBe` [(6, 12), (4, 12), (3, 12)]
# Note:
# Due to the fact that the first translations were written long ago - more than 6 years - these first translations have only irreducible fractions.
#
# Newer translations have some reducible fractions. To be on the safe side it is better to do a bit more work by simplifying fractions even if they don't have to be.
#
# Note for Bash:
# input is a string,  e.g "2,4,2,6,2,8"
# output is then          "6 12 4 12 3 12"

#!/bin/bash
convert () {
    IFS=',' read -ra arr <<< "$1"
    local n=$(( ${#arr[@]} / 2 ))
    local nums=()
    local dens=()
    for ((i=0; i<n; i++)); do
        nums+=(${arr[$((2*i))]})
        dens+=(${arr[$((2*i+1))]})
    done
    
    gcd() {
        local a=$1 b=$2
        while [ $b -ne 0 ]; do
            local t=$b
            b=$((a % b))
            a=$t
        done
        echo $a
    }
    
    for ((i=0; i<n; i++)); do
        local g=$(gcd ${nums[i]} ${dens[i]})
        nums[i]=$((nums[i] / g))
        dens[i]=$((dens[i] / g))
    done
    
    local lcm=${dens[0]}
    for ((i=1; i<n; i++)); do
        local g=$(gcd $lcm ${dens[i]})
        lcm=$((lcm / g * dens[i]))
    done
    
    local out=""
    for ((i=0; i<n; i++)); do
        local factor=$((lcm / dens[i]))
        local num=$((nums[i] * factor))
        if [ $i -gt 0 ]; then out+=" "; fi
        out+="$num $lcm"
    done
    echo "$out"
}
convert "$1"
