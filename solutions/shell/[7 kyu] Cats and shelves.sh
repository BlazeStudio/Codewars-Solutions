# Cats and shelves
# https://www.codewars.com/kata/62c93765cef6f10030dfa92b

# Description
# An infinite number of shelves are arranged one above the other in a staggered fashion.
#
# The cat can jump either one or three shelves at a time: from shelf i to shelf i+1 or i+3 (the cat cannot climb on the shelf directly above its head), according to the illustration:
#
#                  ┌────────┐
#                  │-6------│
#                  └────────┘
# ┌────────┐
# │------5-│
# └────────┘  ┌─────► OK!
#             │    ┌────────┐
#             │    │-4------│
#             │    └────────┘
# ┌────────┐  │
# │------3-│  │
# BANG!────┘  ├─────► OK!
#   ▲  |\_/|  │    ┌────────┐
#   │ ("^-^)  │    │-2------│
#   │ )   (   │    └────────┘
# ┌─┴─┴───┴┬──┘
# │------1-│
# └────────┘
#
# Input
# Start and finish shelf numbers (always positive integers, finish no smaller than start)
#
# Task
# Find the minimum number of jumps to go from start to finish
#
# Example
# Start 1, finish 5, then answer is 2 (1 => 4 => 5 or 1 => 2 => 5)
#
# Inspirers
#
# [inspirers: https://i.ibb.co/BymvZtL/Inspirers.jpg]

#!/bin/bash
start=$1
finish=$2

diff=$((finish - start))

if [ $diff -eq 0 ]; then
    echo 0
    exit 0
fi

jumps=0
while [ $diff -gt 0 ]; do
    if [ $diff -ge 3 ]; then
        diff=$((diff - 3))
        jumps=$((jumps + 1))
    else
        diff=$((diff - 1))
        jumps=$((jumps + 1))
    fi
done

echo $jumps
