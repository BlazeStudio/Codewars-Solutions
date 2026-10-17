// Roman Numerals Decoder
// https://www.codewars.com/kata/51b6249c4612257ac0000005
// Create a function that takes a Roman numeral as its argument and returns its value as a numeric decimal integer. You don't need to validate the form of the Roman numeral.

// Modern Roman numerals are written by expressing each decimal digit of the number to be encoded separately, starting with the leftmost digit and skipping any 0s. So 1990 is rendered "MCMXC" (1000 = M, 900 = CM, 90 = XC) and 2008 is rendered "MMVIII" (2000 = MM, 8 = VIII). The Roman numeral for 1666, "MDCLXVI", uses each letter in descending order.


#include <iostream>
#include <string>

using namespace std;

int solution(string roman) {
  int new_roman = 0, i = 0;
  int number = roman.size();
  while (i != number) {
//   for (int i = 0; number; i++) {
    if (roman[i] == 'I') new_roman += 1;
    if (roman[i] == 'V') new_roman += 5;
    if (roman[i] == 'X') new_roman += 10;
    if (roman[i] == 'L') new_roman += 50;
    if (roman[i] == 'C') new_roman += 100;
    if (roman[i] == 'D') new_roman += 500;
    if (roman[i] == 'M') new_roman += 1000;
    if ((roman[i - 1] == 'I') && (roman[i] != 'I')) new_roman -= 2;
    if ((roman[i - 1] == 'X') && (roman[i] != 'X') && (roman[i] != 'V') && (roman[i] != 'I')) new_roman -= 20;
    if ((roman[i - 1] == 'C') && (roman[i] != 'C') && ((roman[i] == 'D') || (roman[i] == 'M'))) new_roman -= 200;
    i++;
  }
  return new_roman;
}