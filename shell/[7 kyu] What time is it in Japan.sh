# What time is it in Japan ?
# https://www.codewars.com/kata/59c53183aeb2842585000116

# If you do business with people scattered all over the globe,
# you may want to know what time is it where they live before calling them.
#
# Your script should a one-liner which retun the current date and time in Japan,
#
# Date must be ISO-8601 compliant with up to minutes precision, like this:
# 2017-09-23T00:33+0900

TZ=Asia/Tokyo date +"%Y-%m-%dT%H:%M%z"
