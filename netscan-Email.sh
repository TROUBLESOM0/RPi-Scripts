#!/usr/bin/bash
# From: mohafabode.com@gmail.com
# Send email with msmtp
# echo -e "Subject: Your Subject Here\n\nBody of Email Here" | msmtp -a gmail jmahaffey09@yahoo.com
#
#
## do (arp) to get basic hw network specs
arp > arpscan.txt
_arp=$(cat arpscan.txt)
## sets date & time
_D=$(date +"%m-%d-%Y")
_T=$(date +"%H:%M")
## get local ip addresses w/ (hostip)
## get SSID w/ (iwgetid)
_host=$(hostip)
_ssID=$(iwgetid | cut --complement -d' ' -f1)
_allssID=$(sudo iwlist wlan0 scan | grep ESSID)
#########################################################
## scan for active ip addresses on network w/ (nmap)   ##
## and output results to ipList_datetime               ##
#########################################################
# set ip address
checkIP=$(hostip | grep LAN | cut -d ' ' -f 3 | cut -d '.' -f 1)
if [ -z "$checkIP" ] || [ "$checkIP" -eq 169 ];
then
_lanIP=$(hostip | grep LOCAL | cut -d ' ' -f 3)
else
_lanIP=$(hostip | grep LAN | cut -d ' ' -f 3)
fi
rootIP="${_lanIP%.*}.0"
_lanIP=$rootIP
#
#_lanIP=$(hostip | grep LOCAL | cut -d' ' -f 3)
#_lanIP=$(hostname -I)
#
######################
# running nmap scans##
######################
# get ip, mac, vendor and file in ipFilter
sudo nmap -sn 192.168.0.0/24 | grep -E "Nmap scan report|MAC Address" | awk '/Nmap scan report/{ip=$NF} /MAC Address/{print ip, $3,$4,$5}' > ipFilter
#
nmap -sn $_lanIP/24 | awk '/Nmap scan/{gsub(/[()]/,"",$NF); print $NF > "gsubList"}'
sudo nmap -sP $_lanIP/24 > ipList
cat ipList | grep 'MAC\|scan report' > ipList_$_D_$_T
cat ipList | awk '1==1 {res=gsub("\r","")}/Nmap scan report for/{gsub(/[()]/,"",$NF); printf "%s\t", $NF;}/MAC Address:/{gsub("[()]","");printf "%s   ", $3; for(i=4; i<=NF; ++i)}' > newIpMacList 
_scan4=$(<ipFilter)
_scan1=$(<ipList_$_D_$_T)
_scan2=$(<gsubList)
_scan3=$(<newIpMacList)
## get list of only ip addresses and file in iptargets
## and then scan top 100 ports
sudo nmap -n -sP $_lanIP/24 -oG - | awk '/Up$/{print $2}' | sort -V > iptargets
sudo nmap -v0 -O -F -iL iptargets -oG ip-ports #old
_ports=$(<ip-ports)
sudo nmap -v0 -O -F -iL gsubList -oG gsubList-portscan
_ports2=$(<gsubList-portscan)
#
#########################
# Setup email variables #
#########################
_ConNet="Connected Network:\n$_ssID"
_AllNet="Available Networks:\n$_allssID"
_CurCon="Current Connection:\n$_host"
_NetScan="Network Scan:\nTHIS IS SCAN 1:\n$_scan1"
_test2="THIS IS TEST SCAN 2:\n$_scan2"
_test3="THIS IS TEST SCAN 3:\n$_scan3"
_OPorts="OPEN PORTS 1:\n$_ports"
_testPorts="THIS IS gsub PORTS 2:\n$_ports2"
_ARP="ARP SCAN RESULTS:\n$_arp"
_test4="IP, MAC, VENDOR:\n$_scan4 "
#################
## START EMAIL ##
#################
_sub="Network Scan (From Tiny Pi)"
_bod=" ARP SCAN RESULTS on \n$_D $_T :: \n\n$_ConNet\n$_AllNet\n\n$_CurCon\n\n$_test4\n\n$_NetScan\n\n$_test2\n\n$_test3\n\n\n$_OPorts\n\n$_testPorts\n\n$_ARP "
_who="jmahaffey09@yahoo.com"

### Configure Email for Sending ###
echo -e "Subject: $_sub\n\n$_bod" | msmtp -a gmail "$_who"
# remove temp files
sudo rm arpscan.txt iptargets ip-ports ipList* gsubList gsubList-portscan ipFilter newIpMacList
