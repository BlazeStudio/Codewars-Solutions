# Character with longest consecutive repetition
# https://www.codewars.com/kata/586d6cefbcc21eed7a001155

# For a given string s find the character c (or C) with longest consecutive repetition and return:
#
# # in Shell a String of comma-separated values
# c,l
#
# where l (or L) is the length of the repetition. If there are two or more characters with the same l return the first in order of appearance.
#
# For empty string return:
#
# ,0
#
# Happy coding! :)

s="$1"
if [ -z "$s" ]; then
    echo ",0"
    exit 0
fi

max_char="${s:0:1}"
max_count=1
cur_char="${s:0:1}"
cur_count=1

for ((i=1; i<${#s}; i++)); do
    c="${s:i:1}"
    if [ "$c" = "$cur_char" ]; then
        cur_count=$((cur_count + 1))
    else
        cur_char="$c"
        cur_count=1
    fi
    if [ $cur_count -gt $max_count ]; then
        max_count=$cur_count
        max_char="$cur_char"
    fi
done

echo "$max_char,$max_count"
