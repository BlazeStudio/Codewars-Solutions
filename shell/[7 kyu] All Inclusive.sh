# All Inclusive?
# https://www.codewars.com/kata/5700c9acc1555755be00027e

# Input:
#
# - a string strng
# - an array of strings arr
#
# Output of function contain_all_rots(strng, arr) (or containAllRots or contain-all-rots):
#
# - a boolean true if all rotations of strng are included in arr
# - false otherwise
#
# Examples:
# contain_all_rots(
#   "bsjq", ["bsjq", "qbsj", "sjqb", "twZNsslC", "jqbs"]) -> true
#
# contain_all_rots(
#   "Ajylvpy", ["Ajylvpy", "ylvpyAj", "jylvpyA", "lvpyAjy", "pyAjylv", "vpyAjyl", "ipywee"]) -> false)
#
# Note:
# Though not correct in a mathematical sense
#
# - we will consider that there are no rotations of strng == ""
# - and for any array arr: contain_all_rots("", arr) --> true
#
# Ref: https://en.wikipedia.org/wiki/String_(computer_science)#Rotations
#
# Bash:
# For bash the array is replaced by a string (see "RUN sample tests").

#!/bin/bash
s="$1"
arr="$2"

if [ -z "$s" ]; then
    echo "true"
    exit 0
fi

n=${#s}
for ((i=0; i<n; i++)); do
    rot="${s:i}${s:0:i}"
    found=0
    for word in $arr; do
        if [ "$word" = "$rot" ]; then
            found=1
            break
        fi
    done
    if [ $found -eq 0 ]; then
        echo "false"
        exit 0
    fi
done

echo "true"
