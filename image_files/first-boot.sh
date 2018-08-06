#!/bin/bash

###############################
### Installation Constants ####
###############################

hostname=cylonpi
username=cylon
userpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!@#$%^&*_+' | fold -w 12 | head -n 1)


###############################
### Some helpfull functions ###
###############################

timestamp() { date +"%F_%T_%Z"; }

###############################
###### The script itself ######
###############################

# Log everything to file
exec &> >(tee -a "/boot/first-boot.log")

## Installation process after first-boot of the pi

echo -n "$(timestamp) [openHABian] Changing default username and password... "
if [ -z ${username+x} ] || ! id $userdef &>/dev/null || id "$username" &>/dev/null; then
  echo "SKIPPED"
else
  usermod -l "$username" $userdef
  usermod -m -d "/home/$username" "$username"
  groupmod -n "$username" $userdef
  chpasswd <<< "$username:$userpw"
  echo "OK"
fi

echo -n "$(timestamp) [openHABian] Updating repositories and upgrading installed packages... "
apt update &>/dev/null
apt --yes upgrade &>/dev/null
if [ $? -eq 0 ]; then
  echo "OK";
else
  dpkg --configure -a
  apt update &>/dev/null
  apt --yes upgrade &>/dev/null
  if [ $? -eq 0 ]; then echo "OK"; else echo "FAILED"; fail_inprogress; fi
fi
