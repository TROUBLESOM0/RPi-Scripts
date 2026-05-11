#!/bin/bash
#
#
############################
#      Initial Checks      #
############################
# Check script is running as root
if [[ $( whoami ) != "root" ]]
then echo -e "${Error}ERROR${Off} Must be run as sudo or root"
exit 1
else :
fi

#
######################
###   ASK_END    ###
######################
ask_END () {
echo "*** Don't forget to move the private ssh key off this machine if it was set up ***"

if [[ -f $HOSTNAME.pem ]]
then cat $HOSTNAME.pem
elif [[ -f $pub.pem ]]
then cat $pub.pem
else echo ""
fi
if [[ -f "$HOSTNAME.pem" || -f "$pub.pem" ]]
then echo ""
echo "--- this is end of private key ---"
echo "Once moved off of server, and tested working, you should delete it from this server"
echo "permissions should be set to rw by owner"
echo "***"
echo "FOR SECURITY SETTINGS SEE SSHD_CONFIG IN /etc/sshd/"
echo "To list all ssh settings run ' sudo sshd -T ' "
echo "See sshd_simple_conf.sh"
echo "***"
else :
fi

}
#
######################
###   ASK_YACHT    ###
######################
ask_yacht () {
read -p "Do you want to install yacht docker manager? [y/n]" yacht_input
#convert to lowercase
if [[ "${yacht_input,,}" == "y" || "${yacht_input,,}" == "yes" ]]
then docker compose -f $docksc/yacht.yml up -d
else :
fi
}
#
#######################
###   ASK_DOCKER    ###
#######################
ask_docker () {
read -p "Do you want to install docker? [y/n]" dock_input
#convert to lowercase
dock_input="${dock_input,,}"
if [[ "$dock_input" == "y" || "$dock_input" == "yes" ]]
then echo "installing apt-transport-https"
apt update
#apt upgrade -y
apt install apt-transport-https -y
dpkg -l | grep -qw apt-transport-https
  if [ $? -eq 0 ]
  then :
  else echo -e "\n+++${Error}ERROR${Off} apt-transport-https installation failed. Try installing manually with sudo apt install apt-transport-https\n"
  fi
wget https://get.docker.com/ -O get-docker.sh
bash get-docker.sh
read -p "Enter user to attach docker group:" dockGroup_input
usermod -aG docker $dockGroup_input
#
# Creating docker folder
userHome=$(eval echo "~$SUDO_USER")
docksc="$userHome/docker_sc"
  if [[ -d $docksc ]]
  then echo ""
  echo "Storing docker compose files in $docksc"
  else echo ""
  mkdir $docksc
  echo "Storing docker compose files in $docksc"
  fi

# Create yacht folder
if [[ -d $docksc/yacht ]]
then echo ""
dirYacht="$docksc/yacht"
echo "Storing yacht compose files in $dirYacht"
else echo ""
mkdir $docksc/yacht
dirYacht="$docksc/yacht"
echo "Storing docker compose files in $dirYacht"
fi

# Creating yacht yaml file
file_yacht="$dirYacht/yacht.yml"
cat > $file_yacht <<EOF
services:
  yacht:
    container_name: yacht
    restart: unless-stopped
    ports:
      - "8000:8000"
    volumes:
      - ./yacht:/config
      - /var/run/docker.sock:/var/run/docker.sock
    image: selfhostedpro/yacht
    networks:
      - nginx-net

networks:
  nginx-net:
    external: true
EOF
#
echo "Confirm this is correct for yacht..."
cat $file_yacht

echo "Creating docker network nginx-net"
docker network create nginx-net

ask_yacht

else :
fi
}
#
############################
###   ASK_RPI-SCRIPTS    ###
############################
ask_RPI-Scripts () {
echo ""
read -r -p "Do you want to install some basic scripts in $SUDO_USER home folder?" scripts_input
if [[ ${scripts_input,,} == "y" || ${scripts_input,,} == "yes" ]]
then wget "https://github.com/TROUBLESOM0/RPi-Scripts/releases/latest/download/Scripts_Install.sh"
bash Scripts_Install.sh
else return 0
fi
}
#
#####################
###   ASK_SSHD    ###
#####################
ask_sshd () {
read -p "Do you want to create a new ssh key? [y/n]" key_input
#convert to lowercase
key_input="${key_input,,}"
if [[ "$key_input" == "y" || "$key_input" == "yes" ]]
then
echo "What do you want to use for the name of private key?"
echo "1) hostname = $HOSTNAME"
pub=$(curl -s ifconfig.me)
echo "2) ip address = $pub"
read -p "Type (1) or (2) :" host_Type
case $host_Type in
1)
ssh-keygen -t ecdsa -b 256 -C none -f authorized_keys
mv authorized_keys $HOSTNAME.pem
mv authorized_keys.pub authorized_keys
chmod 600 $HOSTNAME.pem
chmod 600 authorized_keys
echo "Public file changed to 'authorized_keys'"
;;
2)
ssh-keygen -t ecdsa -b 256 -C none -f authorized_keys
mv authorized_keys $pub.pem
mv authorized_keys.pub authorized_keys
chmod 600 $pub.pem
chmod 600 authorized_keys
echo "Public file changed to 'authorized_keys'"
;;
*)
echo "Must enter [1 or 2]"
exit 1
;;
esac

