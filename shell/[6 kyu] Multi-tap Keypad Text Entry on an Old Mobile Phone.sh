# Multi-tap Keypad Text Entry on an Old Mobile Phone
# https://www.codewars.com/kata/54a2e93b22d236498400134b

# Prior to having fancy iPhones, teenagers would wear out their thumbs sending SMS
# messages on candybar-shaped feature phones with 3x4 numeric keypads.
#
#     |     | | ABC | | DEF |
#     |  1  | |  2  | |  3  |
#
#     | GHI | | JKL | | MNO |
#     |  4  | |  5  | |  6  |
#
#     |PQRS | | TUV | | WXYZ|
#     |  7  | |  8  | |  9  |
#
#     |  *  | |space| |  #  |
#     |     | |  0  | |     |
#
# Prior to the development of T9 systems (predictive text entry), the method to type words was called "multi-tap" and involved pressing a button repeatedly to cycle through all its possible values, in order. For example:
#
# * Pressing the button 7 repeatedly will cycle through the letters P -> Q -> R -> S -> 7 -> P -> ....
# * Pressing the button 0 is cycling through SPACE -> 0 -> SPACE -> 0 -> ....
# * Buttons with a single symbol on it just type this symbol.
#
# A character is "locked in" and inserted into the message once the user presses a different key or pauses for a short period of time (thus, no extra button presses are required beyond what is needed for each letter individually). For example:
#
# * To type a letter "R" you would press the 7 key three times (as the screen display for the current character cycles through P->Q->R->S->7).
# * To type in a digit 3, you would press the button 3 four times.
# * To type in the message "ABC", you would press the button 2 once, wait a second, then press the button 2 twice to enter the letter B, then pause for another second, and press the button 2 three times, to enter the letter C. You would have to press the button 2 six times in total.
#
# In order to send the message "WHERE DO U WANT 2 MEET L8R" a teen would have to actually do 47 button presses.  No wonder they abbreviated...
#
# For this assignment, write code that can calculate the amount of button presses required for any phrase, with the following requirements:
# - Punctuation can be ignored for this exercise.
# - Likewise, the phone doesn't distinguish between upper and lowercase characters (but you should allow your module to accept input in either form, for convenience).
# - Tested phrases contain letters (A-Z and a-z), digits (0-9), and special characters # and *.

#!/bin/bash
s="$1"

upper=$(echo "$s" | tr '[:lower:]' '[:upper:]')

presses_for() {
    local c="$1"
    case "$c" in
        1) echo 1 ;;
        A|D|G|J|M|P|T|W) echo 1 ;;
        B|E|H|K|N|Q|U|X) echo 2 ;;
        C|F|I|L|O|R|V|Y) echo 3 ;;
        S|Z) echo 4 ;;
        0) echo 2 ;;
        ' ') echo 1 ;;
        2|3|4|5|6|8) echo 4 ;;
        7|9) echo 5 ;;
        '*') echo 1 ;;
        '#') echo 1 ;;
        *) echo 0 ;;
    esac
}

total=0
for ((i=0; i<${#upper}; i++)); do
    c="${upper:i:1}"
    n=$(presses_for "$c")
    total=$((total + n))
done

echo $total
