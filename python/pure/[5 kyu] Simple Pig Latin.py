# Simple Pig Latin
# https://www.codewars.com/kata/520b9d2ad5c005041100000f

# Move the first letter of each word to the end of it, then add "ay" to the end of the word. Leave punctuation marks untouched.

def pig_it(text):
	text = text.split(' ')
	result = []
	for i in text:
		if i.isalpha(): result.append(i[1:] + i[:1] + 'ay')
		else: result.append(i)
	return ' '.join(result)