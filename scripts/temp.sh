#!/bin/bash
# displays cpu temperature
#/opt/vc/bin/vcgencmd measure_temp
cpu=$(/opt/vc/bin/vcgencmd measure_temp | awk -F "[=\']" '{print $2}')
cpuf=$(echo "(1.8 * $cpu) + 32" |bc)
echo "CPU_temp = $cpu'C ($cpuf'F)"
