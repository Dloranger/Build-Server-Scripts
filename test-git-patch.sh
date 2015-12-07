#!/bin/sh
rm -rf /usr/src/svxlink
git clone git://github.com/rneese45/svxlink.git /usr/src/svxlink
cd /usr/src/svxlink
git pull git://github.com/rneese45/svxlink.git spelling-fixes
git pull git://github.com/rneese45/svxlink.git hypen-vs-minus
git pull git://github.com/rneese45/svxlink.git new-file-svxlink_gpio.conf.in
git pull git://github.com/rneese45/svxlink.git qt5-Update
git pull git://github.com/rneese45/svxlink.git fix-missing-home-enviroment
git pull git://github.com/rneese45/svxlink.git fix-init.d-script
git pull git://github.com/rneese45/svxlink.git svxlink-debian-pkg
git pull git://github.com/rneese45/svxlink.git systemd-new

cd /usr/src/svxlink/src
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DBUILD_STATIC_LIBS=YES .. # -DUSE_OSS=NO ..
make -j5
make doc
make install
ldconfig
