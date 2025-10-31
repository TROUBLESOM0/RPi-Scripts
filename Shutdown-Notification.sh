#!/bin/bash
# MSMTP and MPACK are required to be installed and setup
# *** Must configure variables below ***
# *** Must make this file executable ***

# Obtain real directory of this file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EMAIL_PAYLOAD1=""
EMAIL_PAYLOAD2=""
DATE=$(date '+%Y-%m-%d %H:%M:%S')
_to="email@email.com"
_num="1112223333"  #recipient for sms
_from="" #configured in /etc/msmtprc
_textAPI="textbelt API"
halt_type="Unknown Restart"
hostname=`hostname`

# variables for system unit file
UNIT_FILE="/etc/systemd/system/email-halt.service"

#this variable required to compile MIME-type message
# before sending outside of mpack
tmp="~/email.tmp"
body="~/body.tmp"

# Include remailing sms balance in text
getLeft=$(curl -s "https://textbelt.com/quota/$_textAPI")
smsLeft=$(echo "$getLeft" | grep -oP '(?<="quotaRemaining":)\d+')

# Check what we're shutting down into
if systemctl list-jobs | grep -q 'reboot.target'; then
    halt_type="Reboot"
elif systemctl list-jobs | grep -q 'poweroff.target'; then
    halt_type="Shutdown"
fi


# One Time Setup for service to run before reboot/shutdown
if [[ ! -f $UNIT_FILE ]]; then
  echo "Installing system service to send notification on Shutdown or Reboot."
    if [[ -d /etc/systemd/system ]]
    then :
    else echo "/etc/systemd/system not the correct directory for this setup. Exiting."
    exit 1
    fi
    
  # Build system service file
  cat <<EOF > "$UNIT_FILE"
  [Unit]
  Description=Send email before shutdown or reboot
  DefaultDependencies=no
  Before=halt.target reboot.target shutdown.target
  Requires=NetworkManager-wait-online.service
  After=NetworkManager-wait-online.service

  [Service]
  Type=oneshot
  ExecStart=/bin/true
  ExecStop=/usr/bin/sudo $SCRIPT_DIR/Shutdown-Notification.sh
  RemainAfterExit=true
  TimeoutSec=10

  [Install]
  WantedBy=multi-user.target
  EOF

# Set permissions of .service file, reload, and start
  chmod 644 $UNIT_FILE
  systemctl daemon-reexec
  systemctl daemon-reload
  echo "Enabling email-halt.service"
  systemctl enable email-halt.service
  systemctl start email-halt.service
    if [ $? -eq 0 ]
	  then echo "Service started without issues"
	  else echo "Issue starting service"
    exit 1
	  fi

# Continue script if email-halt.service already exists.
else :
fi


# Body of email to send with mpack (must be in a file)
cat <<EOF > "$body"
On $(date), a $halt_type command was sent to
$hostname
The last log file is contained in this email.
EOF



# First check if file exists and send file with msmtp
if [[ -f $EMAIL_PAYLOAD1 ]]
then mpack -s "Log File: $halt_type - $hostname" -d $body -o $tmp $EMAIL_PAYLOAD1
{
echo "To: $_to"
echo "From: $_from"


cat $tmp
echo "Log file at $EMAIL_PAYLOAD1 attached"
} | sudo msmtp -a admin $_to

# Second check if file exists and send file with mpack
elif [[ -f $EMAIL_PAYLOAD2 ]]
then mpack -s "Log File: $halt_type - $hostname" $EMAIL_PAYLOAD2


# Third, just send an email with msmtp if no file exists
else echo -e "To: $_to\nFrom: $_from\nSubject:Log File NOT FOUND\n\nLog file not found at \n$EMAIL_PAYLOAD1\nor\n$EMAIL_PAYLOAD2\n\n$halt_type on $hostname\n$DATE" | sudo msmtp -a admin $_to
fi

rm -f $tmp
rm -f $body

# Send SMS (parameters separated by "\")
curl -X POST https://textbelt.com/text \
       --data-urlencode phone=$_num \
       --data-urlencode message="Input Message
Separate lines of texts like with <CR>.
Source Host: $hostname

Text Remaining: $smsLeft" \
       -d key=$_textAPI
