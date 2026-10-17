# Human readable duration format
# https://www.codewars.com/kata/52742f58faf5485cae000b9a
# Your task in order to complete this Kata is to write a function which formats a duration, given as a number of seconds, in a human-friendly way.

# The function must accept a non-negative integer. If it is zero, it just returns "now". Otherwise, the duration is expressed as a combination of years, days, hours, minutes and seconds.

# It is much easier to understand with an example:

# * For seconds = 62, your function should return 
#     "1 minute and 2 seconds"
# * For seconds = 3662, your function should return
#     "1 hour, 1 minute and 2 seconds"
# For the purpose of this Kata, a year is 365 days and a day is 24 hours.

# Note that spaces are important.

# Detailed rules
# The resulting expression is made of components like 4 seconds, 1 year, etc. In general, a positive integer and one of the valid units of time, separated by a space. The unit of time is used in plural if the integer is greater than 1.

# The components are separated by a comma and a space (", "). Except the last component, which is separated by " and ", just like it would be written in English.

# A more significant units of time will occur before than a least significant one. Therefore, 1 second and 1 year is not correct, but 1 year and 1 second is.

# Different components have different unit of times. So there is not repeated units like in 5 seconds and 1 second.

# A component will not appear at all if its value happens to be zero. Hence, 1 minute and 0 seconds is not valid, but it should be just 1 minute.

# A unit of time must be used "as much as possible". It means that the function should not return 61 seconds, but 1 minute and 1 second instead. Formally, the duration specified by of a component must not be greater than any valid more significant unit of time.

#!/bin/bash

function duration() {
  local total=$1

  if [ "$total" -eq 0 ]; then
    echo "now"
    return
  fi

  local years=$((total / 31536000))
  local days=$(((total % 31536000) / 86400))
  local hours=$(((total % 86400) / 3600))
  local minutes=$(((total % 3600) / 60))
  local seconds=$((total % 60))

  local parts=()

  if [ "$years" -gt 0 ]; then
    if [ "$years" -eq 1 ]; then parts+=("1 year"); else parts+=("$years years"); fi
  fi
  if [ "$days" -gt 0 ]; then
    if [ "$days" -eq 1 ]; then parts+=("1 day"); else parts+=("$days days"); fi
  fi
  if [ "$hours" -gt 0 ]; then
    if [ "$hours" -eq 1 ]; then parts+=("1 hour"); else parts+=("$hours hours"); fi
  fi
  if [ "$minutes" -gt 0 ]; then
    if [ "$minutes" -eq 1 ]; then parts+=("1 minute"); else parts+=("$minutes minutes"); fi
  fi
  if [ "$seconds" -gt 0 ]; then
    if [ "$seconds" -eq 1 ]; then parts+=("1 second"); else parts+=("$seconds seconds"); fi
  fi

  local n=${#parts[@]}
  if [ "$n" -eq 1 ]; then
    echo "${parts[0]}"
  elif [ "$n" -eq 2 ]; then
    echo "${parts[0]} and ${parts[1]}"
  else
    local result=""
    for ((i = 0; i < n - 2; i++)); do
      result+="${parts[i]}, "
    done
    result+="${parts[n - 2]} and ${parts[n - 1]}"
    echo "$result"
  fi
}

duration "$1"