#!/bin/bash
#
# installs from inside /scripts/ folder
#
# activeservices,
# allpackages,
# allservices,
# hostip,
# matrix,
# makewebserver
# systemctlenabled,
# temp,
# usergrp,
#
#
### Scripts to Install ###
# a-j  [NOTE: CAN'T USE "i"]
# when adding more, must update /COPY scripts/ function
a=activeservices.list
b=allpackages.list
c=allservices.list
d=hostip.list
e=makewebserver
f=matrix.sh
g=systemctlenabled.list
h=temp.sh
j=usergrp.list
#
# this is what you want to call it in /bin/
a1=activeservices
b1=allpackages
c1=allservices
d1=hostip
e1=makewebserver
f1=matrix
g1=systemctlenabled
h1=temp
j1=usergrp
#############################################
### sets sleep functions ###
s () { sleep .5; }
s1 () { sleep 1; }
s2 () { sleep 2; }
s3 () { sleep 3; }
s4 () { sleep 4; }
s5 () { sleep 5; }
#
#############################################
### variables for current date ###
currentDate=$(date "+%m-%d-%Y")
repeatDate=$(date "+%m-%d-%Y.%T")
#
#############################################
### variables for files/directories ###
dir=`pwd`
userHome=$(eval echo "~$SUDO_USER")
scripts=$userHome/scripts
bin=/bin/
gitDir="RPi-Scripts-Scripts"
scriptsDir="RPI-Scripts"
gitDL="Scripts.zip"
gitLink=$(curl -s https://api.github.com/repos/TROUBLESOM0/RPi-Scripts/releases/latest | grep "zipball_url" | cut -d '"' -f 4)
# #FOR TESTING ONLY# gitLink=~/Public/Scripts.zip
#
#############################################
###            repeat characters          ###
# example: char_repeat 25 "-"
# repeats "-" 25 times
function char_repeat() {
count="$1"
char="$2"
for (( i=0; i < $count; ++i ))
do printf "$char"
done
echo
}
#
#############################################
###              delay dots               ###
function dot_delay() {
for (( i=0; i < 25; ++i ))
do printf "."
  sleep .1
done
echo
}
#
#
#############################################
#              Begin Script                 #
#############################################
echo "Checking if files are present in '$dir/$scriptsDir'"
sleep 5
dot_delay
char_repeat 20 "-"

# loop thru variables a-z
for var in {a..z}
do
val="${!var}"
#skip if empty or i
[[ -z "$val" || "$var" == "i" ]] && continue
if [[ -f $dir/$scriptsDir/$val ]]
then echo "$val"
else echo "'$val' missing"
fi
done

echo "This will set permissions and install "

s2
### MOVING INTO ~/scripts
#list=`ls -1`
char_repeat 25 "."
for char in {a..z}
do
[[ "$char" == "i" ]] && continue
value="${!char}"
if [ -n "$value" ]
then echo "$value"
fi
done
dot_delay
echo " scripts into '$bin'"
dot_delay
s5
echo "Setting permissions and installing into '$bin'"
s1

# loop thru variables a-z
for var in {a..z}
do
val="${!var}"
#skip if empty or i
[[ -z "$val" || "$var" == "i" ]] && continue
chmod u+rwx,g+rwx,o+r $scripts/$val
done
#chmod u+rwx,g+rwx,o+r $scripts/$a $scripts/$b $scripts/$c $scripts/$d $scripts/$e $scripts/$f $scripts/$g $scripts/$h $scripts/$j

# loop thru variables a1-z1
for var in {a..z}
do
varname="${var}1"
val="${!varname}"
#skip if empty or i
[[ -z "$val" || "$var" == "i" ]] && continue
if [[ -f $bin$val ]]
then echo "Replacing '$bin/$val'"
sudo rm $bin$val
echo "removed '$val'"
else dot_delay
fi
done

echo "Linking......."
# loop thru variables a1-z1
for char in {a..z}
do
[[ "$char" == "i" ]] && continue
src_name="${!char}"
var_link_name="${char}1"
link_name="${!var_link_name}"
if [[ -n "$src_name" && -n "$link_name" ]]
then echo "Linking $src_name to $link_name..."
sudo ln -s "$scripts/$src_name" "$bin$link_name"
fi
done

dot_delay & dot_delay & dot_delay
echo "Linking Complete"
echo "All scripts installed"

#echo "activeservices\n allpackages\n allservices\n hostip\n matrix\n makewebserver\n systemctlenabled\n temp\n usergrp\n "
#echo "----------------------------------------------------"
#sudo chmod u+rwx,g+rwx,o+r activeservices.list allpackages.list allservices.list hostip.list matrix.sh makewebserver systemctlenabled.list temp.sh usergrp.list sudo ln -s ~/scripts/activeservices.list /bin/activeservices && sudo ln -s ~/scripts/allpackages.list /bin/allpackages && sudo ln -s ~/scripts/allservices.list /bin/allservices && sudo ln -s ~/scripts/hostip.list /bin/hostip && sudo ln -s ~/scripts/matrix.sh /bin/matrix && sudo ln -s ~/scripts/makewebserver /bin/makewebserver && sudo ln -s ~/scripts/systemctlenabled.list /bin/systemctlenabled && sudo ln -s ~/scripts/temp.sh /bin/temp && sudo ln -s ~/scripts/usergrp.list /bin/usergrp
#echo "All scripts installed"
