# Count characters in your string
# https://www.codewars.com/kata/52efefcbcdf57161d4000091
# The main idea is to count all the occurring characters in a string. If you have a string like aba, then the result should be {'a': 2, 'b': 1}.
#
# What if the string is empty? Then the result should be empty object literal, {}.

def count(s):
    dict = {}
    for i in s:
        if i in dict: dict[i] += 1
        else: dict[i] = 1
    return dict