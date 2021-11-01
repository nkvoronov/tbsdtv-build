#!/bin/bash

URL_GIT_BUILD="https://github.com/tbsdtv/media_build.git"
URL_GIT_MEDIA="https://github.com/tbsdtv/linux_media.git"
DIR_SOURCE="source"
DIR_BUILD="build"
DIR_PATCHES="patches"
DIR_MEDIA="media"
DIR_MEDIA_BUILD="media_build"
DIR_MODULES="modules"

BUILD="/media/Devel/tbsdtv-build/LE"
TARGET_KERNEL_ARCH=x86
TARGET_NAME="x86_64-libreelec-linux-gnu"
TOOLCHAIN=$BUILD/toolchain
TARGET_PREFIX=$TOOLCHAIN/bin/$TARGET_NAME-
TARGET_KERNEL_PREFIX=$TARGET_PREFIX
MAKE="$TOOLCHAIN/bin/make"
HOST_CPPFLAGS=""
HOST_CFLAGS="-march=native -O2 -Wall -pipe -I$TOOLCHAIN/include"
HOST_CXXFLAGS="$HOST_CFLAGS"
HOST_LDFLAGS="-Wl,-rpath,$TOOLCHAIN/lib -L$TOOLCHAIN/lib"

setup_pkg_config_host() {
  export PKG_CONFIG="$TOOLCHAIN/bin/pkg-config"
  export PKG_CONFIG_PATH=""
  export PKG_CONFIG_LIBDIR="$TOOLCHAIN/lib/pkgconfig:$TOOLCHAIN/share/pkgconfig"
  export PKG_CONFIG_SYSROOT_BASE=""
  export PKG_CONFIG_SYSROOT_DIR=""
  unset PKG_CONFIG_ALLOW_SYSTEM_CFLAGS
  unset PKG_CONFIG_ALLOW_SYSTEM_LIBS
}

kernel_make() {
  (
    setup_pkg_config_host

    LDFLAGS="" make CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
      ARCH="$TARGET_KERNEL_ARCH" \
      HOSTCC="$TOOLCHAIN/bin/host-gcc" \
      HOSTCXX="$TOOLCHAIN/bin/host-g++" \
      HOSTCFLAGS="$HOST_CFLAGS" \
      HOSTLDFLAGS="$HOST_LDFLAGS" \
      HOSTCXXFLAGS="$HOST_CXXFLAGS" \
      DEPMOD="$TOOLCHAIN/bin/depmod" \
      "$@"
  )
}

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
cd ../..

cd $DIR_BUILD/$DIR_MEDIA_BUILD
for f in *.patch; do patch -p1 < "$f"; done

export KERNEL_VER="5.10.47"
export LDFLAGS=""

KERNEL_PATH=${BUILD}/build/linux-5.10.47

#  build
make dir DIR=../media
kernel_make VER=${KERNEL_VER} SRCDIR=${KERNEL_PATH} allyesconfig
kernel_make VER=${KERNEL_VER} SRCDIR=${KERNEL_PATH}
cd ../..

# modules
if [ -d $DIR_MODULES ]; then
  rm -rf $DIR_MODULES
fi
mkdir $DIR_MODULES
find $DIR_BUILD/$DIR_MEDIA_BUILD/v4l -name \*.ko -exec cp {} $DIR_MODULES \;

#CUR_KERNEL=$(uname -r)
#DIR_DEST="/usr/lib/modules/"$CUR_KERNEL"/updates/tbs"

#mkdir -p $DIR_DEST
#sudo make install