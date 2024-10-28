#!/usr/bin/bash
# Send sms from mohafabode.com@gmail.com
## Can only run 1 per minute
#
# From: mohafabode.com@gmail.com
# Send email with msmtp
# echo -e "Subject: Your Subject Here\n\nBody of Email Here" | msmtp -a gmail jmahaffey09@yahoo.com
#
_num="111223333"
# Carrier
_att="txt.att.net"
_vzn="vtext.com"
_tmo="tmomail.net"
#
_sub="Win 100,000,000 Instantly!!!"
_bod="YOU CAN WIN SO MUCH MONEY\n\nTO OPT OUT"
_who="$_num@$_att"

### Configure Email for Sending ###
echo -e "Subject: $_sub\n\n$_bod" | msmtp -a gmail "$_who"
