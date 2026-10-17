# Basics 08: Find next higher number with same Bits (1's)
# https://www.codewars.com/kata/56bdd0aec5dc03d7780010a5

# Your task is to find the next higher number (int) with the same number of bits set in its binaryt representation, i.e. as many 1 bits as before, but next higher than input. Input is always an int between 1 and 1<<30 (possibly inclusive). No bad cases or special tricks.
#
# Some easy examples:
#
# Input: 129    => Output: 130    (10000001 => 10000010)
# Input: 127    => Output: 191    (01111111 => 10111111)
# Input: 1      => Output: 2      (01 => 10)
# Input: 323423 => Output: 323439 (1001110111101011111 => 1001110111101101111)

n=$1

c=$n
c0=0
c1=0

while [ $((c & 1)) -eq 0 ] && [ $c -ne 0 ]; do
    c0=$((c0 + 1))
    c=$((c >> 1))
done

while [ $((c & 1)) -eq 1 ]; do
    c1=$((c1 + 1))
    c=$((c >> 1))
done

p=$((c0 + c1))
n=$((n | (1 << p)))
n=$((n & ~((1 << p) - 1)))
n=$((n | ((1 << (c1 - 1)) - 1)))

echo $n
