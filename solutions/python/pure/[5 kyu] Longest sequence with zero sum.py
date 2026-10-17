# # Longest sequence with zero sum
# Write a method that takes an array of signed integers, and returns the longest contiguous subsequence of this array that has a total sum of elements of exactly 0.
#
# If more than one equally long subsequences have a zero sum, return the one starting at the highest index.

def max_zero_sequence(arr):
    max_length = 0
    result = []
    for i in range(len(arr)):
        current_sum = 0
        for j in range(i, len(arr)):
            current_sum += arr[j]
            if current_sum == 0 and j - i + 1 > max_length:
                max_length = j - i + 1
                result = arr[i:j + 1]
    return result