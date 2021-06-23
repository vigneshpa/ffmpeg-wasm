#!/bin/bash

#loading emsdk
source $EMSDK/emsdk_env.sh

# config
DIST_DIR=../package/dist/bin

#into the ffpmeg directory
cd ffmpeg

# verify Emscripten version
emcc -v

# configure FFMpeg with Emscripten
CFLAGS="-s USE_PTHREADS"
CXXFLAGS="$CFLAGS"
LDFLAGS="$CFLAGS -s INITIAL_MEMORY=33554432 -s ENVIRONMENT=web,worker -s MODULARIZE -s EXPORT_NAME=FFmpegFactory -s EXIT_RUNTIME" # 33554432 bytes = 32 MB
CONFIG_ARGS=(
  --target-os=none        # use none to prevent any os specific configurations
  --arch=x86_32           # use x86_32 to achieve minimal architectural optimization
  --enable-cross-compile  # enable cross compile
  --disable-x86asm        # disable x86 asm
  --disable-inline-asm    # disable inline asm
  --disable-stripping     # disable stripping
  # --disable-programs      # disable programs build (incl. ffplay, ffprobe & ffmpeg)
  --disable-doc           # disable doc
  --disable-debug         # disabling debug symbols
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CXXFLAGS"
  --extra-ldflags="$LDFLAGS"
  --nm="llvm-nm -g"
  --ar=emar
  # --as=llvm-as
  --ranlib=llvm-ranlib
  --cc=emcc
  --cxx=em++
  --objcc=emcc
  --dep-cc=emcc
# licence options
  --enable-gpl
  --enable-version3
# lib options
  # # --enable-avisynth
  # # --disable-cuda-llvm
  # --enable-lto
  # --enable-fontconfig
  # # --enable-libaom
  # --enable-libass
  # # --enable-libdav1d
  # --enable-libfreetype
  # --enable-libfribidi
  # # --enable-libgsm
  # # --enable-libiec61883
  # # --enable-libjack
  # # --enable-libmfx
  # # --enable-libmodplug
  # --enable-libmp3lame
  # # --enable-libopencore_amrnb
  # # --enable-libopencore_amrwb
  # --enable-libopenjpeg
  # --enable-libopus
  # # --enable-libpulse
  # # --enable-librav1e
  # --enable-librsvg
  # --enable-libsoxr
  # # --enable-libspeex
  # --enable-libsrt
  # # --enable-libssh
  # # --enable-libsvtav1
  # --enable-libtheora
  # --enable-libvidstab
  # --enable-libvmaf
  # --enable-libvorbis
  # --enable-libzimg
  # --enable-libxvid
  # # --enable-libxml2
  # --enable-libx264
  # --enable-libx265
  # --enable-libwebp
  # --enable-libvpx
)
emconfigure ./configure "${CONFIG_ARGS[@]}"

# build ffmpeg
emmake make -j3

# making dist
mkdir -p $DIST_DIR

# build ffmpeg.wasm
cp ./ff*_g* $DIST_DIR/
cd $DIST_DIR
for f in *_g; do
    mv -- "$f" "${f%_g}.js"
done