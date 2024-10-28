#!/usr/bin/bash
#
## Can only run 1 per minute
#
# From: mohafabode.com@gmail.com
# Send email with msmtp
# echo -e "Subject: Your Subject Here\n\nBody of Email Here" | msmtp -a gmail jmahaffey09@yahoo.com
#
#
## do (arp) to get basic hw network specs
#arp > arpscan.txt
#_arp=$(cat arpscan.txt)
## sets date & time
#_d=$(date +"%m-%d-%Y")
#_T=$(date +"%H:%M")
## get local ip addresses w/ (hostip)
## get SSID w/ (iwgetid)
#_host=$(hostip)
#_ssID=$(iwgetid | cut --complement -d' ' -f1)
## scan for active ip addresses on network w/ (nmap)
#_lanIP=$(hostip | grep LAN | cut -d' ' -f 3)
#sudo nmap -sP $_lanIP/24 | grep 'MAC\|scan report' > scan.txt
#_scan1=$(<scan.txt)


_sub="Win 100,000,000 Instantly!!!"
_bod="YOU CAN WIN SO MUCH MONEY RIGHT NOW\nEVEN IF YOU DON'T LIKE MONEY, YOU CAN JUST GIVE IT TO SOMEONE WHO NEEDS IT. :: \nTHIS IS NOT A JOKE\nTHIS IS REAL SHIT\nALL YOU HAVE TO DO IS OPT-IN FOR TEXT MESSAGING\nYOU WILL ONLY RECEIVE TEXTS RELATED TO YOUR CHANCE TO WIN ALOT OF MONEY\n\nTO OPT OUT .... SYC, THERE'S NO WAY TO OPT OUT "
_who="6628125631@txt.att.net"

### Configure Email for Sending ###
echo -e "Subject: $_sub\n\n$_bod" | msmtp -a gmail "$_who"

#rm arpscan.txt
