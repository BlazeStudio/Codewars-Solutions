# Exes and Ohs
# https://www.codewars.com/kata/55908aad6620c066bc00002a

# Check to see if a string has the same amount of 'x's and 'o's. The method must return a boolean and be case insensitive. The string can contain any char.
#
# Examples input/output:
# XO("ooxx") => true
# XO("xooxx") => false
# XO("ooxXm") => true
# XO("zpzpzpp") => true // when no 'x' and 'o' is present should return true
# XO("zzoo") => false

#!/bin/bash
s="$1"

lower=$(echo "$s" | tr '[:upper:]' '[:lower:]')

x_count=0
o_count=0
for ((i=0; i<${#lower}; i++)); do
    c="${lower:i:1}"
    [ "$c" = "x" ] && x_count=$((x_count + 1))
    [ "$c" = "o" ] && o_count=$((o_count + 1))
done

if [ $x_count -eq $o_count ]; then
    echo "true"
else
    echo "false"
fi
