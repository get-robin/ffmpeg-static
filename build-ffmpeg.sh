gunzip ffmpeg-5.1.4.tar.gz
tar -xvf ffmpeg-5.1.4.tar
cd ffmpeg-5.1.4/
sudo apt update
sudo apt install gcc
sudo apt install yasm nasm
sudo apt install libmp3lame-dev
sudo apt install libx264-dev
sudo apt install pkgconf
sudo apt install make
./configure --pkg-config-flags="--static" --extra-ldexeflags="-static" --enable-gpl --enable-version3 --enable-static --disable-debug --disable-ffplay --disable-indev=sndio --disable-outdev=sndio --cc=gcc --enable-libmp3lame --enable-libx264
make
