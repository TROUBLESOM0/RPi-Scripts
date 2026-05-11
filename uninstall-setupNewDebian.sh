#!/bin/bash
#
#
### VARIABLES ###
#################
userHome=$(eval echo "~$SUDO_USER")
docksc="$userHome/docker_sc"
#
######################
## UNINSTALL_SSH-KEY##
######################
uninstall_SSH-KEY () {
echo -e "\n\n***** This next portion will remove ssh keys. (authorized_keys file in /.ssh ******"
echo "You will need to update '/etc/ssh/sshd_config'!! "
read -r -p "Remove ssh keys? [y/N]" key_input
#convert to lowercase
key_input="${key_input,,}"
if [[ "$key_input" == "y" || "$key_input" == "yes" ]]
then :
else return 0
fi

if [[ -d $userHome/.ssh ]]
then :
else echo ".ssh file not found in $userHome.  Nothing left to do here."
return 0
fi

if [[ -f $userHome/.ssh/authorized_keys ]]
then rm -f $userHome/.ssh/authorized_keys
else echo "authorized_keys file not found in $userHome/.ssh"
echo "No ssh files removed"
fi

if [[ ! -f $userHome/.ssh/authorized_keys ]]
then echo "SSH keys removed."
echo "Don't forget to adjust ssh config"
else echo "Failed to remove $userHome/.ssh/authorized_keys"
fi
}
#
########################
###   ASK_DELUSER    ###
########################
ask_DelUser () {
echo -e "\n\nList of current users"
ls /home
read -p "Do you want to remove a user? [y/n]" DelUser_input
#convert to lowercase
DelUser_input="${DelUser_input,,}"
if [[ "$DelUser_input" == "y" || "$DelUser_input" == "yes" ]]
then read -p "Name of user to remove:" DelUser
deluser --remove-home $DelUser
else :
fi
}
#
#####################
###   ASK_HOST    ###
#####################
ask_Host () {
echo -e "\n\nCurrent hostname: $HOSTNAME"
read -p "Do you want to change hostname of server? [y/n]" host_input
#convert to lowercase
host_input="${host_input,,}"
if [[ "$host_input" == "y" || "$host_input" == "yes" ]]
then read -p "Enter new hostname:" NewHost
hostnamectl set-hostname "$NewHost"
echo "Hostname set to - $HOSTNAME"
else
echo "Keeping current hostname: $HOSTNAME"
fi
}
#
######################
## UNINSTALL_DOCKER ##
######################
uninstall_Docker () {
echo -e "\n\nUninstalling docker..."
#echo "Trying something ..."

sudo rm /etc/apt/sources.list.d/docker.list    
sudo rm /etc/apt/keyrings/docker*
sudo apt remove docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin -y &>/dev/null
sudo rm -rf /var/lib/docker
sudo apt autoremove -y
sudo rm -r /etc/containerd
sudo rm -r /opt/containerd
sudo rm -rf $docksc
}
#
############################
#      Initial Checks      #
############################
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "\n${Error}ERROR${Off} Must be run as sudo or root\n"
exit 1
else :
fi
#
#############################################
#              Begin Script                 #
#############################################
uninstall_Docker
ask_Host
ask_DelUser
uninstall_SSH-KEY
