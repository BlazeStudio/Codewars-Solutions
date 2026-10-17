# Break camelCase
# https://www.codewars.com/kata/5208f99aee097e6552000148
# Complete the solution so that the function will break up camel casing, using a space between words.

def solution(s):
    j = ""
    for i in enumerate(s):
        if len(j) == 0: size = 0; ratio = 1;
        if i[1].isupper(): j += s[:i[0] - size] + ' '; s = s[i[0] - size:]; size = len(j) - ratio; ratio += 1
    j += s
    return j