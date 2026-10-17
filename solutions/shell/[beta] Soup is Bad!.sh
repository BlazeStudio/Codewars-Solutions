# Soup is Bad!
# https://www.codewars.com/kata/584d97ad52ee40bd020000e0

# We need help determining if the soup is bad, If it contains a nasty string return "Soup is Bad!", else return "Soup is Good!". Here you are given two Arguments, The soup is bad if the 2nd argument can be found in the first.

#!/bin/bash
soup="$1"
nasty="$2"

if [[ "$soup" == *"$nasty"* ]]; then
    echo "Soup is Bad!"
else
    echo "Soup is Good!"
fi
