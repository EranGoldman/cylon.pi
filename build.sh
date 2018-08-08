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
destinationfolder='.' # Without trailing slash

###############################
### Some helpfull functions ###
###############################

timestamp() { date +"%F_%T_%Z"; }


###############################
###### The script itself ######
###############################
timestamp=$(date +%Y%m%d%H%M)

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Creating folders  ... "
mkdir -p $installation_dir
mkdir -p $installation_dir/boot $installation_dir/root

echo "Downloading the last raspbian image ... "
wget -nv -O $installation_dir/raspbian.zip "https://downloads.raspberrypi.org/raspbian_lite_latest" > /dev/null

echo "Unzip and rename the raspbian image ... "
unzip $installation_dir/raspbian.zip -d $installation_dir
mv $installation_dir/*raspbian*.img $imagefile

echo "Mounting the image for modifications... "
PARTITIONS=($(kpartx -asv $imagefile | grep -o 'loop[0-9][0-9]*p[0-9]'))
mount -o rw -t vfat /dev/mapper/${PARTITIONS[0]} $installation_dir/boot
mount -o rw -t ext4 /dev/mapper/${PARTITIONS[1]} $installation_dir/root

echo "Updating hosts and ssh files ... "
sed -i "s/127.0.1.1.*/127.0.1.1 $hostname/" $installation_dir/root/etc/hosts
touch $installation_dir/boot/ssh
echo "$hostname" > $installation_dir/root/etc/hostname


echo "Ijecting files to the image ... "
cp image_files/rc.local $installation_dir/root/etc/rc.local
cp image_files/first-boot.sh $installation_dir/boot/first-boot.sh
touch $installation_dir/boot/first-boot.log

echo "Closing up image file... "
kpartx -u $imagefile
sleep 2
sync
sleep 2
umount $installation_dir/boot
umount $installation_dir/root
kpartx -dv $imagefile

echo "Moving image and cleaning up... "
shorthash=$(git log --pretty=format:'%h' -n 1)
crc32checksum=$(crc32 $imagefile)
destination="$destinationfolder/$hostname-$timestamp-git$shorthash-crc$crc32checksum.img"
# read -n1 -r -p "Press space to continue..." key
mv -v $imagefile "$destination"
rm -rf $installation_dir

# echo "Compressing image... "
# xz --verbose --compress --keep "$destination"
# crc32checksum=$(crc32 "$destination.xz")
# mv "$destination.xz" "$hostname-$timestamp-git$shorthash-crc$crc32checksum.img.xz"

echo "Finished! The results:"
ls -alh "$hostname-$timestamp"*
