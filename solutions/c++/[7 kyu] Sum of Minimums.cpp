// [7 kyu] Sum of Minimums!
// https://www.codewars.com/kata/5d5ee4c35162d9001af7d699
// Given a 2D ( nested ) list ( array, vector, .. ) of size m * n, your task is to find the sum of the minimum values in each row.
// So the function should return 26 because the sum of the minimums is 1 + 5 + 20 = 26.
// Note: You will always be given a non-empty list containing positive values.

#include <vector>

int sum_of_minimums(const std::vector<std::vector<int>> &numbers)
{
  int min = 100000, sum = 0;
  for (int i = 0; i < numbers.size(); i++) {
    for (int j = 0; j < numbers[i].size(); j++) {
      if (numbers[i][j] < min) min = numbers[i][j];
    }
    sum += min; min = 100000;
  }
    return sum;
}