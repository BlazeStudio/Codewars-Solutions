# Convert month name to number
# https://www.codewars.com/kata/58a2d1fdd7f6c7e51b000076

# Convert month name to number. First parameter - month, return this number.
#
# Example:
# stdin:Dec
# stdout:12
#
# stdin:Jan
# stdout:01
#
# stdin:APR
# stdout:04
#
# stdin:FeB
# stdout:02

#!/bin/bash
month="$1"

lower=$(echo "$month" | tr '[:upper:]' '[:lower:]')

case "$lower" in
    jan*|january) echo "01" ;;
    feb*|february) echo "02" ;;
    mar*|march) echo "03" ;;
    apr*|april) echo "04" ;;
    may) echo "05" ;;
    jun*|june) echo "06" ;;
    jul*|july) echo "07" ;;
    aug*|august) echo "08" ;;
    sep*|september) echo "09" ;;
    oct*|october) echo "10" ;;
    nov*|november) echo "11" ;;
    dec*|december) echo "12" ;;
esac
