// Longest Palindromic Substring (Linear)
// https://www.codewars.com/kata/5dcde0b9fcb0d100349cb5c0

// Longest Palindromic Substring (Linear)
// A palindrome is a word, phrase, or sequence that reads the same backward as forward, e.g., 'madam' or 'racecar'. Even the letter 'x' is considered a palindrome.

// For this Kata, you are given a string s. Write a function that returns the longest contiguous palindromic substring in s (it could be the entire string). In the event that there are multiple longest palindromic substrings, return the first to occur.

// I'm not trying to trick you here:

// You can assume that all inputs are valid strings.
// Only the letters a-z will be used, all lowercase (your solution should, in theory, extend to more than just the letters a-z though).
// NOTE: Quadratic asymptotic complexity (O(N^2)) or above will NOT work here.

// Examples
// Basic Tests
// Input: "babad"
// Output: "bab"
// (Note: "bab" occurs before "aba")
// Input: "abababa"
// Output: "abababa"
// Input: "cbbd"
// Output: "bb"
// Edge Cases
// Input: "ab"
// Output: "a"
// Input: ""
// Output: ""
// Testing
// Along with the example tests given:

// There are 500 tests using strings of length in range [1 - 1,000]
// There are 50 tests using strings of length in range [1,000 - 10,000]
// There are 5 tests using strings of length in range [10,000 - 100,000]
// All test cases can be passed within 10 seconds, but non-linear solutions will time out every time. Linear performance is essential.

// Good Luck!
// This problem was inspired by this challenge on LeetCode. Except this is the performance version :^)

package kata

func LongestPalindrome(s string) string {
	n := len(s)
	if n == 0 {
		return ""
	}
	t := make([]byte, 2*n+3)
	t[0] = '^'
	for i := 0; i < n; i++ {
		t[2*i+1] = '#'
		t[2*i+2] = s[i]
	}
	t[2*n+1] = '#'
	t[2*n+2] = '$'
	m := len(t)

	p := make([]int, m)
	center, right := 0, 0
	maxLen, maxCenter := 0, 0

	for i := 1; i < m-1; i++ {
		if i < right {
			mirror := 2*center - i
			p[i] = min(right-i, p[mirror])
		}
		for t[i+p[i]+1] == t[i-p[i]-1] {
			p[i]++
		}
		if i+p[i] > right {
			center = i
			right = i + p[i]
		}
		if p[i] > maxLen {
			maxLen = p[i]
			maxCenter = i
		}
	}

	start := (maxCenter - maxLen) / 2
	return s[start : start+maxLen]
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}