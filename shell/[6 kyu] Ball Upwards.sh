# Ball Upwards
# https://www.codewars.com/kata/566be96bb3174e155300001b

# You throw a ball vertically upwards with an initial speed v0 (in km per hour).
#
# The height h of the ball at each time t is given by $\; h = v_0 \cdot t - 0.5 \cdot g \cdot t \cdot t \;$, where g is the Earth's gravity $( g \approx 9.81 \, m/s^2 )$.
#
# A device is recording at every tenth of second the height of the ball.
#
# For example, with v0 = 15 km/h, the device gets something of the following form:
# (0, 0.0), (1, 0.367...), (2, 0.637...), (3, 0.808...), (4, 0.881..) ...
# where the first number is the time in tenths of a second and the second number the height in meter.
#
# Task
#
# Write a function with a parameter v0 (in km per hour) that returns the time in tenth of second
# of the maximum height recorded by the device.
#
# Examples
#
# Given initial speed v0 = 15 --> should return 4
#
# Given initial speed v0 = 25 --> should return 7
#
# Notes
# - Remember to convert the velocity from km/h to m/s or from m/s to km/h when necessary.
# - The maximum height recorded by the device is not necessarily the maximum height reached by the ball.

#!/bin/bash
v0=$1

v0_ms=$(echo "scale=16; $v0 / 3.6" | bc -l)
g=9.81

t_peak=$(echo "scale=16; $v0_ms / $g" | bc -l)
t_peak_tenths=$(echo "scale=16; $t_peak * 10" | bc -l)

t_floor=$(echo "scale=0; $t_peak_tenths / 1" | bc -l)
t_ceil=$((t_floor + 1))

h_floor=$(echo "scale=16; $v0_ms * ($t_floor / 10) - 0.5 * $g * ($t_floor / 10) * ($t_floor / 10)" | bc -l)
h_ceil=$(echo "scale=16; $v0_ms * ($t_ceil / 10) - 0.5 * $g * ($t_ceil / 10) * ($t_ceil / 10)" | bc -l)

if [ "$(echo "$h_ceil > $h_floor" | bc -l)" = "1" ]; then
    echo $t_ceil
else
    echo $t_floor
fi
