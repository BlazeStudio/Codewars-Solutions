# Easy Balance Checking
# https://www.codewars.com/kata/59d727d40e8c9dd2dd00009f

# You are given a (small) check book as a - sometimes - cluttered (by non-alphanumeric characters) string:
#
# "1000.00
# 125 Market 125.45
# 126 Hardware 34.95
# 127 Video 7.45
# 128 Book 14.32
# 129 Gasoline 16.10"
# The first line shows the original balance.
# Each other line (when not blank) gives information: check number, category, check amount.
# (Input form may change depending on the language).
#
# First you have to clean the lines keeping only letters, digits, dots and spaces.
#
# Then return a report as a string (underscores show spaces -- don't put them in your solution. They are there so you can see them and how many of them you need to have):
#
# "Original_Balance:_1000.00
# 125_Market_125.45_Balance_874.55
# 126_Hardware_34.95_Balance_839.60
# 127_Video_7.45_Balance_832.15
# 128_Book_14.32_Balance_817.83
# 129_Gasoline_16.10_Balance_801.73
# Total_expense__198.27
# Average_expense__39.65"
# On each line of the report you have to add the new balance and then in the last two lines the total expense and the average expense.
# So as not to have a too long result string we don't ask for a properly formatted result.
#
# Notes
# - See input examples in Sample Tests.
# - It may happen that one (or more) line(s) is (are) blank.
# - Round to 2 decimals your calculated results (Elm: without traling 0)
# - The line separator of results may depend on the language \n or \r\n. See examples in the "Sample tests".
# - R language: Don't use R's base function "mean()" that could give results slightly different from expected ones.

#!/bin/bash

input="$1"

IFS=$'\n' read -r -d '' -a lines <<< "$input"

balance=$(echo "${lines[0]}" | tr -cd '0-9.')
total_expense=0
count=0
result="Original Balance: $(printf "%.2f" "$balance")"

for ((i=1; i<${#lines[@]}; i++)); do
    line=$(echo "${lines[$i]}" | tr -cd 'a-zA-Z0-9. ')
    
    if [ -z "$(echo "$line" | tr -d ' ')" ]; then
        continue
    fi
    
    read -r check_num category amount <<< "$line"
    
    amount=$(printf "%.2f" "$amount")
    
    balance=$(echo "$balance - $amount" | bc -l)
    balance=$(printf "%.2f" "$balance")
    
    total_expense=$(echo "$total_expense + $amount" | bc -l)
    count=$((count + 1))
    
    result="$result"$'\n'"$check_num $category $amount Balance $balance"
done

total_expense=$(printf "%.2f" "$total_expense")
average_expense=$(echo "scale=4; $total_expense / $count" | bc -l)
average_expense=$(printf "%.2f" "$average_expense")

result="$result"$'\n'"Total expense  $total_expense"
result="$result"$'\n'"Average expense  $average_expense"

echo "$result"
