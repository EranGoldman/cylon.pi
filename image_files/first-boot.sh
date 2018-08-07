#!/bin/bash

###############################
### Installation Constants ####
###############################

hostname=cylonpi
username=cylon
userpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!@#$%^&*_+' | fold -w 6 | head -n 1)


###############################
### Some helpfull functions ###
###############################

timestamp() { date +"%F_%T_%Z"; }
log_this() {
  echo $(timestamp) >> /boot/first-boot.log
  echo $1 >> /boot/first-boot.log
  echo '\n' >> /boot/first-boot.log
}
###############################
###### The script itself ######
###############################

# Log everything to file
exec &> >(tee -a "/boot/first-boot.log")

## Installation process after first-boot of the pi

echo -n "$(timestamp) [OwnPi] Changing default username and password... "
if [ -z ${username+x} ] || ! id $userdef &>/dev/null || id "$username" &>/dev/null; then
  echo "SKIPPED"
else
  usermod -l "$username" $userdef
  usermod -m -d "/home/$username" "$username"
  groupmod -n "$username" $userdef
  chpasswd <<< "$username:$userpw"
  echo "OK"
fi

log_this $userpw

echo "=============================="
echo
echo -n "Your password is : "
echo $userpw
echo
echo "=============================="
read -n1 -r -p "Press space to continue..." key

echo -n "$(timestamp) [OwnPi] Updating repositories and upgrading installed packages... "
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
