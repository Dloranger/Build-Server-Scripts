#!/bin/bash

PKGVER=4.2.0-31 # this is the version number you update
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

##set version in the changelog files for core
cat > $WRK_DIR/fusionpbx/debian/changelog << DELIM
fusionpbx-core ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx/core

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM

##set version in the changelog files for conf files
cat > $WRK_DIR/fusionpbx/resources/templates/conf/debian/changelog << DELIM
fusionpbx-conf ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx/conf

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM

##set version in the changelog files for scripts
cat > $WRK_DIR/fusionpbx/resources/install/scripts/debian/changelog << DELIM
fusionpbx-scripts ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx/scripts

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM


##set version in the changelog files for sqldb
cat > $WRK_DIR/fusionpbx/resources/install/sql/debian/changelog << DELIM
fusionpbx-sqldb ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx/sqldb

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM

##set version in the changelog files for provisioing templates
for i in aastra atcom cisco digium escene grandstream linksys mitel panasonic polycom snom yealink
do cat > $WRK_DIR/fusionpbx/resources/templates/provision/"${i}"/debian/changelog << DELIM
fusionpbx-provisioning-template-${i} ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx-provisioning-template-${i//_/-}

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM
done

#set version in the changelog files for themes
for i in default
do cat > $WRK_DIR/fusionpbx/themes/"${i}"/debian/changelog << DELIM
fusionpbx-theme-${i} ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx-theme-${i}

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM
done

#set version in the changelog files for app
for i in access_controls adminer backup call_block call_broadcast call_centers call_center_active call_flows calls \
        calls_active click_to_call conference_centers conferences conferences_active contacts destinations devices \
        dialplan dialplan_inbound dialplan_outbound edit emails exec extensions fax fifo fifo_list follow_me gateways \
        ivr_menus log_viewer meetings modules music_on_hold operator_panel phrases provision recordings registrations \
        ring_groups scripts services settings sip_profiles sip_status system time_conditions traffic_graph vars \
        voicemail_greetings voicemails xml_cdr
do cat > $WRK_DIR/fusionpbx/app/"${i}"/debian/changelog << DELIM
fusionpbx-app-${i//_/-} ($PKGVER) stable; urgency=low

  * new deb pkg for fusionpbx-app-${i//_/-}

 -- FusionPBX <debian@fusionpbx.com>  $TIME +1200

DELIM
done

#patch config files
#remove unused extensions from configs dir
for i in "$WRK_DIR"/fusionpbx/resources/templates/conf/directory/default/*.noload ;do rm "$i" ; done

#fix sounds dir
sed "$WRK_DIR"/fusionpbx/resources/templates/conf/autoload_configs/local_stream.conf.xml -i -e s,'<directory name="default" path="$${sounds_dir}/music/8000">','<directory name="default" path="$${sounds_dir}/music/fusionpbx/default/8000">',g
sed "$WRK_DIR"/fusionpbx/resources/templates/conf/autoload_configs/local_stream.conf.xml -i -e s,'<directory name="moh/8000" path="$${sounds_dir}/music/8000">','<directory name="moh/8000" path="$${sounds_dir}/music/fusionpbx/default/8000">',g
sed "$WRK_DIR"/fusionpbx/resources/templates/conf/autoload_configs/local_stream.conf.xml -i -e s,'<directory name="moh/16000" path="$${sounds_dir}/music/16000">','<directory name="moh/16000" path="$${sounds_dir}/music/fusionpbx/default/16000">',g
sed "$WRK_DIR"/fusionpbx/resources/templates/conf/autoload_configs/local_stream.conf.xml -i -e s,'<directory name="moh/32000" path="$${sounds_dir}/music/32000">','<directory name="moh/32000" path="$${sounds_dir}/music/fusionpbx/default/32000">',g
sed "$WRK_DIR"/fusionpbx/resources/templates/conf/autoload_configs/local_stream.conf.xml -i -e s,'<directory name="moh/48000" path="$${sounds_dir}/music/48000">','<directory name="moh/48000" path="$${sounds_dir}/music/fusionpbx/default/48000">',g

#Adding changes to freeswitch profiles
#Enableing device login auth failures ing the sip profiles.
sed "$WRK_DIR"/fusionpbx/resources/templates/conf/sip_profiles/internal.xml.noload -i -e s,'<param name="log-auth-failures" value="false"/>','<param name="log-auth-failures" value="true"/>',g

sed "$WRK_DIR"/fusionpbx/resources/templates/conf/sip_profiles/internal.xml.noload -i -e s,'<!-- *<param name="log-auth-failures" value="false"/>','<param name="log-auth-failures" value="true"/>', \
    -e s,'<param name="log-auth-failures" value="false"/> *-->','<param name="log-auth-failures" value="true"/>', \
    -e s,'<!--<param name="log-auth-failures" value="false"/>','<param name="log-auth-failures" value="true"/>', \
    -e s,'<param name="log-auth-failures" value="false"/>-->','<param name="log-auth-failures" value="true"/>',g


#Build pkgs
#build app pkgs
for i in access_controls adminer backup call_block call_broadcast call_centers call_center_active call_flows calls \
        calls_active click_to_call conference_centers conferences conferences_active contacts destinations devices \
        dialplan dialplan_inbound dialplan_outbound edit emails exec extensions fax fifo fifo_list follow_me gateways \
        ivr_menus log_viewer meetings modules music_on_hold operator_panel phrases provision recordings registrations \
        ring_groups scripts services settings sip_profiles sip_status system time_conditions traffic_graph vars \
        voicemail_greetings voicemails xml_cdr
do cd $WRK_DIR/fusionpbx/app/"${i}"
dpkg-buildpackage -rfakeroot -i
done

#build core pkg
cd "$WRK_DIR"/fusionpbx
dpkg-buildpackage -rfakeroot -i

#Build conf pkg
cd "$WRK_DIR"/fusionpbx/resources/templates/conf
dpkg-buildpackage -rfakeroot -i

#Build scripts pkg
cd "$WRK_DIR"/fusionpbx/resources/install/scripts
dpkg-buildpackage -rfakeroot -i

#Build sql pkg
cd "$WRK_DIR"/fusionpbx/resources/install/sql
dpkg-buildpackage -rfakeroot -i

#Build provision pkg
for i in aastra atcom cisco digium escene grandstream linksys mitel panasonic polycom snom yealink
do cd $WRK_DIR/fusionpbx/resources/templates/provision/"${i}"
dpkg-buildpackage -rfakeroot -i
done

#build theme pkgs
for i in default
do cd $WRK_DIR/fusionpbx/themes/"${i}"
dpkg-buildpackage -rfakeroot -i
done

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
