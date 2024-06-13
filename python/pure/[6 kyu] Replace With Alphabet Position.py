# Replace With Alphabet Position
# https://www.codewars.com/kata/546f922b54af40e1e90001da

#Welcome.

# In this kata you are required to, given a string, replace every letter with its position in the alphabet.
#
# If anything in the text isn't a letter, ignore it and don't return it.
#
# "a" = 1, "b" = 2, etc.

import string
def alphabet_position(text):
    result = ""
    string.ascii_lowercase
    alphabet = list(string.ascii_lowercase)
    for i in text:
        if i.lower() in alphabet:
            if result == "":
                result += str(alphabet.index(i.lower()) + 1)
            else:
                result += " " + str(alphabet.index(i.lower()) + 1)
    return result