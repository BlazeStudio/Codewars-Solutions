# Palindromic Factorization: Pure Bash vs. the Clock
# https://www.codewars.com/kata/6aba7ed3f83fb3ab30958e88

# A palindromic factorization of a string is a way to cut it into consecutive non-empty pieces, each of which is a palindrome. Every string has one (just cut it into single letters), but we want the shortest one.
#
# Task
#
# Write a Bash script that receives a string s as its first argument $1 and prints the minimum number of palindromes s can be split into.
#
# Examples
#
# | s | answer | an optimal split |
# |---|:-:|---|
# | abacaba | 1 | abacaba |
# | bananas | 3 | b · anana · s |
# | abaab | 2 | a · baab |
# | mississippi | 4 | m · ississi · pp · i |
# | racecarannakayak | 3 | racecar · anna · kayak |
# | abcdefghijklmnopqrstuvwxyz | 26 | every letter on its own |
#
# Greedily taking the longest palindromic prefix does not work: for abaab it produces aba · a · b.
#
# Input / Output
#
# - $1 — lowercase latin letters only, 1 <= length <= 10 000.
# - Print a single integer and nothing else (stderr is merged into the output).
#
# Rules: pure Bash
#
# Your script runs in Bash restricted mode with an empty PATH:
#
# - only Bash builtins work — no awk, sed, grep, sort, bc, expr, python, perl, …;
# - no output redirection (>, >>, >&), no exec, no command names containing /.
#
# Loops, arithmetic, arrays, read, printf, parameter expansion — all fair game.
#
# Performance
#
# There are about 100 tests, and all of them together have to finish within the 12-second limit. The largest strings have up to 10 000 characters and are built to be as nasty as possible: long runs of one letter, periodic blocks, Fibonacci words, random noise glued to all of the above.
#
# - The textbook O(n²) dynamic programming times out.
# - So does any approach that visits every palindromic suffix of every prefix: aaa…a alone has n(n+1)/2 palindromic substrings.
# - A Bash loop does roughly a million simple operations per second. Aim for O(n log n) with a small constant — and know your shell: not every Bash data structure is as cheap as it looks.
#
# The size of the performance tests is calibrated to the speed of the test machine; the reference solution uses a bit less than half of the time limit.
#
# Good luck — and may your loops be few.

#!/bin/bash

s=$1
n=${#s}
(( n == 0 )) && { echo 0; exit; }

declare -A S L K D Q M P X T A
L[0]=-1 K[0]=0 D[0]=0      # imaginary root (length -1)
L[1]=0  K[1]=0 D[1]=0      # empty root
X[0]=1000000000 A[0]=0
cnt=2 last=1 i=0

while (( i < n )) && IFS= read -rN1 c; do
  S[$(( ++i ))]=$c

  # longest palindromic suffix xPx with x = c
  cur=$last
  until [[ ${S[$(( i - 1 - L[$cur] ))]} == "$c" ]]; do cur=${K[$cur]}; done

  v=${T[$cur$c]}
  if [[ -z $v ]]; then                       # new palindrome: create node
    v=$(( cnt++ ))
    if (( (L[$v] = L[$cur] + 2) == 1 )); then
      u=1
    else
      p=${K[$cur]}
      until [[ ${S[$(( i - 1 - L[$p] ))]} == "$c" ]]; do p=${K[$p]}; done
      u=${T[$p$c]}
    fi
    T[$cur$c]=$v K[$v]=$u
    if (( (D[$v] = L[$v] - L[$u]) == D[$u] )); then
      Q[$v]=${Q[$u]} P[$v]=$u
    else
      Q[$v]=$u P[$v]=0
    fi
    (( M[$v] = L[${Q[$v]}] + D[$v] ))
  fi
  last=$v best=$i

  # dp over the O(log n) series of palindromic suffixes
  for (( ; v > 1; v = Q[$v] )); do
    (( t = A[$(( i - M[$v] ))], x = X[${P[$v]}], t > x && (t = x),
       X[$v] = t, t < best && (best = t + 1) ))
  done
  A[$i]=$best
done <<< "$s"

echo "${A[$n]}"
