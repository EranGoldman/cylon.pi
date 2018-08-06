#!/usr/bin/env bash
set -e

###############################
###### Image Constants ########
###############################

hostname="cylonpi"

###############################
### Installation Constants ####
###############################

installation_dir="/tmp/ownpi"
imagefile=$installation_dir/ownpi.img

###############################
### Some helpfull functions ###
###############################

timestamp() { date +"%F_%T_%Z"; }


###############################
###### The script itself ######
###############################

echo "$(timestamp) Installing dependecies ... "
apt-get update
apt-get --yes install git wget curl unzip kpartx libarchive-zip-perl dos2unix

echo "Creating folders  ... "
mkdir -p $(installation_dir)
mkdir -p $installation_dir/boot $installation_dir/root

echo "Downloading the last raspbian image ... "
wget -nv -O $installation_dir/raspbian.zip "https://downloads.raspberrypi.org/raspbian_lite_latest" > /dev/null

echo "Unzip and rename the raspbian image ... "
unzip $installation_dir/raspbian.zip -d $installation_dir
mv $installation_dir/*raspbian*.img $imagefile

echo "Mounting the image for modifications... "
PARTITIONS=($(kpartx -asv $imagefile | grep -o 'loop[0-9][0-9]*p[0-9]'))
mount -o rw -t vfat /dev/mapper/${PARTITIONS[0]} $buildfolder/boot
mount -o rw -t ext4 /dev/mapper/${PARTITIONS[1]} $buildfolder/root
