# Return a CSV from a given directory
# https://www.codewars.com/kata/584d9264bd1606771b0000af

# Make a Function that returns a comma separated list in the order of
#
# "DirectoryName, Filename, FileExtension"

#!/bin/bash
path="$1"

dir=$(dirname "$path")
filename=$(basename "$path")
ext="${filename##*.}"
name="${filename%.*}"

echo "$dir, $name, $ext"
