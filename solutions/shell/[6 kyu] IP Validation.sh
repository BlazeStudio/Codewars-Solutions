# IP Validation
# https://www.codewars.com/kata/515decfd9dcfc23bb6000006

# Write an algorithm that will identify valid IPv4 addresses in dot-decimal format. IPs should be considered valid if they consist of four octets, with values between 0 and 255, inclusive.
#
# Valid inputs examples:
# Examples of valid inputs:
# 1.2.3.4
# 123.45.67.89
#
# Invalid input examples:
# 1.2.3
# 1.2.3.4.5
# 123.456.78.90
# 123.045.067.089
#
# Notes:
# - Leading zeros (e.g. 01.02.03.04) are considered invalid
# - Inputs are guaranteed to be a single string

adr="$1"

if [[ ! "$adr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "False"
    exit 0
fi

IFS='.' read -ra octets <<< "$adr"

if [ ${#octets[@]} -ne 4 ]; then
    echo "False"
    exit 0
fi

for octet in "${octets[@]}"; do
    if [ ${#octet} -gt 1 ] && [ "${octet:0:1}" = "0" ]; then
        echo "False"
        exit 0
    fi
    if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
        echo "False"
        exit 0
    fi
done

echo "True"
