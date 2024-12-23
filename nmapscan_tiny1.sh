#!/usr/bin/bash
# From: email@gmail.com
# Send email with msmtp
# echo -e "Subject: Your Subject Here\n\nBody of Email Here" | msmtp -a gmail email@email.com
#
#
# check if exists in /bin
# if not, create it, set permissions, create auto-start and send to systemd
if [ -e "/bin/nmapscan" ]; then
	:
else
	echo "nmapscan isn't setup"
	echo "Adding into /bin"
	sudo chmod u+rwx,g+rwx,o+r nmapscan
	dir=`pwd`
	sudo ln -s $dir/nmapscan /bin/nmapscan
	touch nmapscan.service
	echo -e "[Unit]\nDescription=Run script to scan network and send email\nAfter=network-online.target\nWants=network-online.target\n\n[Service]\nExecStartPre=/bin/sleep 180\nExecStart=/bin/nmapscan\nExecStartPost=/bin/systemctl stop nmapscan.service\nType=oneshot\nUser=root\nRemainAfterExit=true\n\n[Install]\nWantedBy=multi-user.target" > nmapscan.service
	sudo chown root:root nmapscan.service
	sudo chmod u+rwx,g+rwx,o+rwx nmapscan.service
	sudo ln -s $dir/nmapscan.service /etc/systemd/system/nmapscan.service
	sudo systemctl enable nmapscan.service
	sudo systemctl start nmapscan.service
	echo "nmapscan added to systemctl  and nmapscan.service added"
        echo "Can be ran from:  systemctl start nmapscan"
	echo "Exiting..."
	exit 0
fi
#
# check if an old scan exists
if [ -e "oldScan" ]; then
	ping -c 1 -W 10 1.1.1.1 > /dev/null 2>&1
          if [ $? -eq 0 ]; then
            _oldsub="Old Scan (From Tiny Pi)"
            _oldbod=$(<oldScan)
            _oldwho="jmahaffey09@yahoo.com"
            echo -e "Subject: $_oldsub\n\n$_oldbod" | msmtp -a gmail "$_oldwho"
            sudo rm oldScan
	  else
            exit 0
	  fi
else
	:
fi
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
#
### Configured for HTML ###
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
#_sub="Network Scan (From Tiny Pi)"
#_bod="<html><body>ARP SCAN RESULTS on \n$_D $_T :: <br>$_ConNet\n$_AllNet<br>$_CurCon<br>$_test4<br>$_NetScan<br>$_test2<br>$_test3<br>$_OPorts<br>$_testPorts<br>$_ARP </body></html>"
#_who="email@email.com"
###########################
#
### Basic Configuration ###
_ConNet="Connected Network:\n$_ssID"
_AllNet="Available Networks:\n$_allssID"
_CurCon="Current Connection:\n$_host"
_NetScan="Network Scan:\nSCAN 1:\n$_scan1"
_test2="SCAN 2:\n$_scan2"
_test3="SCAN 3:\n$_scan3"
_OPorts="OPEN PORTS 1:\n$_ports"
_testPorts="GSUB PORTS 2:\n$_ports2"
_ARP="ARP SCAN RESULTS:\n$_arp"
_test4="IP, MAC, VENDOR:\n$_scan4 "
#################
## START EMAIL ##
#################
_sub="Network Scan (From Tiny Pi)"
_bod="ARP SCAN RESULTS on \n$_D $_T :: \n\n$_ConNet\n$_AllNet\n\n$_CurCon\n\n$_test4\n\n$_NetScan\n\n$_test2\n\n$_test3\n\n\n$_OPorts\n\n$_testPorts\n\n$_ARP "
_who="email@email.com"

### Test if internet working
ping -c 1 -W 10 1.1.1.1 > /dev/null 2>&1
if [ $? -eq 0 ]; then
	:
else
	echo $_bod > oldScan
	exit 0
fi
### Configure Email for Sending ###
echo -e "$_HTML\nSubject: $_sub\n\n$_bod" | msmtp -a gmail "$_who"
# remove temp files
sudo rm arpscan.txt iptargets ip-ports ipList* gsubList gsubList-portscan ipFilter #newIpMacList