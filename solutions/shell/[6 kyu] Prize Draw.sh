# Prize Draw
# https://www.codewars.com/kata/5616868c81a0f281e500005c

# To participate in a prize draw each one gives his/her firstname.
#
# Each letter of a firstname
# has a value which is its rank in the English alphabet. A and a have rank 1, B and b rank 2 and so on.
#
# The length of the firstname is added to the sum of these ranks hence a number som.
#
# An array of random weights is linked to the firstnames and each som is multiplied by its corresponding weight to get what they call a winning number.
#
# Example:
# names: "COLIN,AMANDBA,AMANDAB,CAROL,PauL,JOSEPH"
# weights: [1, 4, 4, 5, 2, 1]
#
# PauL -> som = length of firstname + 16 + 1 + 21 + 12 = 4 + 50 -> 54
# The *weight* associated with PauL is 2 so PauL's *winning number* is 54 * 2 = 108.
# Now one can sort the firstnames in decreasing order of the winning numbers. When two people have the same winning number sort them alphabetically by their firstnames.
#
# Task:
#
# - parameters: st a string of firstnames, we an array of weights, n a rank
#
# - return: the firstname of the participant whose rank is n
# (ranks are numbered from 1)
#
# Example:
# names: "COLIN,AMANDBA,AMANDAB,CAROL,PauL,JOSEPH"
# weights: [1, 4, 4, 5, 2, 1]
# n: 4
#
# The function should return: "PauL"
# Notes:
# - The weight array is at least as long as the number of names, it may be longer.
#
# - If st is empty return "No participants".
#
# - If n is greater than the number of participants then return "Not enough participants".
#
# - See Examples Test Cases for more examples.

#!/bin/bash
rank() {
    local st="$1"
    local we="$2"
    local n=$3
    
    if [ -z "$st" ]; then
        echo "No participants"
        return
    fi
    
    IFS=',' read -ra names <<< "$st"
    IFS=',' read -ra weights <<< "$we"
    
    local count=${#names[@]}
    
    if [ $n -gt $count ]; then
        echo "Not enough participants"
        return
    fi
    
    local winning=()
    for ((i=0; i<count; i++)); do
        local name="${names[i]}"
        local lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        local som=${#name}
        for ((j=0; j<${#lower}; j++)); do
            local c="${lower:j:1}"
            local val=$(( $(printf '%d' "'$c") - 96 ))
            som=$((som + val))
        done
        local w=${weights[i]}
        local win=$((som * w))
        winning+=("$win:$name")
    done
    
    IFS=$'\n' sorted=($(for x in "${winning[@]}"; do echo "$x"; done | sort -t: -k1,1rn -k2,2))
    
    local result="${sorted[$((n-1))]}"
    echo "${result#*:}"
}
rank "$1" "$2" "$3"
