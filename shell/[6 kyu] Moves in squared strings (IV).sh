# Moves in squared strings (IV)
# https://www.codewars.com/kata/56dbf59b0a10feb08c000227

# You are given a string of n lines, each substring being n characters long: For example:
#
# s = "abcd\nefgh\nijkl\nmnop"
#
# We will study some transformations of this square of strings.
#
# - Symmetry with respect to the antidiagonal (https://en.wikipedia.org/wiki/Main_diagonal#Antidiagonal): diag_2_sym (or diag2Sym or diag-2-sym)
#   diag_2_sym(s) => "plhd\nokgc\nnjfb\nmiea"
# - Counterclockwise rotation 90 degrees: rot_90_counter (or rot90Counter or rot-90-counter)
#   rot_90_counter(s)=> "dhlp\ncgko\nbfjn\naeim"
# - selfie_diag2_counterclock (or selfieDiag2Counterclock or selfie-diag2-counterclock)
#   It is initial string + string obtained by symmetry with respect to the anti
#   diagonal + counterclockwise rotation 90 degrees .
#   s = "abcd\nefgh\nijkl\nmnop" -->
#   "abcd|plhd|dhlp\nefgh|okgc|cgko\nijkl|njfb|bfjn\nmnop|miea|aeim"
#   or printed for the last:
#
#   selfie_diag2_counterclock
#   abcd|plhd|dhlp
#   efgh|okgc|cgko
#   ijkl|njfb|bfjn
#   mnop|miea|aeim
#
# Task
#
# - Write these functions diag_2_sym, rot_90_counter, selfie_diag2_counterclock
#
# and
#
# - high-order function oper(fct, s) where fct is the function of one variable f to apply to the string s (fct will be one of diag_2_sym, rot_90_counter, selfie_diag2_counterclock)
#
# Examples
#
# s = "abcd\nefgh\nijkl\nmnop"
# oper(diag_2_sym, s) => "plhd\nokgc\nnjfb\nmiea"
# oper(rot_90_counter, s) => "dhlp\ncgko\nbfjn\naeim"
# oper(selfie_diag2_counterclock, s) => "abcd|plhd|dhlp\nefgh|okgc|cgko\nijkl|njfb|bfjn\nmnop|miea|aeim"
#
# Notes
#
# - The form of the parameter fct in oper
# changes according to the language. You can see each form according to the language in "Your test cases".
# - It could be easier to take these katas from number (I) to number (IV)
# - Bash Note: The ouput strings should be separated by \r instead of \n. See "Sample Tests".

#!/bin/bash
oper () {
    local fct=$1
    local s=$2
    
    case "$fct" in
        diag_2_sym)
            diag_2_sym "$s"
            ;;
        rot_90_counter)
            rot_90_counter "$s"
            ;;
        selfie_diag2_counterclock)
            selfie_diag2_counterclock "$s"
            ;;
    esac
}

diag_2_sym() {
    local s=$1
    local result=""
    local i j
    mapfile -t lines <<< "$s"
    local n=${#lines[0]}
    
    for ((i=0; i<n; i++)); do
        local row=""
        for ((j=n-1; j>=0; j--)); do
            row+="${lines[j]:n-1-i:1}"
        done
        if [ $i -eq 0 ]; then
            result="$row"
        else
            result="$result"$'\r'"$row"
        fi
    done
    
    printf '%s' "$result"
}

rot_90_counter() {
    local s=$1
    local result=""
    local i j
    mapfile -t lines <<< "$s"
    local n=${#lines[0]}
    
    for ((i=0; i<n; i++)); do
        local row=""
        for ((j=0; j<n; j++)); do
            row+="${lines[j]:n-1-i:1}"
        done
        if [ $i -eq 0 ]; then
            result="$row"
        else
            result="$result"$'\r'"$row"
        fi
    done
    
    printf '%s' "$result"
}

selfie_diag2_counterclock() {
    local s=$1
    mapfile -t lines <<< "$s"
    local n=${#lines[0]}
    
    local d2=$(diag_2_sym "$s")
    local r90=$(rot_90_counter "$s")
    
    mapfile -t d2_lines <<< "$(printf '%s' "$d2" | tr '\r' '\n')"
    mapfile -t r90_lines <<< "$(printf '%s' "$r90" | tr '\r' '\n')"
    
    local result=""
    local i
    for ((i=0; i<n; i++)); do
        local row="${lines[i]}|${d2_lines[i]}|${r90_lines[i]}"
        if [ $i -eq 0 ]; then
            result="$row"
        else
            result="$result"$'\r'"$row"
        fi
    done
    
    printf '%s' "$result"
}

oper "$1" "$2"
