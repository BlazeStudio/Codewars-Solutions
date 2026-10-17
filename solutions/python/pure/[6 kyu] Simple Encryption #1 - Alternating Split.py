# Simple Encryption #1 - Alternating Split
# https://www.codewars.com/kata/57814d79a56c88e3e0000786
# Implement a pseudo-encryption algorithm which given a string S and an integer N concatenates all the odd-indexed characters of S with all the even-indexed characters of S, this process should be repeated N times.

import math

def decrypt(encrypted_text, n):
    answer = encrypted_text
    while n > 0:
        answer = ""
        for i in range(len(encrypted_text)):
            if i % 2 == 0: answer += encrypted_text[math.ceil((len(encrypted_text) - 1)/2) + math.ceil(len(answer) / 2)]
            else: answer += encrypted_text[len(answer) // 2]
        n -= 1
        encrypted_text = answer
    return answer


def encrypt(text, n):
    while n > 0:
        odds, evens = "", ""
        for i in range(len(text)):
            if i % 2 == 1: odds += text[i]
            else: evens += text[i]
        text = odds + evens
        n -= 1
    return text