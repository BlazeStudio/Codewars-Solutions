# Consecutive strings
# https://www.codewars.com/kata/56a5d994ac971f1ac500003e

# You are given an array(list) strarr of strings and an integer k. Your task is to return the first longest string
# consisting of k consecutive strings taken in the array.
#
# Examples:
# strarr = ["tree", "foling", "trashy", "blue", "abcdef", "uvwxyz"], k = 2
#
# Concatenate the consecutive strings of strarr by 2, we get:
#
# treefoling   (length 10)  concatenation of strarr[0] and strarr[1]
# folingtrashy ("      12)  concatenation of strarr[1] and strarr[2]
# trashyblue   ("      10)  concatenation of strarr[2] and strarr[3]
# blueabcdef   ("      10)  concatenation of strarr[3] and strarr[4]
# abcdefuvwxyz ("      12)  concatenation of strarr[4] and strarr[5]
#
# Two strings are the longest: "folingtrashy" and "abcdefuvwxyz".
# The first that came is "folingtrashy" so
# longest_consec(strarr, 2) should return "folingtrashy".
#
# In the same way:
# longest_consec(["zone", "abigail", "theta", "form", "libe", "zas", "theta", "abigail"], 2) --> "abigailtheta"
# n being the length of the string array, if n = 0 or k > n or k <= 0 return "" (return Nothing in Elm, "nothing" in Erlang).
#
# Note
# consecutive strings : follow one after another without an interruption

#!/bin/bash
longestConsec() {
    local s="$1"
    local k=$2
    
    if [ -z "$s" ] || [ "$k" -le 0 ]; then
        echo ""
        return
    fi
    
    read -ra arr <<< "$s"
    local n=${#arr[@]}
    
    if [ $n -eq 0 ] || [ $k -gt $n ]; then
        echo ""
        return
    fi
    
    local max_len=0
    local max_str=""
    
    for ((i=0; i<=n-k; i++)); do
        local concat=""
        for ((j=0; j<k; j++)); do
            concat+="${arr[i+j]}"
        done
        local len=${#concat}
        if [ $len -gt $max_len ]; then
            max_len=$len
            max_str="$concat"
        fi
    done
    
    echo "$max_str"
}
longestConsec "$1" $2
