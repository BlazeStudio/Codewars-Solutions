# Mumbling
# https://www.codewars.com/kata/5667e8f4e3f572a8f2000039

# This time no story, no theory. The examples below show you how to write function accum:

# The parameter of accum is a string which includes only letters from a..z and A..Z.

def accum(st):
    result, count = "", 0
    for i in st:
        count += 1
        result += i.upper() + i.lower() * (count - 1)
        if count != len(st): result += '-'
    return result