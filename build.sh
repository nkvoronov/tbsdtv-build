#!/bin/bash

URL_GIT_BUILD="https://github.com/tbsdtv/media_build.git"
URL_GIT_MEDIA="https://github.com/tbsdtv/linux_media.git"
DIR_SOURCE="source"
#DIR_SOURCE="source_save"
DIR_BUILD="build"
DIR_PATCHES="patches"
DIR_MEDIA="media"
DIR_MEDIA_BUILD="media_build"
CUR_KERNEL=$(uname -r)
ROOT=$(pwd)
DIR_DEST="/usr/lib/modules/"$CUR_KERNEL"/updates/tbs"

#  get source
if [ ! -d $DIR_SOURCE ]; then
  mkdir $DIR_SOURCE
  cd $DIR_SOURCE
  git clone $URL_GIT_BUILD -b extra
  git clone --depth=1 $URL_GIT_MEDIA -b latest ./media
  cd ..
fi

#  update source
cd $DIR_SOURCE/media
git remote update
git pull
cd ../media_build
git remote update
git pull
cd ../..

#  build dir
if [ -d $DIR_BUILD ]; then
  rm -rf $DIR_BUILD
fi
mkdir $DIR_BUILD
cp -PR $DIR_SOURCE/* $DIR_BUILD

#  patches
cp -PR $DIR_PATCHES/$DIR_MEDIA/* $DIR_BUILD/$DIR_MEDIA
cp -PR $DIR_PATCHES/$DIR_MEDIA_BUILD/* $DIR_BUILD/$DIR_MEDIA_BUILD

cd $DIR_BUILD/$DIR_MEDIA
for f in *.patch; do patch -p1 < "$f"; done

#fix
#cp -P ../../$DIR_PATCHES/si2157.c drivers/media/tuners/

cd ../..

cd $DIR_BUILD/$DIR_MEDIA_BUILD
for f in *.patch; do patch -p1 < "$f"; done

#  build
make dir DIR=../media
make allyesconfig
make -j4

# install
sudo make install
