#!/usr/bin/env bash
set -e

###############################
### Some helpfull functions ###
###############################

timestamp() { date +"%F_%T_%Z"; }

###############################
####### The init script #######
###############################

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "$(timestamp) Installing dependecies ... "
apt-get update
apt-get --yes install git wget curl unzip kpartx libarchive-zip-perl dos2unix
