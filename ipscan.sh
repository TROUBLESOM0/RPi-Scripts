#!/bin/bash
### Obtains the first 3 octets of host IP address and pings entire subnet
### Places results in file results_ipsweep.txt where script was run
HOSTIP=$( hostname -I | cut -d "." -f 1-3 )
echo -e "\e[4mpinging 1-254 hosts in subnet "$HOSTIP"\e[0m"
for ip in `seq 1 254`; do
ping -c 1 $HOSTIP.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
done > results_ipscan.txt
sleep 2s
echo "ip scan complete / begin nmap scan"
#
#for ip in $(cat results_ipscan.txt); do
nmap -oN results_nmapscan.txt -A -Pn -iL results_ipscan.txt
#done > results_nmapscan.txt
echo "Scan Complete"
echo "Running vulnerability scan"
nmap -oN results_nmap-vuln.txt --script vuln -iL results_ipscan.txt
echo "All scans complete. See results files"
###
### original script to type in the subnet to ping
#if [ "$1" == "" ]
#then
#echo "You forgot to enter an ip address"
#echo "Example: ./ipsweep.sh 10.10.10"
#else
#for ip in `seq 1 254`; do
#ping -c 1 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
#done
#fi
