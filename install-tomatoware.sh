#!/bin/sh -e

echo "
script: install-tomatoware.sh
source: https://github.com/eduncan911/router

This script will attempt to install tomatoware, a build environment
by lancethepants, onto your USB stick."

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

if ! [ -b "${DRIVE}1" ]
then
    echo
    echo "${DRIVE}1 not found, exiting."
    exit 1
fi

echo
echo "Looking for the current mount point ..."
VOLUMENAME=$(echo -e ${DRIVE} | sed 's/\/dev\///')1
MOUNTPOINT=$(mount | grep -m 1 "${VOLUMENAME}" | awk '{print $3F}')
if [ -z "${MOUNTPOINT}" ]
then
    echo
    echo "HALT: Could not find a mount for ${DRIVE}"
    echo "Try unplugging the USB and plugging it back in to automount."
    echo "Or, log into your router's admin site and check the USB"
    echo "settings for automounting being enabled."
    echo
    echo "${DRIVE} not found, exiting."
    exit 1
fi
echo "Found ${MOUNTPOINT}"

if ! [ -d "${MOUNTPOINT}/tomatoware" ]
then
    echo "Creating directory: ${MOUNTPOINT}/tomatoware"
    mkdir -p ${MOUNTPOINT}/tomatoware
fi 

MMCMOUNT=$(mount | grep "/mmc" | awk '{print $3F}')
if [ -z "${MMCMOUNT}" ]
then
    echo "Mounting ${MOUNTPOINT}/tomatoware to /mmc ..."
    mount -o bind ${MOUNTPOINT}/tomatoware /mmc
fi

if ! [ -d "${MOUNTPOINT}/opt" ]
then
    echo "Creating directory: ${MOUNTPOINT}/opt"
    mkdir -p ${MOUNTPOINT}/opt
fi 

#OPTMOUNT=$(mount | grep "/opt" | awk '{print $3F}')
#if [ -z "${OPTMOUNT}" ]
#then
#    echo "Mounting ${MOUNTPOINT}/opt to /opt ..."
#    mount -o bind ${MOUNTPOINT}/opt /opt
#fi

DOWNLOADYES="y"
DOWNLOADFILE=${MOUNTPOINT}/tomatoware-arm-soft-mmc-1.0.3.tgz
if [ -e "${DOWNLOADFILE}" ]
then
    echo
    read -p "Re-download ${DOWNLOADFILE}? [y/N] " -n 1 -r
    echo
    if [ $REPLY = "y" ]
    then
        rm ${DOWNLOADFILE}
        DOWNLOADYES="y"
    else
        DOWNLOADYES="n"
    fi
fi
if [ "${DOWNLOADYES}" = "y" ]
then
    echo "Downloading to ${DOWNLOADFILE} ..." 
    wget https://github.com/lancethepants/tomatoware/releases/download/v1.0.3/arm-soft-mmc.tgz -O ${DOWNLOADFILE}
fi

echo "Extracting tomatoware into /mmc (this will take a long while)"
tar zxf ${DOWNLOADFILE} -C /mmc

#echo "Copying profile into /opt/etc/profile"
#if [ -e /opt/etc/profile] 
#then 
#    echo "Backing up /opt/etc/profile to /opt/etc/profile~"
#    mv /opt/etc/profile /opt/etc/profile~ 
#fi
#if ! [ -d /opt/etc ]
#then
#    mkdir /opt/etc
#fi
#cp /mmc/etc/profile /opt/etc/profile

echo "
tomatoware was downloaded to: 
  ${MOUNTPOINT}/tomatoware-arm-soft-mmc-1.0.3.tgz
tomatoware was extacted to:
  ${MOUNTPOINT}/tomatoware
tomatoware was mounted to:
  /mmc

Therefore, you will want to make this mount semi-perm by
adding these lines to your USB's \"Run after mounting\" script:

#!/bin/sh
if [ -d ${MOUNTPOINT}/tomatoware ]
then
  mount -o bind ${MOUNTPOINT}/tomatoware /mmc
fi
if [ -d ${MOUNTPOINT}/opt ]
then
  mount -o bind ${MOUNTPOINT}/opt /opt
fi

And add these lines to the \"Run before unmounting\":

#!/bin/sh
unmount /mmc
unmount /opt

Enjoy!
"
