// Split Strings
// https://www.codewars.com/kata/515de9ae9dcfc28eb6000001

// Complete the solution so that it splits the string into strings of two characters in a list/array (depending on the language you use). If the string contains an odd number of characters then it should replace the missing second character of the final pair with an underscore ('_').
//
// Examples:
// * 'abc' =>  ['ab', 'c_']
// * 'abcdef' => ['ab', 'cd', 'ef']

package kata

func Solution(str string) []string {
	n := len(str)
	res := make([]string, 0, (n+1)/2)
	for i := 0; i < n; i += 2 {
		if i+1 < n {
			res = append(res, str[i:i+2])
		} else {
			res = append(res, string(str[i])+"_")
		}
	}
	return res
}
