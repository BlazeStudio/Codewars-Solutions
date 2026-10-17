# Bash Basics - Check for File Existence
# https://www.codewars.com/kata/582d7d22081ed3342d0000a7

# Write a BASH script which checks for a given file. If the file exists, print "Found \fileName\" to stdout, otherwise print "Can't find \fileName."
#
# If no arguments are supplied, print "Nothing to find"
#
# Examples:
# file exists:
# run_shell file1.txt --> "Found file1.txt"
#
# file doesn't exist:
# run_shell file1.txt --> "Can't find file1.txt"
#
# No arguments:
# run_shell --> "Nothing to find"
#
# Please note: the locate command is unavailable on Codewars.

#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Nothing to find"
    exit 0
fi

if [ -e "$1" ]; then
    echo "Found $1"
else
    echo "Can't find $1"
fi
