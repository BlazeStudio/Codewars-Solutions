# Is my friend cheating?
# https://www.codewars.com/kata/5547cc7dcad755e480000004
# A friend of mine takes the sequence of all numbers from 1 to n (where n > 0).
# Within that sequence, he chooses two numbers, a and b.
# He says that the product of a and b should be equal to the sum of all numbers in the sequence, excluding a and b.
# Given a number n, could you tell me the numbers he excluded from the sequence?
# The function takes the parameter: n (n is always strictly greater than 0) and returns an array or a string (depending on the language) of the form:

# [(a, b), ...] or [[a, b], ...] or {{a, b}, ...} or or [{a, b}, ...]
# with all (a, b) which are the possible removed numbers in the sequence 1 to n.

# [(a, b), ...] or [[a, b], ...] or {{a, b}, ...} or ... will be sorted in increasing order of the "a".

# It happens that there are several possible (a, b). The function returns an empty array (or an empty string) if no possible numbers are found which will prove that my friend has not told the truth! (Go: in this case return nil).

# Examples:
# removNb(26) should return [(15, 21), (21, 15)]
# or
# removNb(26) should return { {15, 21}, {21, 15} }
# or
# removeNb(26) should return [[15, 21], [21, 15]]
# or
# removNb(26) should return [ {15, 21}, {21, 15} ]
# or
# removNb(26) should return "15 21, 21 15"
# or

# in C:
# removNb(26) should return  {{15, 21}{21, 15}} tested by way of strings.
# Function removNb should return a pointer to an allocated array of Pair pointers, each one also allocated. 
# Note
# See examples of returns for each language in "RUN SAMPLE TESTS"

#!/bin/bash
removeNb() {
  local n=$1
  local sum=$(( n * (n + 1) / 2 ))
  local target=$(( sum + 1 ))
  local -a pairs=()

  local a
  for (( a = 1; a <= n; a++ )); do
    if (( target % (a + 1) == 0 )); then
      local b=$(( target / (a + 1) - 1 ))
      if (( b >= 1 && b <= n && b != a )); then
        pairs+=("$a $b")
      fi
    fi
  done

  local result=""
  local first=1
  for p in "${pairs[@]}"; do
    if (( first )); then
      result="$p"
      first=0
    else
      result+=",$p"
    fi
  done
  echo "$result"
}
removeNb "$1"