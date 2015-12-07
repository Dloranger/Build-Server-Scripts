#!/bin/bash

#Set Pkg Build Version
PKGVER=1.0.0
BUILD=16

#set repo info
REPO=/home/repo/openrepeater/release/debian
WRK_DIR=/usr/src/openrepeater-build

#remove old build dir
rm -rf $WRK_DIR

#Set Timestamp in the change logs
TIME=$(date +"%a, %d %b %Y %X")

#Build svxlink
mkdir $WRK_DIR

cp -r /root/openrepeater-$PKGVER $WRK_DIR

cat > $WRK_DIR/openrepeater-$PKGVER/debian/changelog << DELIM
openrepeater ($PKGVER-$BUILD) stable; urgency=low

  * Initial release new openrepeater "$PKGVER"

 -- Richard Neese <kb3vgw@gmail.com>  Thur, 11 June 2015 15:19:23 -0500

DELIM

cd $WRK_DIR/openrepeater-$PKGVER

time dpkg-buildpackage -rfakeroot -i -us -uc

cd $WRK_DIR

mkdir debs-openrepeater-$PKGVER

mv *.deb debs-openrepeater-$PKGVER
mv *.changes debs-openrepeater-$PKGVER
mv *.gz debs-openrepeater-$PKGVER
mv *.dsc debs-openrepeater-$PKGVER

#cp -rp "$WRK_DIR"/debs-svxlink/* "$REPO"/incoming

#cd "$REPO" && ./import-new-pkgs.sh


