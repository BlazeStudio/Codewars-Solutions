# Next bigger number with the same digits
# https://www.codewars.com/kata/55983863da40caa2c900004e
# Create a function that takes a positive integer and returns the next bigger number that can be formed by rearranging its digits.

def next_bigger(num):
    digits = [int(d) for d in str(num)]
    n = len(digits)
    for i in range(n - 2, -1, -1):
        if digits[i] < digits[i + 1]:
            break
    else:
        return -1
    for j in range(n - 1, i, -1):
        if digits[j] > digits[i]:
            digits[i], digits[j] = digits[j], digits[i]
            break
    digits[i + 1:] = reversed(digits[i + 1:])

    result = int(''.join(map(str, digits)))
    return result if result != num else -1