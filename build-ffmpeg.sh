gunzip ffmpeg-5.1.4.tar.gz
tar -xvf ffmpeg-5.1.4.tar
sudo apt update
sudo apt install gcc
sudo apt install yasm nasm
sudo apt install libmp3lame-dev
sudo apt install libx264-dev
sudo apt install pkgconf
sudo apt install make
sudo apt install librsvg2-dev
sudo apt install libxml2-dev
sudo apt install librust-pangocairo-dev
sudo apt install libgdk-pixbuf2.0-dev
sudo apt install libgdk-pixbuf-2.0-dev
sudo apt install librust-gdk-pixbuf-dev
curl -o librsvg-2.52.9.tar.xz https://src.fedoraproject.org/repo/pkgs/librsvg2/librsvg-2.52.9.tar.xz/sha512/16ba49266b6dd39e87b706817eaadb4ab4e60bd91b6d7a5e1e539fdcad8a628b517854ef3ac5ca54ba1b3e884467f04e04fcc4b7b29d506b3aef08553cf0d788/librsvg-2.52.9.tar.xz
xz -d librsvg-2.52.9.tar.xz
tar xvf librsvg-2.52.9.tar
cd librsvg-2.52.9
sudo apt install -y rustc cargo
sudo apt install -y automake autoconf libtool gtk-doc-tools git libgdk-pixbuf2.0-dev libgirepository1.0-dev libxml2-dev libcairo2-dev libpango1.0-dev
PATH="$PATH:/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0"
sudo apt install valac
./configure --enable-gtk-doc --enable-vala
make
sudo make install
cd ..
curl -o gdk-pixbuf-2.40.0.tar.xz https://download.gnome.org/sources/gdk-pixbuf/2.40/gdk-pixbuf-2.40.0.tar.xz
xz -d gdk-pixbuf-2.40.0.tar.xz
tar -xvf gdk-pixbuf-2.40.0.tar
cd gdk-pixbuf-2.40.0/
sudo apt install meson ninja-build
meson _build .
cd _build/
meson configure --default-library static
ninja
sudo ninja install
curl -o cairo-1.14.12.tar.xz https://www.cairographics.org/releases/cairo-1.14.12.tar.xz
xz -d cairo-1.14.12.tar.xz
tar xvf cairo-1.14.12.tar
cd cairo-1.14.12/
./configure --disable-shared --enable-static
make
sudo make install
gunzip util-linux-2.33.1.tar.gz
tar -xvf util-linux-2.33.1.tar
cd util-linux-2.33.1/
sudo apt install gettext
sudo apt install autopoint
sudo apt install bison
./autogen.sh
./configure --disable-all-programs --enable-static-programs --enable-libblkid --enable-libmount
make
sudo make install
cd ../../ffmpeg-5.1.4/
./configure --pkg-config-flags="--static" --extra-ldexeflags="-static" --enable-gpl --enable-version3 --enable-static --disable-shared --disable-debug --disable-ffplay --disable-indev=sndio --disable-outdev=sndio --cc=gcc --enable-libmp3lame --enable-libx264 --enable-librsvg
make
