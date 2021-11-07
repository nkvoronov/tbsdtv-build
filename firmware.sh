#!/bin/bash

ROOT=$(pwd)
DIR_FIRMWARE="firmware"

#  get firmware
if [ -d $DIR_FIRMWARE ]; then
  rm -rf $DIR_FIRMWARE
fi
mkdir $DIR_FIRMWARE

wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2
tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C $ROOT/$DIR_FIRMWARE