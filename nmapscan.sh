#!/bin/bash
# nmapscan.sh v2.2
# Send email with msmtp
# Below is the script used to actually send email
# echo -e "Subject: Your Subject Here\n\nBody of Email Here" | msmtp -a [From Email config in msmtprc] [To Email]
#
# [NOTICE]
#  There is some configuration to be setup with the msmtp email server and msmtp-mta
#  1) You will have to configure /etc/msmtprc prior to running msmtp
#  2) You will have to authenticate with a SMTP server to use this program to send emails
#  3) Must set "_to" and "_from" variables below
#
#
##########################
###     TO and FROM    ###
##########################
_to="email@email.com"  # who to send to
_from="gmail"  # who to send from (configured in msmtprc)
#
#
#########################
### GENERIC VARIABLES ###
#########################
_host=$HOSTNAME
dir=`pwd`
tempdir="Temp-Install-nmapscan"
#bin=/bin/
depends1=nmap
depends2=msmtp
depends3=msmtp-mta
depends4=msmtprc
_PROGRAM=nmapscan
#
## sets date and time
_D=$(date +"%m-%d-%Y")
_T=$(date +"%H:%M")
#
#################################
#           FUNCTIONS           #
#################################
#
### sets sleep functions ###
s () { sleep .5; }
s1 () { sleep 1; }
s2 () { sleep 2; }
s3 () { sleep 3; }
s4 () { sleep 4; }
s5 () { sleep 5; }
#
#################
#   Install 1   #
# Install nmap  #
#################
ask_Install1 () {
while true
do
read -r -p "Do You Want To Install $depends1? [Y/n]" ask_d1_input
case $ask_d1_input in
[yY][eE][sS]|[yY])
echo "Installing $depends1"
s
sudo apt install $depends1 -y -qq > /dev/null
s
if type $depends1 &>/dev/null
then :
else
echo "$depends1 wasn't installed"
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
#################
#   Install 2   #
# Install msmtp #
#################
ask_Install2 () {
while true
do
read -r -p "Do You Want To Install $depends2? [Y/n]" ask_d2_input
case $ask_d2_input in
[yY][eE][sS]|[yY])
echo "Installing $depends2"
s
sudo apt install $depends2 -y -qq > /dev/null
s
if type $depends2 &>/dev/null
then :
else
echo "$depends2 wasn't installed"
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
#####################
#     Install 3     #
# Install msmtp-mta #
#####################
ask_Install3 () {
while true
do
read -r -p "Do You Want To Install $depends3? [Y/n]" ask_d3_input
case $ask_d3_input in
[yY][eE][sS]|[yY])
echo "Installing $depends3"
s
sudo apt install $depends3 -y -qq > /dev/null
s
if [[ -f /usr/sbin/sendmail ]]
then :
else
echo "$depends3 wasn't installed"
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


