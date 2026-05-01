#!/bin/bash
# displays cpu temperature
os_version=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f2)
if [[ $os_version = "buster" || $os_version = "bullseye" ]]
then
cpu=$(vcgencmd measure_temp | cut -d'=' -f2 | cut -d"'" -f1)
cpuf=$(echo "(1.8 * $cpu) + 32" |bc)
echo "CPU_temp = $cpu'C ($cpuf'F)"
elif [[ $os_version = "bookworm" ]]
then echo -e "OS Version: Bookworm (compatible)\n"
elif [[ $os_version = "" ]]
then echo "OS Version (not-found)"
else echo -e ""
fi
#/opt/vc/bin/vcgencmd measure_temp
#cpu=$(/opt/vc/bin/vcgencmd measure_temp | awk -F "[=\']" '{print $2}')
