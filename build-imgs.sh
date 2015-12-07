#!/bin/bash

#Set Pkg Build Version
IMG_VER=1.0.0
BUILD="Beta" # Beta/Release


#Set Timestamp in the change logs
TIME=$(date +"%a, %d %b %Y %X")


time dd if=/dev/$device of=/mnt/$FILE_NAME-$IMG_VER-$BUILD-$TIME.img bs-1024

gzip $FILE_NAME-$IMG_VER-$BUILD-$TIME.img

