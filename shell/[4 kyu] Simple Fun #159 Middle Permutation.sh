# Simple Fun #159 Middle Permutation
# https://www.codewars.com/kata/58ad317d1541651a740000c5
# Task
# You are given a string s. Every letter in s appears once.

# Consider all strings formed by rearranging the letters in s. After ordering these strings in dictionary order, return the middle term. (If the sequence has a even length n, define its middle term to be the (n/2)th term.)

# Example
# For s = "abc", the result should be "bac".

#  The permutations in order are: "abc", "acb", "bac", "bca", "cab", "cba" So, The middle term is "bac".

# Input/Output
# [input] string s
# unique letters (2 <= length <= 26)

# [output] a string
# middle permutation.

#!/bin/bash
function middle() {
  local s="$1"
  local -a chars
  mapfile -t chars < <(echo "$s" | fold -w1 | sort)

  middle_rec() {
    local -a arr=("$@")
    local len=${#arr[@]}
    if (( len == 0 )); then
      echo ""
      return
    fi
    if (( len == 1 )); then
      echo "${arr[0]}"
      return
    fi

    if (( len % 2 == 0 )); then
      local pos=$(( len / 2 - 1 ))
      local first="${arr[pos]}"
      local -a rest=()
      local i
      for (( i=0; i<len; i++ )); do
        if (( i != pos )); then
          rest+=("${arr[i]}")
        fi
      done
      local rev=""
      for (( i=${#rest[@]}-1; i>=0; i-- )); do
        rev+="${rest[i]}"
      done
      echo "${first}${rev}"
    else
      local pos=$(( len / 2 ))
      local first="${arr[pos]}"
      local -a rest=()
      local i
      for (( i=0; i<len; i++ )); do
        if (( i != pos )); then
          rest+=("${arr[i]}")
        fi
      done
      local sub
      sub=$(middle_rec "${rest[@]}")
      echo "${first}${sub}"
    fi
  }

  middle_rec "${chars[@]}"
}
middle "$1"