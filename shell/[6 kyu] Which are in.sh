# Which are in?
# https://www.codewars.com/kata/550554fd08b86f84fe000a58

# Given two arrays of strings a1 and a2 return a sorted array r in lexicographical order of the strings of a1 which are substrings of strings of a2.
#
# Example 1:
# a1 = ["arp", "live", "strong"]
#
# a2 = ["lively", "alive", "harp", "sharp", "armstrong"]
#
# returns ["arp", "live", "strong"]
#
# Example 2:
# a1 = ["tarp", "mice", "bull"]
#
# a2 = ["lively", "alive", "harp", "sharp", "armstrong"]
#
# returns []
#
# Notes:
# - Arrays are written in "general" notation. See "Your Test Cases" for examples in your language.
# - In Shell bash a1 and a2 are strings. The return is a string where words are separated by commas.
# - Beware: In some languages r must be without duplicates.

#!/bin/bash
inArray() {
    local a1="$1"
    local a2="$2"
    
    local result=()
    for w in $a1; do
        for s in $a2; do
            if [[ "$s" == *"$w"* ]]; then
                result+=("$w")
                break
            fi
        done
    done
    
    if [ ${#result[@]} -eq 0 ]; then
        echo ""
        return
    fi
    
    local sorted=$(printf '%s\n' "${result[@]}" | sort -u)
    local out=""
    while IFS= read -r line; do
        if [ -z "$out" ]; then
            out="$line"
        else
            out="$out,$line"
        fi
    done <<< "$sorted"
    
    echo "$out"
}
inArray "$1" "$2"
