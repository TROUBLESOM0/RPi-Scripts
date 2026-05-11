#!/bin/bash
### Simple configuration for sshd_config
### You should already have keypairs created and stored
### ref. setupNewDebian.sh on Github
#
### Get full sshd config with " sudo sshd -T 
#
#
# Is an SSH service registered?
SERVICE_CHECK=$(systemctl list-unit-files | grep -i ssh | grep enabled)

# Is anything listening on Port 22?
PORT_CHECK=$(ss -tlnp | grep :22)

# Is the 'sshd' command available?
COMMAND_CHECK=$(command -v sshd)

if [ -n "$COMMAND_CHECK" ] || [ -n "$PORT_CHECK" ]; then
    echo "An SSH server is detected."
    [ -n "$COMMAND_CHECK" ] && echo "   - Binary: $COMMAND_CHECK"
    [ -n "$PORT_CHECK" ] && echo "   - Listening on Port 22"
else
    echo "No SSH server detected."
    echo "Installing OpenSSH Server."
    sudo apt install openssh-server -y
    echo ""
fi

SSH_FILE=/etc/ssh/sshd_config
echo "You better have already created your keypairs !!!"
echo -e "**** Cause you about to \e[4mremove password login\e[0m"
echo
echo "Do you want to append the following to sshd_config :"
echo "----------------------------------------------"
echo "Subsystem sftp /usr/lib/openssh/sftp-server"
echo "AcceptEnv LANG LC_*"
echo "AllowAgentForwarding no"
echo "AllowTcpForwarding no"
echo "PrintMotd no"
echo "X11Forwarding no"
echo "ChallengeResponseAuthentication no"
echo "PermitRootLogin no"
echo "PasswordAuthentication no"
echo "PermitEmptyPasswords no"
echo "UsePAM no"
echo "AuthenticationMethods publickey"
echo "AllowUsers USERNAME"
echo "----------------------------------------------"
echo
echo " Remember, you're about to remove password authentication!!!"
read -p "Do you want to continue? [y/N] " ask_input

if [[ "$ask_input" == [nN] ]]; then
    echo "Ending."
    exit 0
else
    echo "Checking presence of sshd_config"
fi

if [ -f $SSH_FILE ]
then echo "Making backup $SSH_FILE.default"
sudo cp $SSH_FILE $SSH_FILE.default
else
echo "Unable to locate sshd_config. Exiting"
exit 1
fi

read -p "Type username to use for authentication with sshd:" ask_user

# There can be only one Subsystem configuration
# This should search for a configuration of 'Subsystem sftp' and replace or add
if grep -q "^Subsystem sftp" /etc/ssh/sshd_config
then sed -i 's|^Subsystem sftp.*|Subsystem sftp internal-sftp|' /etc/ssh/sshd_config
else echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config
fi

cat <<- EOF >> $SSH_FILE

# added by $ask_user
AcceptEnv LANG LC_*
AllowAgentForwarding no
AllowTcpForwarding no
PrintMotd no
X11Forwarding no
ChallengeResponseAuthentication no
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
UsePAM no
AuthenticationMethods publickey
AllowUsers $ask_user
EOF

echo -e "Output of new file displayed below: \n"
echo "<---------------------------------------------------------------------->"
cat $SSH_FILE
echo "<---------------------------------------------------------------------->"
echo -e "\nIf you are happy with output, You just need to:"
echo " 1) Again, make sure keypairs are complete and in right places w/ correct permissions."
echo " 2) Restart sshd daemon with ' sudo systemctl restart sshd ' "
echo "Reference Setup_Debian at https://github.com/TROUBLESOM0/Setup_Debian "
exit 0
