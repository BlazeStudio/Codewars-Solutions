# Integers Recreation One
# https://www.codewars.com/kata/55aa075506463dac6600010d
# 1, 246, 2, 123, 3, 82, 6, 41 are the divisors of number 246.

# Squaring these divisors we get: 1, 60516, 4, 15129, 9, 6724, 36, 1681.

# The sum of these squares is 84100 which is 290 * 290.

# Task
# Find all integers between m and n (m and n are integers with 1 <= m <= n) such that the sum of their squared divisors is itself a square.

# We will return an array of subarrays or of tuples (in C an array of Pair) or a string.

# The subarrays (or tuples or Pairs) will have two elements: first the number the squared divisors of which is a square and then the sum of the squared divisors.

# Example:
# m =  1, n = 250 --> [[1, 1], [42, 2500], [246, 84100]]
# m = 42, n = 250 --> [[42, 2500], [246, 84100]]
# The form of the examples may change according to the language, see "Sample Tests".

# Note
# In Fortran - as in any other language - the returned string is not permitted to contain any redundant trailing whitespace: you can use dynamically allocated character strings.

#!/bin/bash
listSquared () {
  local m=$1
  local n=$2

  local -a sigma2
  local i j
  for (( i=0; i<=n; i++ )); do sigma2[i]=0; done
  for (( i=1; i<=n; i++ )); do
    local sq=$((i*i))
    for (( j=i; j<=n; j+=i )); do
      (( sigma2[j] += sq ))
    done
  done

  is_square() {
    local x=$1
    (( x < 0 )) && return 1
    local r=0 bit=1
    # Find highest power of 4 <= x
    while (( bit <= x )); do (( bit <<= 2 )); done
    (( bit >>= 2 ))
    while (( bit != 0 )); do
      if (( x >= r + bit )); then
        (( x -= r + bit ))
        (( r = (r >> 1) + bit ))
      else
        (( r >>= 1 ))
      fi
      (( bit >>= 2 ))
    done
    (( r * r == $1 ))
  }

  local -a results=()
  for (( i=m; i<=n; i++ )); do
    local s=${sigma2[i]}
    if is_square "$s"; then
      results+=("[$i, $s]")
    fi
  done

  if (( ${#results[@]} == 0 )); then
    echo "[]"
  else
    local out="[" first=1
    for r in "${results[@]}"; do
      if (( first )); then out+="$r"; first=0
      else out+=", $r"; fi
    done
    echo "${out}]"
  fi
}
listSquared "$1" "$2"