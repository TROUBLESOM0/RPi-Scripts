#!/bin/bash
#
# v4.3.9
#
# Command to download Raspberry Pi Scripts package
#
### Scripts to Install ###
# a-j  [NOTE: CAN'T USE "i"]
# when adding more, must update /COPY scripts/ function
# **** MOVED TO EXTERNAL SCRIPT (install-[num]-lists.sh) ****

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
gitLink=$(curl -sS https://api.github.com/repos/TROUBLESOM0/RPi-Scripts/releases/latest | grep "zipball_url" | cut -d '"' -f 4)
DLscript="Scripts_Install.sh"
motd_file="90-script"
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
########################
###   INSTALL_MOTD   ###
########################
install_MOTD () {
read -r -p "Do you want to install 90-script to MOTD?" input_motd
if [[ "${input_motd,,}" == "y" || "${input_motd,,}" == "yes" ]]
then :
else return 0
fi
if [[ -f $scripts/$motd_file ]]
then echo "Installing MOTD..."
else echo -e "${Error}ERROR${Off} Unable to find $motd_file. Not installing MOTD."
return 0
fi
if [[ -d /etc/update-motd.d ]]
then :
else echo -e "${Error}ERROR${Off} update-motd.d not found."
return 0
fi
mv $scripts/$motd_file /etc/update-motd.d/$motd_file
chown root:root /etc/update-motd.d/$motd_file
chmod 755 /etc/update-motd.d/$motd_file
}
#
############################
###   ASK_INSTALLUNZIP   ###
############################
ask_Installunzip () {
while true
do
read -r -p "Do You Want To Install Unzip? [Y/n]" ask_unzip_input
case $ask_unzip_input in
[yY][eE][sS]|[yY])
echo "Installing unzip"
s
sudo apt install unzip -y -qq > /dev/null
s
if type unzip &>/dev/null
then :
else
echo "unzip installation failed. Try installing manually with sudo apt install unzip"
exit 1
fi
break
;;
[nN][oO]|[nN])
echo "Install Cancelled"
break
;;
*)
echo "Must enter [Y/n]"
s
exit 0
;;
esac
done
}
#
###########################
###   ASK_INSTALLCURL   ###
###########################
ask_Installcurl () {
while true
do
read -r -p "Do You Want To Install Curl? [Y/n]" ask_curl_input
case $ask_curl_input in
[yY][eE][sS]|[yY])
echo "Installing curl"
s
sudo apt install curl -y -qq > /dev/null
s
if type curl &>/dev/null
then :
else
echo "curl installation failed. Try installing manually with sudo apt install curl"
exit 1
fi
break
;;
[nN][oO]|[nN])
echo "Install Cancelled"
break
;;
*)
echo "Must enter [Y/n]"
s
exit 0
;;
esac
done
}
#
#############################################
###                 UNZIP                 ###
#############################################
ask_Unzip () {
if test -d $scriptsDir
then mv $scriptsDir/ bkup_$scriptsDir.$repeatDate/
else echo "'$scriptsDir' doesn't exist... Unzipping '$gitDL'"
dot_delay
fi
if test -f $gitDL
then
unzip -qq -o $gitDL && mv $gitDir $scriptsDir
echo "Scripts unzipped to '$scriptsDir'."
s
else echo "ERROR: $gitDL doesn't exist."
fi
while test -d $scriptsDir
do
read -r -p "Do you want to delete the .zip file?" del_zip
case $del_zip in
[yY][eE][sS]|[yY])
rm $gitDL
s1
echo "Deleted Scripts.zip"
s3
#cp_Scripts
break
;;
[nN][oO]|[nN])
echo "Keeping Scripts.zip"
chown $SUDO_USER:$SUDO_USER $gitDL
#cp_Scripts
break
;;
*)
echo "Must enter [Y/n]"
s
;;
esac
done
}
############################################
###               DOWNLOAD               ###
############################################
ask_DL () {
while true
do
read -r -p "Ready to download? [Y/n]" dl_input
case $dl_input in
[yY][eE][sS]|[yY])
echo "Downloading $gitDL"
s1
wget -qq --timeout=20 --tries=3 -O $gitDL $gitLink
# #FOR TESTING ONLY# cp $gitLink $dir
s1
if test -f $gitDL
then char_repeat 25 "-"
echo "Download successful"
char_repeat 25 "-"
mkdir tmpDir
unzip -qq $gitDL -d tmpDir/
rm $gitDL
mkdir $gitDir && mv tmpDir/*/* $gitDir/
rm -r tmpDir
zip -qq -r $gitDL $gitDir/
rm -r $gitDir
#ask_Unzip
else echo "Error downloading"
fi
break
;;
[nN][oO]|[nN])
echo "Download Cancelled"
exit 0
;;
*)
echo "Must enter [Y/n]"
s
;;
esac
done
}
#############################################
###                REPLACE                ###
#############################################
ask_Replace () {
while true
do
read -r -p "Do you want to replace $gitDL?" rep_input
case $rep_input in
[yY][eE][sS]|[yY])
echo "Backing up $gitDL"
echo $currentDate
if test -f bkup_Scripts-$currentDate.zip
then cp $gitDL bkup_Scripts-$repeatDate.zip
else cp $gitDL bkup_Scripts-$currentDate.zip
chown $SUDO_USER:$SUDO_USER bkup_Scripts*
fi
rm $gitDL
s3
echo "Downloading Scripts"
wget -q --timeout=20 --tries=3 $gitLink
#wget "http://10.10.10.5:8000/Scripts"
s1
if test -f $gitDL
then char_repeat 25 "-"
echo "Download successful."
char_repeat 25 "-"
#ask_Unzip
else echo "Error Downloading"
fi
break
;;
[nN][oO]|[nN])
echo "END"
break
;;
*)
echo "Must enter [Y/n]"
s
;;
esac
done
}

#############################################
###                 COPY                  ###
#############################################
cp_Scripts () {
if [[ ! -d $scripts ]]
then mkdir $scripts
echo "scripts dir didn't exist so was created at '$scripts'"
s5
dot_delay
else echo "$scripts exists... creating backup"
cp -r $scripts $dir/bkup_scripts-$repeatDate
chown $SUDO_USER:$SUDO_USER $dir/bkup_scripts*
s5
dot_delay
echo "'$scripts' backed up to '$dir/bkup-scripts-$repeatDate'"
fi

#if [[ -f $dir/$scriptsDir/$a && -f $dir/$scriptsDir/$b && -f $dir/$scriptsDir/$c && -f $dir/$scriptsDir/$d && -f $dir/$scriptsDir/$e && -f $dir/$scriptsDir/$f && -f $dir/$scriptsDir/$g && -f $dir/$scriptsDir/$h && -f $dir/$scriptsDir/$j ]]
#then echo "All script files present. Ready to install scripts"
echo "Copying files to '$scripts'"
cp $dir/$scriptsDir/* $scripts
#s1
#dot_delay
#install_Scripts
#else echo "Missing script files in $dir/$scriptsDir"
#s5
#fi
}
#############################################
###                INSTALL                ###
#############################################
#
# installs from inside /scripts/ folder
# View install-[number]-lists.sh for scripts to be installed
#
install_Scripts () {

echo "Searching for install file (install-[]-lists.sh)..."
# array if more than 1 file
file_array=()
while IFS= read -r -d $'\0' file
do
file_array+=("$file")
done < <(find "$userHome/scripts" -maxdepth 1 -name "install-*-lists.sh" -print0)

# check results
if [ ${#file_array[@]} -eq 0 ]
then echo -e "${Error}+++ERROR:${Off}No install-*-lists.sh file found."
exit 1
fi

# single vs multiple files option
if [ ${#file_array[@]} -eq 1 ]
then S_FILE="${file_array[0]}"
printf "Found: %s\n" "$(basename "$S_FILE")"
else printf "Multiple versions found. Select one:\n"
PS3="Choice: "

# Show only the filenames (basename) in the menu
select opt in "${file_array[@]}"
do
  if [ -n "$opt" ]
  then S_FILE="$opt"
  break
  else
  printf "Invalid choice.\n"
  fi
done
fi

echo "Using $S_FILE"

if [ -f $S_FILE ]
then bash $S_FILE
else echo "ERROR:  Unable to locate install-[number]-lists.sh"
exit 1
fi
}

######################
#      CLEAN_UP      #
######################
clean_Up () {
scriptsOwn=$(stat -c %U $scripts)
echo -e "\nCleaning up and setting permissions"

if [ "$scriptsOwn" != "$SUDO_USER" ]
then echo "..changing $scripts ownership to $SUDO_USER..."
chown -R $SUDO_USER:$SUDO_USER $scripts
else :
fi

if [ -d $dir/$scriptsDir ]
then rm -rf $dir/$scriptsDir
fi
if [ -f $dir/$DLscript ]
then rm -f $dir/$DLscript
fi
}
############################
#      Initial Checks      #
############################
echo "Downloads Raspberry Pi Scripts zip into current folder : '$dir'"
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
fi
#
# Check if unzip is installed
if type unzip &>/dev/null
then : # continues script
else
echo "ERROR unzip is not installed"
ask_Installunzip
echo "unzip install complete"
fi
#
# Check if curl is installed
if type curl &>/dev/null
then : # continues script
else
echo "ERROR curl is not installed"
ask_Installcurl
echo "curl install complete"
fi
#
#############################################
#              Begin Script                 #
#############################################
if test -f $gitDL
then echo "$gitDL file already exists"
s1
ask_Replace
ask_Unzip
cp_Scripts
install_Scripts
else ask_DL
ask_Unzip
cp_Scripts
install_Scripts
fi
install_MOTD
clean_Up
echo "ENDING"
#########################################
exit 0
