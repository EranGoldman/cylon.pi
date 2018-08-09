#!/bin/bash

###############################
### Installation Constants ####
###############################

hostname=cylonpi
username=cylon
userpw=$(date +%N|sed s/...$//)


###############################
### Some helpfull functions ###
###############################

timestamp() { date +"%F_%T_%Z"; }
# log_this() {
#   echo $(timestamp) >> /boot/first-boot.log
#   echo $1 >> /boot/first-boot.log
#   echo '\n' >> /boot/first-boot.log
# }
###############################
###### The script itself ######
###############################

# Log everything to file
exec &> >(tee -a "/boot/first-boot.log")

# Installation process after first-boot of the pi

# Installing cylon.js
echo -n "[OwnPi] Installing nodejs : "
apt-get update > /dev/null
apt-get install -y git nodejs npm build-essential >/dev/null
ln /usr/bin/nodejs /usr/bin/node
echo "OK"
#
echo -n "[OwnPi] Cloning cylon.js : "
git clone https://github.com/hybridgroup/cylon.git /home/$username
echo "OK"

# Updateing user name and password
echo -n "$(timestamp) [OwnPi] Changing default username and password... "
if [ -z ${username+x} ] || ! id $usergroup &>/dev/null || id "$username" &>/dev/null; then
  echo "SKIPPED"
else
  usermod -l "$username" pi
  usermod -m -d "/home/$username" "$username"
  groupmod -n "$username" pi
  chpasswd <<< "$username:$userpw"
  echo "OK"
fi

echo "=============================="
echo
echo -n "Your password is : "
echo $userpw
echo
echo "=============================="

touch /opt/afterfirstboot.lock
