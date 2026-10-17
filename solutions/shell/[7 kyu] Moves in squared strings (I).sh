# Moves in squared strings (I)
# https://www.codewars.com/kata/56dbe0e313c2f63be4000b25

# This kata is the first of a sequence of four about "Squared Strings".
#
# You are given a string of n lines, each substring being n characters long: For example:
#
# s = "abcd\nefgh\nijkl\nmnop"
#
# We will study some transformations of this square of strings.
#
# - Vertical mirror:
# vert_mirror (or vertMirror or vert-mirror)
# vert_mirror(s) => "dcba\nhgfe\nlkji\nponm"
# - Horizontal mirror:
# hor_mirror (or horMirror or hor-mirror)
#  hor_mirror(s) => "mnop\nijkl\nefgh\nabcd"
#
# or printed:
#
# vertical mirror   |horizontal mirror
# abcd --> dcba     |abcd --> mnop
# efgh     hgfe     |efgh     ijkl
# ijkl     lkji     |ijkl     efgh
# mnop     ponm     |mnop     abcd
#
# Task:
# - Write these two functions
#
# and
#
# - high-order function oper(fct, s) where
#
#  - fct is the function of one variable f to apply to the string s
# (fct will be one of vertMirror, horMirror)
#
# Examples:
# s = "abcd\nefgh\nijkl\nmnop"
# oper(vert_mirror, s) => "dcba\nhgfe\nlkji\nponm"
# oper(hor_mirror, s) => "mnop\nijkl\nefgh\nabcd"
# Note:
# The form of the parameter fct in oper
# changes according to the language. You can see each form according to the language in "Sample Tests".
#
# Bash Note:
# The input strings are separated by , instead of \n. The output strings should be separated by \r instead of \n. See "Sample Tests".

#!/bin/bash
oper() {
    local fct=$1
    local s=$2
    
    case "$fct" in
        vertMirror)
            vertMirror "$s"
            ;;
        horMirror)
            horMirror "$s"
            ;;
    esac
}

vertMirror() {
    local s=$1
    IFS=',' read -ra lines <<< "$s"
    local n=${#lines[@]}
    local result=""
    
    for ((i=0; i<n; i++)); do
        local line="${lines[i]}"
        local rev=""
        for ((j=${#line}-1; j>=0; j--)); do
            rev+="${line:j:1}"
        done
        if [ $i -eq 0 ]; then
            result="$rev"
        else
            result="$result"$'\r'"$rev"
        fi
    done
    
    printf '%s' "$result"
}

horMirror() {
    local s=$1
    IFS=',' read -ra lines <<< "$s"
    local n=${#lines[@]}
    local result=""
    
    for ((i=n-1; i>=0; i--)); do
        if [ $i -eq $((n-1)) ]; then
            result="${lines[i]}"
        else
            result="$result"$'\r'"${lines[i]}"
        fi
    done
    
    printf '%s' "$result"
}

oper "$1" "$2"