#################################
## START INITIAL PROGRAM CHECK ##
#################################
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} This script must be run as sudo or root!"
exit 1
fi
#
#check if run as "sh" instead of "bash"
if readlink /proc/$$/exe | grep -q "dash"
then echo 'Needs to be run as "bash", not "sh".'
exit
fi
#
# check if $depends1 is installed
if type $depends1 &>/dev/null
then :  # continue code if $depends1 is found
else
echo "ERROR '$depends1' is not installed"
echo "need to run 'sudo apt search $depends1'"
echo "find '$depends1' to install and run 'sudo apt install $depends1'"
ask_Install1
echo "done installing $depends1...Run script again."
exit 0
fi
#
# check if $depends2 and is installed
if type $depends2 &>/dev/null
then :  # continue code if $depends2 is found
else
echo "ERROR '$depends2' is not installed"
echo "need to run 'sudo apt search $depends2'"
echo "find '$depends2' to install and run 'sudo apt install $depends2'"
echo "NOTE: Must configure  msmtp and also install msmtp-mta"
ask_Install2
echo "done installing $depends2...Run script again."  #DEL
exit 0                         #DEL
fi
# check if $depends3 is installed
if [[ -f /usr/sbin/sendmail ]]
then :  # continue code if $depends3 is found
else
echo "ERROR '$depends3' is not installed"
echo "need to run 'sudo apt search $depends3'"
echo "find depends3 to install and run 'sudo apt install $depends3'"
ask_Install3
echo "done installing $depends3...Run script again."                              #DEL
exit 0                                                     #DEL
fi
#
# checking if $depends4 is setup
if [[ -f /etc/$depends4 ]]
then :  # continue code if msmtprc is setup
else
echo "All dependancies appear to be installed but /etc/msmtprc is missing"
echo -e "\033[32mYou will have to configure this file manually.\033[0m"
echo -e "\033[32mThis script will create the file and setup a default template... But,\033[0m"
echo -e "\033[32myou will have to add the email account info and authentication password\033[0m"
sudo touch /etc/msmtprc
echo -e "defaults\auth on\ntls on\ntls_starttls on\ntls_trust_file /etc/ssl/certs/ca-certificates.crt\nlogfile /var/log/msmtp_mail.log\n\naccount gmail\nhost smtp.gmail.com\nport 587\n\nfrom email@gmail.com\nuser email@gmail.com\npassword xxxxxxxx\n\naccount default: gmail\naliases /etc/aliases" > /etc/msmtprc
sudo chown root:msmtp /etc/msmtprc
sudo chmod u+r,g+r,o-rwx /etc/msmtprc
echo "created /etc/msmtprc and set permissions"
echo -e "\033[32mNOW, GO AND EDIT THE FILE: /etc/msmtprc !!!!\033[0m"
exit 0
fi
#######################################
#######################################
######       BEGIN PROGRAM       ######
#######################################
#######################################
#
# check if an old scan exists
#
###########################
_oldScan="old-nmapscan"
###########################
#
if [ -e $_oldScan ]
then ping -c 1 -W 10 1.1.1.1 > /dev/null 2>&1
if [ $? -eq 0 ]
then
echo "sending archived email..."
_oldsub="Old Scan (From $_host)"
_oldbod=$(<$_oldScan)
_oldwho="$_to"
echo -e "Subject: $_oldsub\n\n$_oldbod" | msmtp -a gmail "$_oldwho"
sudo rm $_oldScan
else
echo "Internet is down.  Found a previous scan in file: old-nmapscan, but unable to send it."
exit 0
fi
else
:
fi
#####################################
#
## get local ip addresses w/ (hostip)
## get SSID w/ (iwgetid)
#
#####################################
# {sed 's/^[[:space:]]*//'}  shifts output to the left
_hostIP=$(hostip)
_ssID=$(iwgetid | cut --complement -d' ' -f1 | sed 's/^[[:space:]]*//')
_allssID=$(sudo iwlist wlan0 scan | grep "ESSID" | sed 's/^[[:space:]]*//')
##
## gentle scan (arp) to get basic network specs
arp > arpscan.txt
_arp=$(cat arpscan.txt)
#
#############################################
#
#
#
#########################################################
## scan for active ip addresses on network w/ (nmap)   ##
## and output results to ipList_datetime               ##
#########################################################
# set ip address
checkIP=$(hostip | grep LAN | cut -d ' ' -f 3 | cut -d '.' -f 1)
if [ -z "$checkIP" ] || [ "$checkIP" -eq 169 ];
then _lanIP=$(hostip | grep LOCAL | cut -d ' ' -f 3)
else _lanIP=$(hostip | grep LAN | cut -d ' ' -f 3)
fi
rootIP="${_lanIP%.*}.0"
_lanIP=$rootIP
echo "Scanning network: $_lanIP"
#
#_lanIP=$(hostip | grep LOCAL | cut -d' ' -f 3)
#_lanIP=$(hostname -I)
#
########################
##     NMAP SCANS     ##
########################
# get ip, mac, vendor and file in ipFilter
echo "running IPfilter..."
sudo nmap -sn $_lanIP/24 | grep -E "Nmap scan report|MAC Address" | awk '/Nmap scan report/{ip=$NF} /MAC Address/{print ip, $3,$4,$5}' > ipFilter
#
echo "running gsubList..."
sudo nmap -sn $_lanIP/24 | awk '/Nmap scan/{gsub(/[()]/,"",$NF); print $NF > "gsubList"}'
echo "running ipList..."
sudo nmap -sP $_lanIP/24 > ipList
cat ipList | grep 'MAC\|scan report' > ipList_$_D_$_T
cat ipList | awk '1==1 {res=gsub("\r","")}/Nmap scan report for/{gsub(/[()]/,"",$NF); printf "%s\t", $NF;}/MAC Address:/{gsub("[()]","");printf "%s   ", $3; for(i=4; i<=NF; ++i)}' > newIpMacList
_scan4=$(<ipFilter)
_scan1=$(<ipList_$_D_$_T)
_scan2=$(<gsubList)
_scan3=$(<newIpMacList)
## get list of only ip addresses and file in iptargets
## and then scan top 100 ports
echo "scanning for targets..."
sudo nmap -n -sP $_lanIP/24 -oG - | awk '/Up$/{print $2}' | sort -V > iptargets
echo "scanning ports..."
sudo nmap -v0 -O -f -iL iptargets -oG ip-ports #old
_ports=$(<ip-ports)
echo "deeper portscan..."
sudo nmap -v0 -O -f -iL gsubList -oG gsubList-portscan
_ports2=$(<gsubList-portscan)
#
### Test if internet working
ping -c 1 -W 10 1.1.1.1 > /dev/null 2>&1
if [ $? -eq 0 ]
then :
else echo $_bod > $_oldScan
echo "No internet. Scan archived in old-nmapscan."
exit 0
fi
#
################################
### Email Body Configuration ###
################################
_ConNet="Connected Network:\n$_ssID"
_AllNet="Available Networks:\n$_allssID"
_CurCon="Current Connection:\n$_hostIP"
_NetScan="Network Scan:\nSCAN 1:\n$_scan1"
_test2="IP ADDRESSES:\n$_scan2"
_test3="IP MAC ADDRESSES:\n$_scan3"
_OPorts="OPEN PORTS:\n$_ports"
_testPorts="GSUB DEEP-PORTS:\n$_ports2"
_ARP="ARP SCAN RESULTS:\n$_arp"
_test4="IP, MAC, VENDOR:\n$_scan4 "
#
#############################
# Secondary email variables #
#############################
#
### Some Test configuration for HTML ###
#_HTML="Content-Type: text/html; charset=UTF-8"
#_ConNet="<p><u>Connected Network:</u></p><p>$_ssID</p>"
#_AllNet="<u>Available Networks:</u><p>$_allssID</p>"
#_CurCon="<u>Current Connection:</u><p>$_host</p>"
#_NetScan="<u>SCAN 1:</u><p>$_scan1</p>"
#_test2="<u>SCAN 2:<u/><p>$_scan2</p>"
#_test3="<u>SCAN 3:</u></p>$_scan3</p>"
#_OPorts="<u>OPEN PORTS 1:</u><p>$_ports</p>"
#_testPorts="<u>THIS IS gsub PORTS 2:</u><p>$_ports2</p>"
#_ARP="<u>ARP SCAN RESULTS:</u><p>$_arp</p>"
#_test4="<u>IP, MAC, VENDOR:</u><p>$_scan4</p>"
#_sub="Network Scan (From $_host)"
#_bod="<html><body>ARP SCAN RESULTS on \n$_D $_T :: <br>$_ConNet\n$_AllNet<br>$_CurCon<br>$_test4<br>$_NetScan<br>$_test2<br>$_test3<br>$_OPorts<br>$_testPorts<br>$_ARP </body></html>"
#_who="email@email.com"
#################################################################
###############################                                 #
## ESSENTIAL EMAIL VARIABLES ##                                 #
###############################                                 #
#################################################################
_sub="Network Scan (From $_host)"
_bod="ARP SCAN RESULTS on \n$_D $_T :: \n\n$_ConNet\n$_AllNet\n\n$_CurCon\n\n$_test4\n\n$_NetScan\n\n$_test2\n\n$_test3\n\n\n$_OPorts\n\n$_testPorts\n\n$_ARP "
#
###################################
### Configure Email for Sending ###
###################################
#add ($_HTML\n) before (Subject:) for html"
#
echo -e "Subject: $_sub\n\n$_bod" | msmtp -a "$_from" "$_to"
# remove temp files
#sudo rm arpscan.txt iptargets ip-ports ipList* gsubList gsubList-portscan ipFilter newIpMacList
echo "email sent to $_to"
exit 0
