# Alphabetical Addition
# https://www.codewars.com/kata/5d50e3914861a500121e1958

# Your task is to add up letters to one letter.
# The script will be given a string of letters, each character being a letter to add.
# Notes:
# * Letters will always be lowercase.
# * Letters can overflow (see second to last example of the description)
# * If no letters are given, the function should return 'z'
#
# Examples:
# run_shell(args: ['abc']) = "f"
# run_shell(args: ['ab']) = "c"
# run_shell(args: ['z']) = "z"
# run_shell(args: ['za']) = "a"
# run_shell(args: ['ycb']) = "d" # notice the letters overflowing
# run_shell(args: ['']) = "z"
#
# Confused? Roll your mouse/tap over  1, b => 2, etc. Add them up. Think about the overflow yourself. Once that's done, convert it back to a letter.">here

#!/bin/bash
s="$1"

if [ -z "$s" ]; then
    echo "z"
    exit 0
fi

sum=0
for ((i=0; i<${#s}; i++)); do
    c="${s:i:1}"
    val=$(( $(printf '%d' "'$c") - 96 ))
    sum=$((sum + val))
done

result=$(( (sum - 1) % 26 ))
char=$(printf "\\$(printf '%03o' $((result + 97)))")
echo "$char"
