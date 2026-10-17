# Rot13
# https://www.codewars.com/kata/530e15517bc88ac656000716

# ROT13 is a simple letter substitution cipher that replaces a letter with the letter 13 letters after it in the alphabet. ROT13 is an example of the Caesar cipher.
#
# Create a function that takes a string and returns the string ciphered with Rot13.
#
# If there are nonletter characters in the string, they should be left as-is in the output. Only letters from the ASCII alphabet should be shifted, like in the original Rot13 "implementation".

var=$1
echo "$var" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
