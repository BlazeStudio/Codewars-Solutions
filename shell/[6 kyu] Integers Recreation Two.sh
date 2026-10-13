# Integers: Recreation Two
# https://www.codewars.com/kata/55e86e212fce2aae75000060

# We are still with squared integers.
#
# Given 4 integers a, b, c, d we form the sum of the squares of a and b
# and then the sum of the squares of c and d. We multiply the two sums hence a number n and we try to
# decompose n in a sum of two squares e and f (e and f integers >= 0) so that n = e² + f².
#
# More: e and f must result only from sums (or differences) of products between on the one hand (a, b) and on the other (c, d) each of a, b, c, d taken only once.
# For example,
# prod2sum(1, 2, 1, 3) should return [[1, 7], [5, 5]])
# because
# 1==1*3-1*2
# 7==2*3+1*1
# 5==1*2+1*3
# Suppose we have a = 1, b = 2, c = 1, d = 3. First we calculate the sums
# 1² + 2² = 5 and 1² + 3² = 10 hence n = 50.
#
# 50 = 1² + 7² or 50 = 7² + 1² (we'll consider that these two solutions are the same)
# or 50 = 5² + 5².
#
# The return of our function will be an array of subarrays (in C an array of Pairs) sorted on the first elements of the subarrays. In each subarray the lower element should be the first.
#
# prod2sum(1, 2, 1, 3) should return [[1, 7], [5, 5]]
#
# prod2sum(2, 3, 4, 5) should return  [[2, 23], [7, 22]]
#
# because (2² + 3²) * (4² + 5²) = 533 = (7² + 22²) = (23² + 2²)
#
# prod2sum(1, 2, 2, 3) should return  [[1, 8], [4, 7]]
#
# prod2sum(1, 1, 3, 5) should return  [[2, 8]] (there are not always 2 solutions).
#
# ##Hint
# Take a sheet of paper and with a bit of algebra try to write the product of squared numbers in another way.

#!/bin/bash
prod2sum() {
    local a=$1
    local b=$2
    local c=$3
    local d=$4
    
    local e1=$((a*c - b*d))
    local f1=$((a*d + b*c))
    local e2=$((a*c + b*d))
    local f2=$((a*d - b*c))
    
    [ $e1 -lt 0 ] && e1=$((-e1))
    [ $f1 -lt 0 ] && f1=$((-f1))
    [ $e2 -lt 0 ] && e2=$((-e2))
    [ $f2 -lt 0 ] && f2=$((-f2))
    
    local p1 p2
    if [ $e1 -le $f1 ]; then p1="$e1, $f1"; else p1="$f1, $e1"; fi
    if [ $e2 -le $f2 ]; then p2="$e2, $f2"; else p2="$f2, $e2"; fi
    
    if [ "$p1" = "$p2" ]; then
        echo "[[$p1]]"
    else
        local sorted=$(printf "%s\n%s" "$p1" "$p2" | sort -t, -k1,1n)
        local first=$(echo "$sorted" | head -1)
        local second=$(echo "$sorted" | tail -1)
        echo "[[$first], [$second]]"
    fi
}
prod2sum $1 $2 $3 $4
