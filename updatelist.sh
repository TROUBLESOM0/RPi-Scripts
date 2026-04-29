#!/bin/bash
# stores list in $file

# give up if packages are broken
[[ $(dpkg -l | grep ^..r) ]] && exit 0

# give up if there is a dependency problem
[[ "$((apt-get upgrade -s -qq) 2>&1)" == *"Unmet dependencies"* ]] && exit 0

file="/home/pi/scripts/updates.number"

# update procedure
DISTRO=$(lsb_release -c | cut -d ":" -f 2 |  tr -d '[:space:]') && DISTRO=${DISTRO,,}

# run around the packages
upgrades=0
security_upgrades=0
while IFS= read -r LINE; do
        # increment the upgrade counter
        (( upgrades++ ))
        # keep another count for security upgrades
        [[ ${LINE} == *"${DISTRO}-sec"* ]] && (( security_upgrades++ ))
done < <(apt-get upgrade -s -qq | sed -n '/^Inst/p')

cat >|${file} <<EOT
NUM_UPDATES="${upgrades}"
NUM_SECURITY_UPDATES="${security_upgrades}"
DATE="$(date +"%Y-%m-%d %H:%M")"
EOT

exit 0
