# Simple beads count
# https://www.codewars.com/kata/58712dfa5c538b6fc7000569

# Two red beads are placed between every two blue beads. There are N blue beads. After looking at the arrangement below work out the number of red beads.
#
# @
# @@
# @
# @@
# @
# @@
# @
# @@
# @
# @@
# @
#
# Implement a function returning the number of red beads.
#
# If there are less than 2 blue beads return 0.

#!/bin/bash
n=$1
if [ $n -lt 2 ]; then
    echo 0
else
    echo $(( (n - 1) * 2 ))
fi
