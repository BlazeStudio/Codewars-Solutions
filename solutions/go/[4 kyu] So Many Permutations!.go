// So Many Permutations!
// https://www.codewars.com/kata/5254ca2719453dcc0b00027d

// In this kata, your task is to create all permutations of a non-empty input string and remove duplicates, if present.
//
// Create as many "shufflings" as you can!
//
// Examples:
// With input 'a':
// Your function should return: ['a']
//
// With input 'ab':
// Your function should return ['ab', 'ba']
//
// With input 'abc':
// Your function should return ['abc','acb','bac','bca','cab','cba']
//
// With input 'aabb':
// Your function should return ['aabb', 'abab', 'abba', 'baab', 'baba', 'bbaa']
//
// Note: The order of the permutations doesn't matter.
//
// Good luck!

package kata

func Permutations(s string) []string {
	if len(s) <= 1 {
		return []string{s}
	}

	seen := make(map[string]bool)
	var result []string

	for i := 0; i < len(s); i++ {
		rest := s[:i] + s[i+1:]
		for _, perm := range Permutations(rest) {
			candidate := string(s[i]) + perm
			if !seen[candidate] {
				seen[candidate] = true
				result = append(result, candidate)
			}
		}
	}

	return result
}
