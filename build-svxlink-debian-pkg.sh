#!/bin/bash

#set arch
i386="n"
amd64="n"
arm64="n"
armhf="y"

#Set Pkg Build Version
PKG_NAME=svxlink
PKG_VER=16.04
BUILD=b1
RELEASE=testing #testing/release/devel

#Set Repo Info
REPO=/home/repo/$PKG_NAME/$RELEASE/debian
#Set work dir
WRK_DIR=/usr/src/"$PKG_NAME"-build

#remove old build dir
rm 16*
rm -rf $WRK_DIR

#Get the main src
wget https://github.com/kb3vgw/$PKG_NAME/archive/$PKG_VER.tar.gz

#Build svxlink

mkdir $WRK_DIR

tar xzvf $PKG_VER.tar.gz -C $WRK_DIR

cd $WRK_DIR/$PKG_NAME-$PKG_VER || exit

dch -v $PKG_VER-$BUILD

cd $WRK_DIR/$PKG_NAME-$PKG_VER || exit

uscan --download-current-version

cd $WRK_DIR/$PKG_NAME-$PKG_VER || exit

if [[ $arm64 == "y" ]]; then
time dpkg-buildpackage -rfakeroot -i -j5 -us -uc --host-arch arm64
elif [[ $armhf == "y" ]]; then
time dpkg-buildpackage -rfakeroot -i -j5 -us -uc --host-arch armhf
elif [[ $amd64 == "y" ]]; then
time dpkg-buildpackage -rfakeroot -i -j5 -us -uc --host-arch amd64
elif [[ $i386 == "y" ]]; then
time dpkg-buildpackage -rfakeroot -i -j5 -us -uc --host-arch i386
fi

cd $WRK_DIR || exit

mkdir debs-svxlink-$PKG_VER || exit

mv *.deb debs-$PKG_NAME-$PKG_VER
mv *.changes debs-$PKG_NAME-$PKG_VER
mv *.xz debs-$PKG_NAME-$PKG_VER
mv *.dsc debs-$PKG_NAME-$PKG_VER
mv *.gz debs-$PKG_NAME-$PKG_VER

#cp -rp "$WRK_DIR"/debs-$PKG_NAME/"$REPO"/incoming || exit
#cd "$REPO" && ./import-new-pkgs.sh || exit