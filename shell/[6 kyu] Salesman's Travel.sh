# Salesman's Travel
# https://www.codewars.com/kata/56af1a20509ce5b9b000001e

# A traveling salesman has to visit clients. He got each client's address e.g. "432 Main Long Road St. Louisville OH 43071" as a list.
#
# The basic zipcode format usually consists of two capital letters followed by a white space and five digits.
# The list of clients to visit was given as a string of all addresses, each separated from the others by a comma, e.g. :
#
# "123 Main Street St. Louisville OH 43071,432 Main Long Road St. Louisville OH 43071,786 High Street Pollocksville NY 56432".
#
# To ease his travel he wants to group the list by zipcode.
# Task
# The function travel will take two parameters r (addresses' list of all clients' as a string) and zipcode and returns a string in the following format:
#
# zipcode:street and town,street and town,.../house number,house number,...
#
# The street numbers must be in the same order as the streets where they belong.
#
# If a given zipcode doesn't exist in the list of clients' addresses return "zipcode:/"
#
# Examples
# r = "123 Main Street St. Louisville OH 43071,432 Main Long Road St. Louisville OH 43071,786 High Street Pollocksville NY 56432"
#
# travel(r, "OH 43071") --> "OH 43071:Main Street St. Louisville,Main Long Road St. Louisville/123,432"
#
# travel(r, "NY 56432") --> "NY 56432:High Street Pollocksville/786"
#
# travel(r, "NY 5643") --> "NY 5643:/"
#
# Note for Elixir:
# In Elixir the empty addresses' input is an empty list, not an empty string.
#
# Note:
# You can see a few addresses and zipcodes in the test cases.

#!/bin/bash
travel() {
    local r="$1"
    local zipcode="$2"
    
    local streets=""
    local numbers=""
    local found=0
    
    local IFS=','
    for addr in $r; do
        addr=$(echo "$addr" | xargs)
        if [[ "$addr" == *"$zipcode"* ]]; then
            local zip_part=$(echo "$addr" | grep -o '[A-Z][A-Z] [0-9]\{5\}$')
            if [ "$zip_part" = "$zipcode" ]; then
                local before_zip=$(echo "$addr" | sed "s/ $zipcode$//")
                local number=$(echo "$before_zip" | awk '{print $1}')
                local street=$(echo "$before_zip" | sed 's/^[0-9]* //')
                
                if [ $found -eq 0 ]; then
                    streets="$street"
                    numbers="$number"
                    found=1
                else
                    streets="$streets,$street"
                    numbers="$numbers,$number"
                fi
            fi
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo "$zipcode:/"
    else
        echo "$zipcode:$streets/$numbers"
    fi
}
travel "$1" "$2"
