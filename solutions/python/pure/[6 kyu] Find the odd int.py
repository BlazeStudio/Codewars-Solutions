# Find the odd int
# https://www.codewars.com/kata/54da5a58ea159efa38000836
#Given an array of integers, find the one that appears an odd number of times.

#There will always be only one integer that appears an odd number of times.

def find_it(seq):
    numbers = {}
    for i in seq:
        if i in numbers: numbers[i] += 1
        else: numbers[i] = 1
    result = [i for i in numbers if numbers[i] % 2 != 0]
    return result[0]
