# Closest and Smallest
# https://www.codewars.com/kata/5868b2de442e3fb2bb000119

# Input
#
# - a string strng of n positive numbers (n = 0 or n >= 2)
#
# Let us call weight of a number the sum of its digits.
# For example 99 will have "weight" 18, 100 will have "weight" 1.
#
# Two numbers are "close" if the difference of their weights is small.
#
# Task:
# For each number in strng calculate its "weight" and then find two numbers
# of strng that have:
#
# - the smallest difference of weights ie that are the closest
# - with the smallest weights
# - and with the smallest indices (or ranks, numbered from 0) in strng
#
# Output:
#
# - an array of two arrays, each subarray in the following format:
#
# [number-weight, index in strng of the corresponding number, original corresponding number in strng]
#
# or a pair of two subarrays (Haskell, Clojure, FSharp) or an array of tuples (Elixir, C++)
#
# or a (char*) in C or a string in some other languages mimicking an array of two subarrays or a string
#
# or a matrix in R (2 rows, 3 columns, no columns names)
#
# The two subarrays are sorted in ascending order by their number weights if these weights are different,
# by their indexes in the string if they have the same weights.
#
# Examples:
# Let us call that function closest
# strng = "103 123 4444 99 2000"
# the weights are 4, 6, 16, 18, 2 (ie 2, 4, 6, 16, 18)
#
# closest should return [[2, 4, 2000], [4, 0, 103]] (or ([2, 4, 2000], [4, 0, 103])
# or [{2, 4, 2000}, {4, 0, 103}] or ... depending on the language)
# because 2000 and 103 have for weight 2 and 4, their indexes in strng are 4 and 0.
# The smallest difference is 2.
# 4 (for 103) and 6 (for 123) have a difference of 2 too but they are not
# the smallest ones with a difference of 2 between their weights.
# ....................
#
# strng = "80 71 62 53"
# All the weights are 8.
# closest should return [[8, 0, 80], [8, 1, 71]]
# 71 and 62 have also:
# - the smallest weights (which is 8 for all)
# - the smallest difference of weights (which is 0 for all pairs)
# - but not the smallest indices in strng.
# ....................
#
# strng = "444 2000 445 544"
# the weights are 12, 2, 13, 13 (ie 2, 12, 13, 13)
#
# closest should return [[13, 2, 445], [13, 3, 544]] or ([13, 2, 445], [13, 3, 544])
# or [{13, 2, 445}, {13, 3, 544}] or ...
# 444 and 2000 have the smallest weights (12 and 2) but not the smallest difference of weights;
# they are not the closest.
# Here the smallest difference is 0 and in the result the indexes are in ascending order.
# ...................
#
# closest("444 2000 445 644 2001 1002") --> [[3, 4, 2001], [3, 5, 1002]] or ([3, 4, 2001],
# [3, 5, 1002]]) or [{3, 4, 2001}, {3, 5, 1002}] or ...
# Here the smallest difference is 0 and in the result the indexes are in ascending order.
# ...................
#
# closest("239382 162 254765 182 485944 468751 49780 108 54")
# The weights are: 27, 9, 29, 11, 34, 31, 28, 9, 9.
# closest should return  [[9, 1, 162], [9, 7, 108]] or ([9, 1, 162], [9, 7, 108])
# or [{9, 1, 162}, {9, 7, 108}] or ...
# 108 and 54 have the smallest difference of weights too, they also have
# the smallest weights but they don't have the smallest ranks in the original string.
# ..................
#
# closest("54 239382 162 254765 182 485944 468751 49780 108")
# closest should return  [[9, 0, 54], [9, 2, 162]] or ([9, 0, 54], [9, 2, 162])
# or [{9, 0, 54}, {9, 2, 162}] or ...
# Notes :
#  If n == 0 closest("") should return []
# -  or ([], []) in Haskell, Clojure, FSharp
#
# - or [{}, {}] in Elixir or '(() ()) in Racket
# - or {{0,0,0}, {0,0,0}} in C++
# - or "[(), ()]" in Go, Nim,
# - or "{{0,0,0}, {0,0,0}}" in C, NULL in R
# - or "" in Perl.
#
# See Example tests for the format of the results in your language.

closest() {
    local str="$1"

    [[ -z "$str" ]] && return

    read -ra nums <<< "$str"

    local n=${#nums[@]}
    local -a weights

    local i j d sum
    for ((i=0; i<n; i++)); do
        sum=0
        for ((j=0; j<${#nums[i]}; j++)); do
            d=${nums[i]:j:1}
            sum=$((sum + d))
        done
        weights[i]=$sum
    done

    local best_diff=999999999
    local best_w1=999999999
    local best_w2=999999999
    local best_i=999999999
    local best_j=999999999

    local diff w1 w2 i1 i2

    for ((i=0; i<n-1; i++)); do
        for ((j=i+1; j<n; j++)); do

            if ((weights[i] < weights[j])); then
                w1=${weights[i]}
                w2=${weights[j]}
                i1=$i
                i2=$j
            elif ((weights[i] > weights[j])); then
                w1=${weights[j]}
                w2=${weights[i]}
                i1=$j
                i2=$i
            else
                w1=${weights[i]}
                w2=$w1

                if ((i < j)); then
                    i1=$i
                    i2=$j
                else
                    i1=$j
                    i2=$i
                fi
            fi

            diff=$((w2 - w1))

            if ((diff < best_diff ||
                  (diff == best_diff && w1 < best_w1) ||
                  (diff == best_diff && w1 == best_w1 && i1 < best_i) ||
                  (diff == best_diff && w1 == best_w1 && i1 == best_i && i2 < best_j)
               )); then

                best_diff=$diff
                best_w1=$w1
                best_w2=$w2
                best_i=$i1
                best_j=$i2
            fi
        done
    done

    printf '[[%d, %d, %s], [%d, %d, %s]]\n' \
        "$best_w1" "$best_i" "${nums[best_i]}" \
        "$best_w2" "$best_j" "${nums[best_j]}"
}

closest "$1"
