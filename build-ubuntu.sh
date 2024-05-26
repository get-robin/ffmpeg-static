#!/bin/bash

sudo apt-get install build-essential curl tar pkg-config gtk-doc-tools autopoint libgtk-3-dev libgirepository1.0-dev rust-all gettext
sudo apt-get -y --force-yes install \
  autoconf \
  automake \
  build-essential \
  cmake \
  frei0r-plugins-dev \
  gawk \
  libass-dev \
  libfreetype6-dev \
  libopencore-amrnb-dev \
  libopencore-amrwb-dev \
  libsdl1.2-dev \
  libspeex-dev \
  libssl-dev \
  libtheora-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvo-amrwbenc-dev \
  libvorbis-dev \
  libwebp-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libxvidcore-dev \
  pkg-config \
  texi2html \
  yasm \
  nasm \
  zlib1g-dev

ln -s /usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/gdk-pixbuf-query-loaders /usr/local/bin/gdk-pixbuf-query-loaders

./build.sh "$@"

