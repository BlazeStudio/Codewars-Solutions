# Parts of a list
# https://www.codewars.com/kata/56f3a1e899b386da78000732

# Write a function partlist that gives all the ways to divide a list (an array) of at least two elements into two non-empty parts.
#
# - Each two non empty parts will be in a pair (or an array for languages without tuples or a structin C - C: see Examples test Cases - )
# - Each part will be in a string
# - Elements of a pair must be in the same order as in the original array.
#
# Examples of returns in different languages:
# a = ["az", "toto", "picaro", "zone", "kiwi"] -->
# [["az", "toto picaro zone kiwi"], ["az toto", "picaro zone kiwi"], ["az toto picaro", "zone kiwi"], ["az toto picaro zone", "kiwi"]]
# or
#  a = {"az", "toto", "picaro", "zone", "kiwi"} -->
# {{"az", "toto picaro zone kiwi"}, {"az toto", "picaro zone kiwi"}, {"az toto picaro", "zone kiwi"}, {"az toto picaro zone", "kiwi"}}
# or
# a = ["az", "toto", "picaro", "zone", "kiwi"] -->
# [("az", "toto picaro zone kiwi"), ("az toto", "picaro zone kiwi"), ("az toto picaro", "zone kiwi"), ("az toto picaro zone", "kiwi")]
# or
# a = [|"az", "toto", "picaro", "zone", "kiwi"|] -->
# [("az", "toto picaro zone kiwi"), ("az toto", "picaro zone kiwi"), ("az toto picaro", "zone kiwi"), ("az toto picaro zone", "kiwi")]
# or
# a = ["az", "toto", "picaro", "zone", "kiwi"] -->
# "(az, toto picaro zone kiwi)(az toto, picaro zone kiwi)(az toto picaro, zone kiwi)(az toto picaro zone, kiwi)"
# Note
# You can see other examples for each language in "Your test cases"

#!/bin/bash
s="$1"
read -ra arr <<< "$s"
n=${#arr[@]}

result=""
for ((i=1; i<n; i++)); do
    left=""
    for ((j=0; j<i; j++)); do
        if [ -z "$left" ]; then
            left="${arr[j]}"
        else
            left="$left ${arr[j]}"
        fi
    done
    right=""
    for ((j=i; j<n; j++)); do
        if [ -z "$right" ]; then
            right="${arr[j]}"
        else
            right="$right ${arr[j]}"
        fi
    done
    result+="($left,$right)"
done

echo "$result"
