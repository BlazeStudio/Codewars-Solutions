# Unique In Order
# https://www.codewars.com/kata/54e6533c92449cc251001667

#Implement the function unique_in_order which takes as argument a sequence and returns a list of items without any elements with the same value next to each other and preserving the original order of elements.

def unique_in_order(sequence):
    result = []
    for i in range(len(sequence)):
	    if (sequence[i] != sequence[i-1]) or (len(result) == 0):
		    result.append(sequence[i])
    return result