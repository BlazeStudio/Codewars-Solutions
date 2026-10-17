# Vigenère Cipher Helper
# https://www.codewars.com/kata/52d1bd3694d26f8d6e0000d3
# The Vigenère cipher is a classic cipher originally developed by Italian cryptographer Giovan Battista Bellaso and published in 1553. It is named after a later French cryptographer Blaise de Vigenère, who had developed a stronger autokey cipher (a cipher that incorporates the message of the text into the key).
#
# The cipher is easy to understand and implement, but survived three centuries of attempts to break it, earning it the nickname "le chiffre indéchiffrable" or "the indecipherable cipher."
#
# From Wikipedia:
#
# The Vigenère cipher is a method of encrypting alphabetic text by using a series of different Caesar ciphers based on the letters of a keyword. It is a simple form of polyalphabetic substitution.
#
# . . .
#
# In a Caesar cipher, each letter of the alphabet is shifted along some number of places; for example, in a Caesar cipher of shift 3, A would become D, B would become E, Y would become B and so on. The Vigenère cipher consists of several Caesar ciphers in sequence with different shift values.
#
# Assume the key is repeated for the length of the text, character by character. Note that some implementations repeat the key over characters only if they are part of the alphabet -- this is not the case here.
#
# The shift is derived by applying a Caesar shift to a character with the corresponding index of the key in the alphabet.


class VigenereCipher(object):
    def __init__(self, key, alphabet):
        self.key = key
        self.abc = alphabet
        self.table = self.create()

    def create(self):
        self.table = []
        abc = self.abc
        for i in range(len(self.abc)):
            self.table.append(abc)
            abc = abc[1:] + abc[:1]
        return self.table

    def encode(self, text):
        result = ""
        for i in range(len(text)):
            if text[i] not in self.abc:
                result += text[i]
            else:
                result += self.table[self.abc.index(text[i])][self.abc.index(self.key[i % len(self.key)])]
        return result

    def decode(self, text):
        result = ""
        for i in range(len(text)):
            if text[i] not in self.abc:
                result += text[i]
            else:
                result += self.abc[(self.table[self.abc.index(self.key[i % len(self.key)])].index(text[i]))]
        return result