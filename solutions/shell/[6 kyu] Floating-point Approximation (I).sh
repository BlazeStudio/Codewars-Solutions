# Floating-point Approximation (I)
# https://www.codewars.com/kata/58184387d14fc32f2b0012b2

# Consider the function
#
# f: x -> sqrt(1 + x) - 1 at x = 1e-15.
#
# We get:
# f(x) = 4.44089209850062616e-16
#
# or something around that, depending on the language.
#
# This function involves the subtraction of a pair of similar numbers when x is near 0
# and the results are significantly erroneous in this region. Using pow instead of sqrt
# doesn't give better results.
#
# A "good" answer is 4.99999999999999875... * 1e-16.
#
# Can you modify f(x) to give a good approximation of f(x) in the neighborhood of 0?
#
# Note:
#
# Don't round or truncate your results. See the testing function in Sample Tests:.

x="$1"

x_dec=$(printf "%.20f" "$x")

result=$(echo "scale=30; sqrt(1 + $x_dec) - 1" | bc -l)

small=$(echo "$x_dec < 0.00000001" | bc -l)
if [ "$small" = "1" ]; then
    result=$(echo "scale=30; $x_dec / (sqrt(1 + $x_dec) + 1)" | bc -l)
fi

result=$(printf "%.16e" "$result")

echo "$result"
