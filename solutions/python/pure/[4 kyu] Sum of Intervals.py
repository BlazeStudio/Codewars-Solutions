# Sum of Intervals
# https://www.codewars.com/kata/52b7ed099cdc285c300001cd

#Write a function called sumIntervals/sum_intervals that accepts an array of intervals, and returns the sum of all the interval lengths. Overlapping intervals should only be counted once.

#Intervals
#Intervals are represented by a pair of integers in the form of an array. The first value of the interval will always be less than the second value. Interval example: [1, 5] is an interval from 1 to 5. The length of this interval is 4.


#Tests with large intervals
#Your algorithm should be able to handle large intervals. All tested intervals are subsets of the range [-1000000000, 1000000000].

def sum_of_intervals(intervals):
    intervals.sort(key=lambda x: x[0])
    total_length = 0
    current_interval = intervals[0]
    for interval in intervals[1:]:
        if interval[0] <= current_interval[1]:
            current_interval = (current_interval[0], max(current_interval[1], interval[1]))
        else:
            total_length += current_interval[1] - current_interval[0]
            current_interval = interval
    total_length += current_interval[1] - current_interval[0]
    return total_length