echo ""
echo "***************************************************"
echo ""
echo "    Configuring the user for the new key..."
echo "Name of User to use for key (must be one of below):"
ls /home
echo ""
echo "***************************************************"
read -p "YOU MUST ENTER NAME OF A CURRENT USER (SEE ABOVE ^): " key_User
echo "***************************************************"
echo ""
echo "***************************************************"
if [[ -d /home/$key_User/.ssh ]]
then :
else mkdir /home/$key_User/.ssh
fi
if [[ -f authorized_keys ]]
then mv authorized_keys /home/$key_User/.ssh/authorized_keys
  if [[ -f /home/$key_User/.ssh/authorized_keys ]]
  then :
  else echo "ERROR VERIFYING authorized_keys FILE IN USERS FOLDER"
  exit 1
  fi
echo "public key moved to .ssh folder for user: $key_User"
chmod 600 /home/$key_User/.ssh/authorized_keys
chown -R $key_User:$key_User /home/$key_User/.ssh
echo "permissions set"
echo "You need to move '$HOSTNAME.pem or $pub.pem' off of server---"
echo "--- this is private key --- (copy it)"
echo ""
if [[ -f $HOSTNAME.pem ]]
then cat $HOSTNAME.pem
mv $HOSTNAME.pem /home/$key_User/$HOSTNAME.pem
elif [[ -f $pub.pem ]]
then cat $pub.pem
mv $pub.pem /home/$key_User/$pub.pem
else echo "Can't find private key file...It should be here somewhere"
fi
echo ""
echo "--- this is end of private key ---"
echo -e "\nYour private key should be in home directory: /home/$key_User"
echo "Once moved off of server, and tested working, you should delete it from this server"
echo "permissions should be set to rw by owner"
echo "***"
echo "FOR BEST SECURITY CHANGE SSHD_CONFIG IN /etc/sshd/"
echo "See sshd_simple_conf.sh"
echo "***"

else echo "Unable to locate authorized_keys file"
exit 1
fi

else :
fi
}
#
#####################
###   ASK_HOST    ###
#####################
ask_Host () {
echo "Current hostname: $HOSTNAME"
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
########################
###   ASK_DELUSER    ###
########################
ask_DelUser () {
echo "List of current users"
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
###   ASK_USER    ###
#####################
ask_User () {
echo "Current Users:"
ls /home
while true
do
read -r -p "Do you want to create a new user? [Y/n]" ask_user_input
case $ask_user_input in
[yY][eE][sS]|[yY])
read -p "Enter new user name:" NewUser
echo "Adding $NewUser"
adduser $NewUser
echo -e "\nGiving sudo permissions to $NewUser"
usermod -aG sudo $NewUser
echo "List of current users"
ls /home
;;
[nN][oO]|[nN])
echo "No user created"
break
;;
*)
echo "Must enter [Y/n]"
exit 0
;;
esac
done
}
#
#####################
###   ASK_START   ###
#####################
ask_Start () {
while true
do
read -r -p "Start script to setup New Debian? [Y/n]" ask_start_input
case $ask_start_input in
[yY][eE][sS]|[yY])
echo "Starting script..."
break
;;
[nN][oO]|[nN])
echo "Cancelled"
exit 0
;;
*)
echo "Must enter [Y/n]"
exit 0
;;
esac
done
}
#
#############################################
#              Begin Script                 #
#############################################
#
echo "This will:"
echo "1. Create a new user, with sudo permission."
echo "--- option to delete existing user"
echo "2. Change the hostname."
echo "3. Create ssh-keys (**** External Work Required ****)."
echo "4. Update all packages."
echo "5. Install docker"
echo "6. Then, install yacht-docker-manager."
echo ""
echo "You should receive queries for every task"
echo ""
ask_Start
ask_User
ask_DelUser
ask_Host
ask_sshd
ask_RPI-Scripts
ask_docker
ask_END
echo "Ending script."

exit 0
