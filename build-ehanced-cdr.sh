#!/bin/bash

PKGVER=4.2.0-26 # this is the version number you update
GIT_SRC=https://github.com/kb3vgw/fusionpbx.git
REPO=/home/repo/fusionpbx/debian
WRK_DIR=/usr/src/fusionpbx-pkg-build
WRK_SRC_DIR=/usr/src/fusionpbx-pkg-build/fusionpbx

#Set Timestamp in the change logs
TIME=$(date +"%a, %d %b %Y %X")

#remove old working dir
rm -rf $WRK_DIR

#get pkg system scripts
git clone -b Debian-pkgs $GIT_SRC "$WRK_SRC_DIR"/

#set version in the changelog files for app
for i in enhanced-cdr-importer
do cat > $WRK_DIR/fusionpbx/app/"${i}"/debian/changelog << DELIM
fusionpbx-app-${i//_/-} ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx-app-${i//_/-}

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM
done

#Build sql pkg
cd "$WRK_DIR"/fusionpbx/resources/install/sql
dpkg-buildpackage -rfakeroot -i

cd "$WRK_DIR"
mkdir -p "$WRK_DIR"/debs-fusionpbx-jessie

for i in "$WRK_DIR" "$WRK_DIR"/fusionpbx/app "$WRK_DIR"/fusionpbx/themes "$WRK_DIR"/fusionpbx/resources/templates/provision "$WRK_DIR"/fusionpbx/resources/templates "$WRK_DIR"/fusionpbx/resources/install
do
mv "${i}"/*.deb "$WRK_DIR"/debs-fusionpbx-jessie
mv "${i}"/*.changes "$WRK_DIR"/debs-fusionpbx-jessie
mv "${i}"/*.gz "$WRK_DIR"/debs-fusionpbx-jessie
mv "${i}"/*.dsc "$WRK_DIR"/debs-fusionpbx-jessie
done

cp -rp "$WRK_DIR"/debs-fusionpbx-jessie/* "$REPO"/incoming

cd "$REPO" && ./import-new-pkgs.sh
