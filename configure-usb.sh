#!/bin/sh -e

echo "
script: configure-usb.sh
source: https://github.com/eduncan911/router

This script fully erases your USB stick and configures it with the 
following Linux partition, using all avaliable space.

	/usb

WARNING: Your USB stick must be plugged in but UNMOUNTED, or you will get
errors.  Log into your router and browse to your USB settings and click 
UNMOUNT before continuing.
"

DRIVE=$USB_DRIVE
if [ -z "$USB_DRIVE" ]; then
  DRIVE="/dev/sda"
  echo "
WARNING: USB_DRIVE environment variable not set.  We will default to:

	${DRIVE}

You might want to verify this is the correct drive by inspecting the
output of fdisk.  Run this command and look for /dev/sd[?]:

	# fdisk -l

You can change the drive used with this command:

	# export USB_DRIVE=/dev/sdc

Replacing /dev/sdc with the correct drive."
fi  

echo
read -p "Do you want to continue on ${DRIVE}? [y/N] " -n 1 -r
echo 
if ! [ $REPLY = "y" ]
then
    echo "Aborted."
    exit 1
fi

echo
echo "Erasing $DRIVE ..."
dd if=/dev/zero of=${DRIVE} bs=512 count=1 conv=notrunc

echo
echo "Creating partitions ..."
echo -e "n\np\n1\n\n\nw\nq\n" | fdisk ${DRIVE} >> /dev/null
fdisk -l /dev/sda

echo
echo "Formatting 'usb' with ext2 file system ..."
mkfs.ext2 -m 1 -L usb ${DRIVE}1

echo
echo "Cleaning up tmp mount points ..."
VOLUMENAME=$(echo -e ${DRIVE} | sed 's/\/dev\///')1
MOUNTPOINT=$(mount | grep -m 1 "${VOLUMENAME}" | awk '{print $3F}')
umount -l ${MOUNTPOINT}

echo "
Your USB stick has now been prepared with one partition:

    /usb

Please REMOVE and RE-INSERT the USB device for your firmware
to automount.  Check to see if it was re-mounted by running:

    mount | grep ${DRIVE}

If wanting to install entware and/or tomatoware, visit:

htts://github.com/eduncan911/router

Enjoy!
"

