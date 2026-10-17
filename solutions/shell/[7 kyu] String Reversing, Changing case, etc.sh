# String Reversing, Changing case, etc.
# https://www.codewars.com/kata/58305403aeb69a460b00019a

# Given 2 string parameters, show a concatenation of:
#
# - the reverse of the 2nd string with inverted case; e.g Fish -> HSIf
# - a separator in between both strings: @@@
# - the 1st string reversed with inverted case and then mirrored; e.g Water -> RETAwwATER
#
# ** Keep in mind that this kata was initially designed for Shell, I'm aware it may be easier in other languages.**

#!/bin/bash
s1="$1"
s2="$2"

invert() {
    local s="$1"
    local out=""
    for ((i=0; i<${#s}; i++)); do
        c="${s:i:1}"
        if [[ "$c" =~ [a-z] ]]; then
            out+="${c^^}"
        elif [[ "$c" =~ [A-Z] ]]; then
            out+="${c,,}"
        else
            out+="$c"
        fi
    done
    echo "$out"
}

rev2=""
for ((i=${#s2}-1; i>=0; i--)); do
    rev2+="${s2:i:1}"
done
rev2=$(invert "$rev2")

rev1=""
for ((i=${#s1}-1; i>=0; i--)); do
    rev1+="${s1:i:1}"
done
rev1=$(invert "$rev1")

inv1=$(invert "$s1")

echo "${rev2}@@@${rev1}${inv1}"
