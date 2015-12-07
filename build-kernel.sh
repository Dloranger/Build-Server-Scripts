#!/bin/bash

# ------ edit here --------
board=odroidc   #Select your board  model
kernel=uImage   #Select your kernel img type uImage/zImage
kern_ver=3.10.y #Select your kernel version
menu_config="n" #Select to run menuconfig if adding in more options
base=~   #dir where to put the src
custom_config="n"
# ------ end edit here ------

set -e

###############################
# git clone / update kernel src
###############################
if [ ! -f $base/"$board"-"$kern_ver" ]; then
git clone --depth 1 https://github.com/hardkernel/linux -b "$board"-"$kern_ver" $base/"$board"-"$kern_ver" || { echo "command make git clone failed"; exit 1; }
else
#cd to working kernel dir
cd $base/"$board"-"$kern_ver" || { echo "Directory $base/$board-$kern_ver does not exist"; exit 1; }
#cleaning up the src dir
make mrproper || { echo "command make mrproper failed"; exit 1; }
# git pull to update kernel src
sudo git pull || { echo "command git pull failed"; exit 1; }
fi

######################################################
# Build Kernel + System map + modules + device tree
######################################################

#cd to kernel source dir
cd /usr/src/"$board"-"$kern_ver" || exit

#cleaning the source dir for safty
sudo make mrproper || { echo "command make mrproper failed"; exit 1; }

# cp the default board config into place
if [[ $custom_config == "y"]]; then
cp /root/$kern_config /usr/src/"$board"-"$kern_ver"/.config || { echo "copy failed the config file does not exist"; exit 1; }
make configold || { echo "make configold failed please check your config file"; exit 1; }
else
make "$board"_defconfig || { echo "command make \"$board\"_defconfig failed"; exit 1; }
fi

# If selected runs menuconfig
if [[ $menu_config == "y" ]]; then
make menuconfig || { echo "command make menuconfig failed"; exit 1; }
fi

# runs make
make -j5 || { echo "command make failed"; exit 1; }

#make the kernel file
make $kernel || { echo "command make $kernel failed"; exit 1; }

# builds kernel modules
make modules || { echo "command make modules failed"; exit 1; }

# builds the device tree files
make dtbs || { echo "command make dtbs failed"; exit 1; }

######################################################
# Install Kernel + System map + modules + device tree 
######################################################
# Installs modules for your kernel build
sudo make modules_install || { echo "command make modules_install failed"; exit 1; }

# replaces the System.map
if [ -f $base/"$board"-"$kern_ver/arch/arm/boot/System.map " ]; then
sudo cp $base/"$board"-"$kern_ver"/arch/arm/boot/System.map /media/boot
else
echo " $base/$board-$kern_ver/arch/arm/boot/System.map does not exist. Unable to copy it into place "
exit 1
fi

# replaces the $kernel boot image
if [ -f $base/"$board"-"$kern_ver"/arch/arm/boot/"$kernel" ]; then
cp $base/"$board"-"$kern_ver"/arch/arm/boot/$kernel /media/boot
else
echo " $base/$board-$kern_ver/arch/arm/boot/$kernel does not exist. Unable to copy it into place "
exit 1
fi

# replaces meson2b_"$board".dtb boot tree file
if [ -f $base/"$board"-"$kern_ver"/arch/arm/boot/dts/meson2b_"$board".dtb ]; then
cp $base/"$board"-"$kern_ver"/arch/arm/boot/dts/meson2b_"$board".dtb /media//boot
else
echo " $base/$board-$kern_ver/arch/arm/boot/dts/meson2b_$board.dtb does not exist. Unable to copy it into place "
exit 1
fi

# replace meson2b_"$board".dts boot tree file
if [ -f $base/"$board"-"$kern_ver"/arch/arm/boot/dts/meson2b_"$board".dtb ]; then
cp $base/"$board"-"$kern_ver"/arch/arm/boot/dts/meson2b_"$board".dts /media/boot
else
echo " $base/$board-$kern_ver/arch/arm/boot/dts/meson2b_$board.dtb does not exist. Unable to copy it into place "
exit 1
fi

echo " ########################################################################################## "
echo " #                 Your custom built Kernel is now compiled and installed                 # "
echo " #                           and your kernel is ready for use..                           # "
echo " #                       Please Reboot to Enable your new Kernel                          # "
echo " #                                                                                        # "
echo " #                     Please send any feed back to kb3vgw@gmail.com                      # "
echo " ########################################################################################## "

