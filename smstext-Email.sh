#!/bin/bash
# Send sms and email for nut notifications
#
_num="1112223333"
_textAPI="textbelt API"
getLeft=$(curl -s "https://textbelt.com/quota/$_textAPI")
smsLeft=$(echo "$getLeft" | grep -oP '(?<="quotaRemaining":)\d+')

# Not working anymore after carriers turned of E2T
# Carrier
#_att="txt.att.net"
#_vzn="vtext.com"
#_tmo="tmomail.net"
#
_sub="CLOSET UPS"
_bod="ALERT: $NOTIFYTYPE\n$1\n$2"
#_who="$_num@$_att"
_who="email@email.com"

### Configure Email for Sending ###
echo -e "Subject: $_sub\n\n$_bod" | msmtp -a gmail "$_who"

### Send SMS TEXT via Textbelt.com
curl -X POST https://textbelt.com/text \
       --data-urlencode phone=$_num \
       --data-urlencode message="CLOSET UPS:
Issue: $NOTIFYTYPE, $1, $2

Text Remaining: $smsLeft" \
       -d key=$_textAPI
