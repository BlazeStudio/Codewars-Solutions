# Bash Basics - While Loop
# https://www.codewars.com/kata/582cd9033c1acf1d45000052

# Create a simple while loop in bash that prints the numbers 1-20 to stdout.
#
# It should look like (stdout):
#
# Count: 1
# Count: 2
# ...
# Count: 20

#!/bin/bash

countToTwenty() {
    count=1
    while [ "$count" -le 20 ]; do
        echo "Count: $count"
        count=$((count + 1))
    done
}

countToTwenty
