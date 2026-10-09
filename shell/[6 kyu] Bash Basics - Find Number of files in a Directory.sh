# Bash Basics - Find Number of files in a Directory
# https://www.codewars.com/kata/584857c5a7878e993b0005cc

# Your task is to write a script that finds the number of type 'f' files in a given directory (argument 1) to stdout. If there is no arguments, print "Nothing to find".
#
# Examples:
#
# run_shell        --> prints: "Nothing to find"
# run_shell dir1         --> prints: "There are 5 files in /home/codewarrior/shell/dir1"
# run_shell doesNotExist --> prints: "Directory not found"

if [ -z "$1" ]; then
    echo "Nothing to find"
    exit 0
fi

if [ ! -d "$1" ]; then
    echo "Directory not found"
    exit 0
fi

count=$(find "$1" -maxdepth 1 -type f | wc -l)
abs_path=$(cd "$1" && pwd)
echo "There are $count files in $abs_path"
