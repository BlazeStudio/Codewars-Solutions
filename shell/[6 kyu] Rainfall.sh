# Rainfall
# https://www.codewars.com/kata/56a32dd6e4f4748cc3000006

# dataand data1 are two strings with rainfall records of a few cities for months from January to December.
# The records of towns are separated by \n. The name of each town is followed by :.
#
# data and towns can be seen in "Your Test Cases:".
#
# Task:
# - function: mean(town, strng) should return the average of rainfall for the city town and the strng data or data1 (In R and Julia this function is called avg).
# - function: variance(town, strng) should return the variance of rainfall for the city town and the strng data or data1.
#
# Examples:
#
# mean("London", data), 51.19(9999999999996)
# variance("London", data), 57.42(833333333374)
#
# Notes:
# - if functions mean or variance have as parameter town a city which has no records return -1 or -1.0 (depending on the language)
#
# - Don't truncate or round: the tests will pass if abs(your_result - test_result) <= 1e-2
# or abs((your_result - test_result) / test_result) <= 1e-6 depending on the language.
#
# - Shell
#   1) Shell tests only variance.
#   2) In "function "variance" $1 is "data", $2 is "town".
#
# - A ref: http://www.mathsisfun.com/data/standard-deviation.html
#
# - data and data1 (can be named d0 and d1 depending on the language; see "Sample Tests:") are adapted from:  http://www.worldclimate.com

#!/bin/bash
variance () {
    local strng="$1"
    local town="$2"
    
    local line=$(echo "$strng" | grep "^$town:")
    
    if [ -z "$line" ]; then
        echo "-1"
        return
    fi
    
    local values=$(echo "$line" | sed "s/^$town://" | tr ',' '\n' | awk '{print $2}')
    
    local sum=0
    local count=0
    for v in $values; do
        sum=$(echo "$sum + $v" | bc -l)
        count=$((count + 1))
    done
    
    local mean=$(echo "scale=16; $sum / $count" | bc -l)
    
    local sq_sum=0
    for v in $values; do
        local diff=$(echo "scale=16; $v - $mean" | bc -l)
        local sq=$(echo "scale=16; $diff * $diff" | bc -l)
        sq_sum=$(echo "$sq_sum + $sq" | bc -l)
    done
    
    local var=$(echo "scale=16; $sq_sum / $count" | bc -l)
    
    echo "$var"
}
variance "$1" "$2"
