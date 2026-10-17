# Sum Strings as Numbers
#
# Given the string representations of two integers, return the string representation of the sum of those integers.

def sum_strings(x, y):
    x = x[::-1]
    y = y[::-1]
    if len(x) < len(y):
        x, y = y, x
    result = []
    carry = 0
    for i in range(len(x)):
        digit_x = int(x[i])
        digit_y = int(y[i]) if i < len(y) else 0
        total = digit_x + digit_y + carry
        result.append(str(total % 10))
        carry = total // 10
    if carry:
        result.append(str(carry))
    result = ''.join(result[::-1])
    result = result.lstrip('0')
    if not result:
        return '0'

    return result