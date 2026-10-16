# Return the latest modified file
# https://www.codewars.com/kata/59bfe5f15227ddf81900007b

# Write a script which return the latest modified file.
#
# For example, if the following files are in the current directory:
#
#     poem.txt
#     article.txt
#     quotes.txt
#
# and the latest edited file was article.txt then the following should be returned:
#
#     article.txt
#
# Note: The files will be in the current directory.

ls -t | head -1
