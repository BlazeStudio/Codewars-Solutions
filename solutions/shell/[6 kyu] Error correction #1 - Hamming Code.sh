# Error correction #1 - Hamming Code
# https://www.codewars.com/kata/5ef9ca8b76be6d001d5e1c3e

# Translations appreciated
#
# Background information
#
# The Hamming Code is used to correct errors, so-called bit flips, in data transmissions. Later in the description follows a detailed explanation of how it works.
#
# In this Kata we will implement the Hamming Code with bit length 3; this has some advantages and disadvantages:
# - [ + ] It's simple to implement
# - [ + ] Compared to other versions of hamming code, we can correct more mistakes
# - [ - ] The size of the input triples
#
# Task 1: Encode function
#
# Implement the encode function, using the following steps:
# * convert every letter of the text to its ASCII value; (ASCII value of space is 32)
# * convert ASCII values to 8-bit binary;
# * triple every bit;
# * concatenate the result;
#
# For example:
# input: "hey"
# --> 104, 101, 121                  // ASCII values
# --> 01101000, 01100101, 01111001   // binary
# --> 000111111000111000000000 000111111000000111000111 000111111111111000000111  // tripled
# --> "000111111000111000000000000111111000000111000111000111111111111000000111"  // concatenated
#
# Task 2: Decode function:
#
# Check if any errors happened and correct them. Errors will be only bit flips, and not a loss of bits:
#
# - 111 --> 101 : this can and will happen
# - 111 --> 11 : this cannot happen
#
# Note: the length of the input string is also always divisible by 24 so that you can convert it to an ASCII value.
#
# Steps:
#
# * Split the input into groups of three characters;
# * Check if an error occurred: replace each group with the character that occurs most often, e.g. 010 --> 0, 110 --> 1, etc;
# * Take each group of 8 characters and convert that binary number;
# * Convert the binary values to decimal (ASCII);
# * Convert the ASCII values to characters and concatenate the result
#
# For example:
# input: "100111111000111001000010000111111000000111001111000111110110111000010111"
# --> 100, 111, 111, 000, 111, 001, ...  // triples
# -->  0,   1,   1,   0,   1,   0,  ...  // corrected bits
# --> 01101000, 01100101, 01111001       // bytes
# --> 104, 101, 121                      // ASCII values
# --> "hey"
#
# In bash you get two arguments, first one is "encode" or "decode" whether you should encode or decode and the second argument is the plain text or the encoded bits.
#
# If you liked this kata, please try out some of my other katas:
#
# Crack the PIN
#
# Decode the QR-Code
#
# Hack the NSA

#!/bin/bash

if [ "$1" = "encode" ]; then
    text="$2"
    result=""

    for ((i=0; i<${#text}; i++)); do
        printf -v byte '%d' "'${text:i:1}"
        printf -v bits '%08d' "$(echo "obase=2; $byte" | bc)"

        for ((j=0; j<8; j++)); do
            bit="${bits:j:1}"
            result+="$bit$bit$bit"
        done
    done

    printf '%s' "$result"

else
    bits="$2"
    corrected=""

    for ((i=0; i<${#bits}; i+=3)); do
        group="${bits:i:3}"
        ones="${group//0/}"
        
        if [ "${#ones}" -ge 2 ]; then
            corrected+="1"
        else
            corrected+="0"
        fi
    done

    result=""

    for ((i=0; i<${#corrected}; i+=8)); do
        byte="${corrected:i:8}"
        value=$((2#$byte))
        printf -v char '%b' "$(printf '\\%03o' "$value")"
        result+="$char"
    done

    printf '%s' "$result"
fi
