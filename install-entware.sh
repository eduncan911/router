


echo
echo "Create auto-mount scripts for /mmc and /opt ..."


echo
echo "Mounting /mmc and /opt, to be usable immediately."
[ -d /mmc ] || mkdir /mmc
mount ${DRIVE}1 /mmc
[ -d /opt ] || mkdir /opt
mount ${DRIVE}2 /opt

echo
echo "Your USB stick has now been prepared with two partitions:"
echo
echo "  /mmc - 1GB in size, can be used for tomatoware."
echo "  /opt - remaining disk space, can be used for entware/optware,"
echo "         config file storage, downloads, swapfile, etc."
echo
echo "Note: A swapfile is useful if your router has less than 64MB of ram."
echo "If you have less than 64MB, create a Linux Swapfile on your"
echo "/data partition that was just created.  You can do this with entware"
echo "or optware once they are installed.  I choose not to setup a designated"
echo "partition for swap to keep it adjustable. Just remember to seed the entire"
echo "swapfile first and there will not be any performance issues."
echo
echo "Enjoy!"

