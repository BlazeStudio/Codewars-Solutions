# Easy wallpaper
# https://www.codewars.com/kata/567501aec64b81e252000003

# John wants to decorate the walls of a room with wallpaper.
# He wants a fool-proof method for getting it right.
#
# John knows that the rectangular room has a length of l meters, a width of w meters, a height of h meters.
# The standard width of the rolls he wants to buy is 52 centimeters. The
# length of a roll is 10 meters.
# He bears in mind however, that it’s best to have an extra length of wallpaper handy in case of mistakes or miscalculations so he wants to buy a length 15% greater than the one he needs.
#
# Last time he did these calculations he got a headache, so could you help John?
#
# Task
# Your function wallpaper(l, w, h) should return as a plain English word
# in lower case the number of rolls he must buy.
#
# Example:
#
# wallpaper(4.0, 3.5, 3.0) should return "ten"
#
# wallpaper(0.0, 3.5, 3.0) should return "zero"
#
# Notes:
#
# - all rolls (even with incomplete width) are put edge to edge
# - 0 <= l, w, h (floating numbers); it can happens that w * h * l is zero
# - the integer r (number of rolls) will always be less or equal to 20
#
# - FORTH: the number of rolls will be a positive or null integer (not a plain English word; this number can be greater than 20)
#
# - In Coffeescript, Javascript, Python, Ruby and Scala the English numbers are preloaded and can be accessed as:
# numbers = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve","thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty"]
#
# - For other languages it is not preloaded and you can instead copy the above list if you desire.

#!/bin/bash
l=$1
w=$2
h=$3

awk -v l="$l" -v w="$w" -v h="$h" 'BEGIN {
    if (l == 0 || w == 0 || h == 0) {
        print "zero"
        exit
    }
    area = 2 * h * (l + w)
    roll_area = 0.52 * 10
    rolls_needed = area / roll_area
    rolls_needed = rolls_needed * 1.15
    rolls = int(rolls_needed)
    if (rolls < rolls_needed) rolls++
    
    numbers[0]="zero"; numbers[1]="one"; numbers[2]="two"; numbers[3]="three"
    numbers[4]="four"; numbers[5]="five"; numbers[6]="six"; numbers[7]="seven"
    numbers[8]="eight"; numbers[9]="nine"; numbers[10]="ten"; numbers[11]="eleven"
    numbers[12]="twelve"; numbers[13]="thirteen"; numbers[14]="fourteen"
    numbers[15]="fifteen"; numbers[16]="sixteen"; numbers[17]="seventeen"
    numbers[18]="eighteen"; numbers[19]="nineteen"; numbers[20]="twenty"
    
    print numbers[rolls]
}'
