# Sum of angles
# https://www.codewars.com/kata/5a03b3f6a1c9040084001765

# Find the total sum of internal angles (in degrees) in an n-sided simple polygon. N will be greater than 2.

#!/bin/bash
n=$1
echo $(( (n - 2) * 180 ))
