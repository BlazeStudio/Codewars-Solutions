# Magnet particules in boxes
# https://www.codewars.com/kata/56c04261c3fcf33f2d000534

# Professor Chambouliard hast just discovered a new type of magnet material. He put particles of this material in a box made of small boxes arranged
# in K rows and N columns as a kind of 2D matrix K x N where K and N are postive integers.
# He thinks that his calculations show that the force exerted by the particle in the small box (k, n) is:
#
# \displaystyle  v(k,n) = \dfrac{1}{k(n+1)^{2k}}
# The total force exerted by the first row with k = 1 is:
#
# \displaystyle u(1, N) = \sum_{n=1}^{n=N}v(1, n) = \dfrac{1}{1 \cdot 2^2}+\dfrac{1}{1\cdot 3^2} + \dots + \frac{1}{1 \cdot (N+1)^2}
#
# We can go on with k = 2 and then k = 3 etc ... and consider:
#
# \displaystyle S(K, N) = \sum_{k=1}^{k=K} u(k, N) = \sum_{k=1}^{k=K} \bigg(\sum_{n=1}^{n=N} v(k, n) \bigg) \to(double(max_k, max_n))
#
# Task:
# To help Professor Chambouliard can we calculate the function doubles that will take as parameter maxk and maxn such that doubles(maxk, maxn) = S(maxk, maxn)?
# Experiences seems to show that this could be something around 0.7 when maxk and maxn are big enough.
#
# Examples:
# doubles(1, 3)  => 0.4236111111111111
# doubles(1, 10) => 0.5580321939764581
# doubles(10, 100) => 0.6832948559787737
# Notes:
# - In u(1, N) the dot is the multiplication operator.
# - Don't truncate or round: Have a look at the testing function in "Sample Tests".
# - link to symbol Sigma (https://en.wikipedia.org/wiki/Summation)

#!/bin/bash
maxk=$1
maxn=$2
awk -v maxk="$maxk" -v maxn="$maxn" '
BEGIN {
  s = 0.0
  for (k = 1; k <= maxk; k++) {
    for (n = 1; n <= maxn; n++) {
      s += 1.0 / (k * exp((2 * k) * log(n + 1)))
    }
  }
  printf "%.20g\n", s
}
'
