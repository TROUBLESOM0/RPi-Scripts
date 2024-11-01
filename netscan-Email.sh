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
#########################################################
## scan for active ip addresses on network w/ (nmap)   ##
## and output results to ipList_datetime               ##
#########################################################
_lanIP=$(hostip | grep LOCAL | cut -d' ' -f 3)
#_lanIP=$(hostname -I)
nmap -sn $_lanIP/24 | awk '/Nmap scan/{gsub(/[()]/,"",$NF); print $NF > "gsubList"}'
sudo nmap -sP $_lanIP/24 | grep 'MAC\|scan report' > ipList_$_D_$_T
_scan1=$(<ipList_$_D_$_T)
_scan2=$(<gsubList)
## get list of only ip addresses
## and then scan top 100 ports
sudo nmap -n -sP $_lanIP/24 -oG - | awk '/Up$/{print $2}' | sort -V > iptargets
sudo nmap -v0 -O -F -iL iptargets -oG ip-ports #old
_ports=$(<ip-ports)
sudo nmap -v0 -O -F -iL gsubList -oG gsubList-portscan
_ports2=$(<gsubList-portscan)
_sub="Network Scan (From Tiny Pi)"
_bod=" ARP SCAN RESULTS on \n$_T $_D :: \n\nNetwork:\n$_ssID\nHost IP:\n$_host\n\nNetwork Scan:\nTHIS IS SCAN 1$_scan1\n\nTHIS IS SCAN 2\n\n$_scan2\n\n\nTHIS IS OPEN PORTS 1\n$_ports\n\nTHIS IS OPEN PORTS 2\n$_ports2$_arp "
_who="jmahaffey09@yahoo.com"

### Configure Email for Sending ###
echo -e "Subject: $_sub\n\n$_bod" | msmtp -a gmail "$_who"

sudo rm arpscan.txt scan.txt iptargets ip-ports
