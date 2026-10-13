# A disguised sequence (I)
# https://www.codewars.com/kata/563f0c54a22b9345bf000053

# Given $u_0 = 1, u_1 = 2$
#
# And the relation $6 u_n u_{n+1} - 5 u_n u_{n+2} + u_{n+1} u_{n+2} = 0$
#
# Calculate $u_n$ for any integer $n \ge 0$.
#
# Examples:
#
# $n = 17, u_{17} = 131072$
#
# $n = 21, u_{21} = 2097152$
#
# Remark:
#
# You can take two points of view to do this kata:
#
# - the first one purely algorithmic from the definition of $u_n$
#
# - the second one - not at all mandatory, but as a complement - is to get a bit your head around and find which sequence is hidden behind $u_n$.

#!/bin/bash
n=$1
echo $((2 ** n))
