# Reverser
# https://www.codewars.com/kata/58069e4cf3c13ef3a6000168

# Impliment the reverse function, which takes in input n and reverses it. For instance, reverse(123) should return 321. You should do this without converting the inputted number into a string.
#
# # Please do not use anything from the following list:
# ['encode','decode','join','zfill','codecs','chr','bytes','ascii', 'substitute','template','bin', 'os','sys','re', '"', "'", 'str','repr', '%s', 'format', 'type', '__', '.keys','eval','exec','subprocess']
#
# // Please do not use
# const forbidden = "
#                   '
#                   `
#                   string
#                   fixed
#                   precision
#                   .keys

#!/bin/bash
n=$1
result=0
while [ $n -gt 0 ]; do
    result=$((result * 10 + n % 10))
    n=$((n / 10))
done
echo $result
