# Sort Strings by Most Contiguous Vowels
# https://www.codewars.com/kata/5d2d0d34bceae80027bffddb

# The goal of this Kata is to write a function that will receive an array of strings as its single argument, then the strings are each processed and sorted (in desending order) based on the length of the single longest sub-string of contiguous vowels ( aeiouAEIOU ) that may be contained within the string. The strings may contain letters, numbers, special characters, uppercase, lowercase, whitespace, and there may be (often will be) multiple sub-strings of contiguous vowels. We are only interested in the single longest sub-string of vowels within each string, in the input array.
#
# Example:
#
#     str1 = "what a beautiful day today"
#     str2 = "it's okay, but very breezy"
#
# When the strings are sorted, str1 will be first as its longest sub-string of contiguous vowels "eau" is of length 3, while str2 has as its longest sub-string of contiguous vowels "ee", which is of length 2.
#
# If two or more strings in the array have maximum sub-strings of the same length, then the strings should remain in the order in which they were found in the orginal array.

#!/bin/bash
sortStringsByVowels () {
    local input="$1"
    local -a items
    local -a records
    local item max run c

    read -r -a items <<< "$input"

    for item in "${items[@]}"; do
        max=0
        run=0

        while IFS= read -r -n1 c; do
            if [[ "$c" =~ [aeiouAEIOU] ]]; then
                ((run++))
                ((run > max)) && max=$run
            else
                run=0
            fi
        done <<< "$item"

        records+=("$max"$'\t'"$item")
    done

    printf '%s\n' "${records[@]}" |
        sort -t $'\t' -k1,1nr -s |
        cut -f2- |
        paste -sd' ' -
}

sortStringsByVowels "$1"
