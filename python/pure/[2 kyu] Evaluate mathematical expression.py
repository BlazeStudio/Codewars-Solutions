# Evaluate mathematical expression
# https://www.codewars.com/kata/52a78825cdfc2cfc87000005

# Instructions
#
# Given a mathematical expression as a string you must return the result as a number.
#
# Numbers
#
# Number may be both whole numbers and/or decimal numbers. The same goes for the returned result.
#
# Operators
#
# You need to support the following mathematical operators:
#
# * Multiplication *
# * Division / (as floating point division)
# * Addition +
# * Subtraction -
#
# Operators are always evaluated from left-to-right, and * and / must be evaluated before + and -.
#
# Parentheses
#
# You need to support multiple levels of nested parentheses, ex. (2 / (2 + 3.33) * 4) - -6
#
# Whitespace
#
# There may or may not be whitespace between numbers and operators.
#
# An addition to this rule is that the minus sign (-) used for negating numbers and parentheses will never be separated by whitespace. I.e all of the following are valid expressions.
#
# 1-1    // 0
# 1 -1   // 0
# 1- 1   // 0
# 1 - 1  // 0
# 1- -1  // 2
# 1 - -1 // 2
# 1--1   // 2
#
# 6 + -(4)   // 2
# 6 + -( -4) // 10
#
# And the following are invalid expressions
#
# 1 - - 1    // Invalid
# 1- - 1     // Invalid
# 6 + - (4)  // Invalid
# 6 + -(- 4) // Invalid
#
# Validation
#
# You do not need to worry about validation - you will only receive valid mathematical expressions following the above rules.
#
# Restricted APIs
#
# NOTE: eval and exec are disallowed in your solution.

def calc(expression):
    tokens = tokenize(expression)
    pos = [0]
    result = parse_expr(tokens, pos)
    return result


def tokenize(s):
    tokens = []
    i = 0
    n = len(s)
    while i < n:
        c = s[i]
        if c == ' ':
            i += 1
            continue
        if c in '+-*/()':
            # handle unary minus
            if c == '-' and (not tokens or tokens[-1] in '+-*/('):
                # start of a number (possibly negative)
                j = i + 1
                while j < n and s[j] == ' ':
                    j += 1
                # could be unary minus applied to a number or '('
                if j < n and s[j] == '(':
                    tokens.append('u-')
                    i += 1
                    continue
                # parse number with sign
                num = '-'
                j = i + 1
                while j < n and s[j] == ' ':
                    j += 1
                while j < n and (s[j].isdigit() or s[j] == '.'):
                    num += s[j]
                    j += 1
                tokens.append(num)
                i = j
                continue
            tokens.append(c)
            i += 1
        elif c.isdigit() or c == '.':
            j = i
            num = ''
            while j < n and (s[j].isdigit() or s[j] == '.'):
                num += s[j]
                j += 1
            tokens.append(num)
            i = j
        else:
            i += 1
    return tokens


def parse_expr(tokens, pos):
    result = parse_term(tokens, pos)
    while pos[0] < len(tokens) and tokens[pos[0]] in '+-':
        op = tokens[pos[0]]
        pos[0] += 1
        rhs = parse_term(tokens, pos)
        if op == '+':
            result += rhs
        else:
            result -= rhs
    return result


def parse_term(tokens, pos):
    result = parse_factor(tokens, pos)
    while pos[0] < len(tokens) and tokens[pos[0]] in '*/':
        op = tokens[pos[0]]
        pos[0] += 1
        rhs = parse_factor(tokens, pos)
        if op == '*':
            result *= rhs
        else:
            result /= rhs
    return result


def parse_factor(tokens, pos):
    tok = tokens[pos[0]]
    if tok == 'u-':
        pos[0] += 1
        return -parse_factor(tokens, pos)
    if tok == '(':
        pos[0] += 1
        result = parse_expr(tokens, pos)
        pos[0] += 1  # skip ')'
        return result
    pos[0] += 1
    return float(tok)
