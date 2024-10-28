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
_d=$(date +"%m-%d-%Y")
_T=$(date +"%H:%M")
## get local ip addresses w/ (hostip)
## get SSID w/ (iwgetid)
_host=$(hostip)
_ssID=$(iwgetid | cut --complement -d' ' -f1)
#########################################################
## scan for active ip addresses on network w/ (nmap)   ##
## and output results to scan.txt (file removed at end)##
#########################################################
_lanIP=$(hostip | grep LAN | cut -d' ' -f 3)
sudo nmap -sP $_lanIP/24 | grep 'MAC\|scan report' > scan.txt
_scan1=$(<scan.txt)
## get list of only ip addresses
## and then scan top 100 ports
sudo nmap -n -sP $_lanIP/24 -oG - | awk '/Up$/{print $2}' | sort -V > iptargets
sudo nmap -v0 -O -F -iL iptargets -oG ip-ports
_ports=$(<ip-ports)

_sub="Network Scan (From Tiny Pi)"
_bod=" ARP SCAN RESULTS on \n$_T $_d :: \n\nNetwork:\n$_ssID\nHost IP:\n$_host\n\nNetwork Scan:\n$_scan1\n\n$_ports\n\n$_arp "
_who="jmahaffey09@yahoo.com"

### Configure Email for Sending ###
echo -e "Subject: $_sub\n\n$_bod" | msmtp -a gmail "$_who"

sudo rm arpscan.txt scan.txt iptargets ip-ports
