#!/bin/sh

set -e
set -u

jflag=
jval=2
rebuild=0
download_only=0
uname -mpi | grep -qE 'x86|i386|i686' && is_x86=1 || is_x86=0

while getopts 'j:Bd' OPTION
do
  case $OPTION in
  j)
      jflag=1
      jval="$OPTARG"
      ;;
  B)
      rebuild=1
      ;;
  d)
      download_only=1
      ;;
  ?)
      printf "Usage: %s: [-j concurrency_level] (hint: your cores + 20%%) [-B] [-d]\n" $(basename $0) >&2
      exit 2
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$jflag" ]
then
  if [ "$jval" ]
  then
    printf "Option -j specified (%d)\n" $jval
  fi
fi

[ "$rebuild" -eq 1 ] && echo "Reconfiguring existing packages..."
[ $is_x86 -ne 1 ] && echo "Not using yasm or nasm on non-x86 platform..."

cd `dirname $0`
ENV_ROOT=`pwd`
. ./env.source

# check operating system
OS=`uname`
platform="unknown"

case $OS in
  'Darwin')
    platform='darwin'
    ;;
  'Linux')
    platform='linux'
    ;;
esac

#if you want a rebuild
#rm -rf "$BUILD_DIR" "$TARGET_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DOWNLOAD_DIR" "$BIN_DIR"

#download and extract package
download(){
  filename="$1"
  if [ ! -z "$2" ];then
    filename="$2"
  fi
  ../download.pl "$DOWNLOAD_DIR" "$1" "$filename" "$3" "$4"
  #disable uncompress
  REPLACE="$rebuild" CACHE_DIR="$DOWNLOAD_DIR" ../fetchurl "http://cache/$filename"
}

echo "#### FFmpeg static build ####"

#this is our working directory
cd $BUILD_DIR

download \
  "x264-stable.tar.gz" \
  "" \
  "91539513b13ffdc46947d6128407958e" \
  "https://code.videolan.org/videolan/x264/-/archive/stable/"

download \
  "lame-3.100.tar.gz" \
  "" \
  "83e260acbe4389b54fe08e0bdbf7cddb" \
  "http://downloads.sourceforge.net/project/lame/lame/3.100"

download \
  "librsvg-2.50.7.tar.gz" \
  "" \
  "" \
  "https://gitlab.gnome.org/GNOME/librsvg/-/archive/2.50.7/"

download \
  "n6.0.tar.gz" \
  "ffmpeg6.0.tar.gz" \
  "586ca7cc091d26fd0a4c26308950ca51" \
  "https://github.com/FFmpeg/FFmpeg/archive"

[ $download_only -eq 1 ] && exit 0

TARGET_DIR_SED=$(echo $TARGET_DIR | awk '{gsub(/\//, "\\/"); print}')

echo "*** Building x264 ***"
cd $BUILD_DIR/x264*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-asm --disable-opencl --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building mp3lame ***"
cd $BUILD_DIR/lame*
# The lame build script does not recognize aarch64, so need to set it manually
uname -a | grep -q 'aarch64' && lame_build_target="--build=arm-linux" || lame_build_target=''
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-nasm --disable-shared $lame_build_target
make
make install

echo "*** Building librsvg ***"
cd $BUILD_DIR/librsvg-*
./autogen.sh --prefix=$TARGET_DIR --disable-shared --enable-static
./configure
make -j $jval
make install

# FFMpeg
echo "*** Building FFmpeg ***"
cd $BUILD_DIR/FFmpeg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true

if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="$TARGET_DIR/lib/pkgconfig" ./configure \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-libs="-lpthread -lm -lz" \
    --extra-ldexeflags="-static" \
    --bindir="$BIN_DIR" \
    --enable-gpl \
    --enable-libmp3lame \
    --enable-librsvg \
    --enable-libx264
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="${TARGET_DIR}/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/Cellar/openssl/1.0.2o_1/lib/pkgconfig" ./configure \
    --cc=/usr/bin/clang \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-ldexeflags="-Bstatic" \
    --bindir="$BIN_DIR" \
    --enable-gpl \
    --enable-libmp3lame \
    --enable-librsvg \
    --enable-libx264
fi

PATH="$BIN_DIR:$PATH" make -j $jval
make install
make distclean
hash -r
