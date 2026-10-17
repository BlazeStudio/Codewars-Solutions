# Weight for weight
# https://www.codewars.com/kata/55c6126177c9441a570000cc

# My friend John and I are members of the "Fat to Fit Club (FFC)". John is worried because
# each month a list with the weights of members is published and each month he is the last on the list
# which means he is the heaviest.
#
# I am the one who establishes the list so I told him:
# "Don't worry any more, I will modify the order of the list".
# It was decided to attribute a "weight" to numbers. The weight of a number will be from now on the sum of its digits.
#
# For example 99 will have "weight" 18, 100 will have "weight" 1 so in the list 100 will come before 99.
#
# Given a string with the weights of FFC members in normal order can you give this string ordered by "weights" of these numbers?
#
# Example:
# "56 65 74 100 99 68 86 180 90" ordered by numbers weights becomes:
#
# "100 180 90 56 65 74 68 86 99"
#
# When two numbers have the same "weight", let us class them as if they were strings (alphabetical ordering) and not numbers:
#
# 180 is before 90 since, having the same "weight" (9),  it comes before as a string.
#
# All numbers in the list are positive numbers and the list can be empty.
#
# Notes
#
# - it may happen that the input string have leading, trailing whitespaces and more than a unique whitespace between two consecutive numbers
# - For C: The result is freed.

#!/bin/bash
orderweight () {
    local input="$1"
    read -ra nums <<< "$input"
    local n=${#nums[@]}
    [ $n -eq 0 ] && { echo ""; return; }
    
    local weights=()
    for ((i=0; i<n; i++)); do
        local num="${nums[i]}"
        local w=0
        for ((j=0; j<${#num}; j++)); do
            w=$((w + ${num:j:1}))
        done
        weights+=($w)
    done
    
    local idx=()
    for ((i=0; i<n; i++)); do idx+=($i); done
    
    for ((i=0; i<n-1; i++)); do
        for ((j=0; j<n-1-i; j++)); do
            local a=${idx[j]}
            local b=${idx[j+1]}
            local swap=0
            if [ ${weights[a]} -gt ${weights[b]} ]; then
                swap=1
            elif [ ${weights[a]} -eq ${weights[b]} ]; then
                if [[ "${nums[a]}" > "${nums[b]}" ]]; then
                    swap=1
                fi
            fi
            if [ $swap -eq 1 ]; then
                local t=${idx[j]}
                idx[j]=${idx[j+1]}
                idx[j+1]=$t
            fi
        done
    done
    
    local out=""
    for ((i=0; i<n; i++)); do
        if [ $i -gt 0 ]; then out+=" "; fi
        out+="${nums[idx[i]]}"
    done
    echo "$out"
}
orderweight "$1"
