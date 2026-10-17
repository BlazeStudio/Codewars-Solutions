// Alternate capitalization
// https://www.codewars.com/kata/59cfc000aeb2844d16000075
//Given a string, capitalize the letters that occupy even indexes and odd indexes separately, and return as shown below. Index 0 will be considered even.

//For example, capitalize("abcdef") = ['AbCdEf', 'aBcDeF']. See test cases for more examples.

//The input will be a lowercase string with no spaces.

#include <string>
#include <cctype>

using namespace std;

std::pair<std::string, std::string> capitalize(const std::string &s)
{
    int number = s.size(), i = 0;
    string low_let, up_let;
    while (i != number) {
        if (i % 2 == 0) {
          low_let += toupper(s[i]);
          up_let += tolower(s[i]);
        }
        else {
          low_let += tolower(s[i]);
          up_let += toupper(s[i]);
        }
        i++;
    }
    return {low_let, up_let};
}