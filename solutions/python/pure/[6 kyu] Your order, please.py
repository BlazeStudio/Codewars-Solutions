# Your order, please
# https://www.codewars.com/kata/55c45be3b2079eccff00010f
# Your task is to sort a given string. Each word in the string will contain a single number. This number is the position the word should have in the result.
#
# Note: Numbers can be from 1 to 9. So 1 will be the first word (not 0).
#
# If the input string is empty, return an empty string. The words in the input String will only contain valid consecutive numbers.

def order(sentence):
    sentence = sentence.split(' ')
    test = []
    test = sentence.copy()
    for i in sentence:
        for char in i:
            if char.isdigit():
                test[int(char) - 1] = i
    return ' '.join(test)