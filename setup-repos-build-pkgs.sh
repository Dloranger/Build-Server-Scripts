#!/bin/bash
pkg-name="svxlink"

repo1="release"
repo2="devel"
rep3="stable"

apt-get install -y cowbuilder devscripts g++ make cmake libsigc++-2.0-dev libgsm1-dev libpopt-dev libgcrypt11-dev \
	libspeex-dev libspeexdsp-dev libasound2-dev alsa-utils vorbis-tools sox flac libsox-fmt-mp3 sqlite3 unzip \
	opus-tools tcl8.6-dev tk-dev alsa-base ntp groff doxygen libopus-dev librtlsdr-dev git-core reprepro nginx \
	uuid-dev qtbase5-dev qttools5-dev-tools qttools5-dev git-core tk8.6-dev ntp flite screen time inetutils-syslogd \
	vim install-info whiptail dialog logrotate cron dh-systemd quilt

#Setup repos
#Stable repo
for i in conf incoming log tmp
do mkdir -p /home/repo/"$pkg-name"/"$repo1"/debian/"${i}"
done
#Head repo
for i in conf incoming log tmp
do mkdir -p /home/repo/"$pkg-name"/"$repo2"/debian/"${i}"
done

#Add conf files to repo
for i in "$repo1" "$repo2"
do /bin/cat > '/home/repo/"$pkg-name"/"${i}"/debian/conf/distributions'  <<DELIM
Origin: "$pkg-name"
Label: "$pkg-name"
Suite: stable
Codename: jessie
Components: main
Architectures: source amd64 i386 armhf
Description: "$pkg-name" Packages for Debian jessie
Contents: .gz
#SignWith: 25E010CF

DELIM
done

for i in "$repo1" "$repo2"
do /bin/cat >/home/repo/"$pkg-name"/"${i}"/debian/conf/incoming  <<DELIM
Name: all
IncomingDir: incoming
TempDir: tmp
LogDir: log
Allow: jessie stable>jessie jessie testing>jessie
Default: jessie
Options: multiple_distributions limit_arch_all
Cleanup: unused_files on_deny on_error
done

for i in "$repo1" "$repo2"
do cat >/home/repo/"$pkg-name"/"${i}"/debian/conf/  <<DELIM
#!/bin/sh
repo_ver="stable" # stable/head

INCOMING=/usr/home/repo/"$pkg-name"/"$repo_ver"/debian/incoming

#
# Make sure we're in the apt/ directory
#
cd $INCOMING
cd ..

#
#  See if we found any new packages
#
found=0
for i in $INCOMING/*.changes; do
  if [ -e $i ]; then
    found=`expr $found + 1`
  fi
done

#
#  If we found none then exit
#
if [ "$found" -lt 1 ]; then
   exit
fi

#
#  Now import each new package that we *did* find
#
for i in $INCOMING/*.changes; do

  # Import package to 'sarge' distribution.
  reprepro -Vb . include jessie $i

  # Delete the referenced files
  sed '1,/Files:/d' $i | sed '/BEGIN PGP SIGNATURE/,$d' \
       | while read MD SIZE SECTION PRIORITY NAME; do

      if [ -z "$NAME" ]; then
           continue
      fi

      #
      #  Delete the referenced file
      #
      if [ -f "$INCOMING/$NAME" ]; then
          rm "$INCOMING/$NAME"  || exit 1
      fi
  done

  # Finally delete the .changes file itself.
  rm  $i
done
DELIM

