#!/bin/bash

# Wasm memory options
WASM_MEMORY=512                                    # Initial memory in Mega Bytes
MEMORY_GROWTH=0                                    # Wheater to allow memory growth
WORKER_THREADS='navigator.hardwareConcurrency-1'   # Setting thread pool to no of cores -1
DIST_DIR=./package/dist/bin                        # directory to save compiled files
FFMPEG_BUILD_DIR=./build                           # directory to builf ffmpeg

# exit if anyting fails
set -euo pipefail

# making directories
mkdir -p $DIST_DIR
mkdir -p $FFMPEG_BUILD_DIR

# loading emsdk environment variables
source $EMSDK/emsdk_env.sh

# adding llvm to path
export PATH=$EMSDK/upstream/bin:$PATH


# verify Emscripten existance
emcc -v

# Environment variables for emsdk and llvm
export EM_PKG_CONFIG_PATH=$FFMPEG_BUILD_DIR/lib/pkgconfig
export TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake

# initial memory for wasm file
INITIALM=$(($WASM_MEMORY * 1024 * 1024))

# Compiler and linker flags
COMPILER_FLAGS=(
    # -o3
    -pthread
)
COMPILER_FLAGS="${COMPILER_FLAGS[@]}"


LINKER_FLAGS=(
    -s PTHREAD_POOL_SIZE="$WORKER_THREADS"
    -s INITIAL_MEMORY=$INITIALM
    -s ALLOW_MEMORY_GROWTH=$MEMORY_GROWTH
    -s PTHREAD_POOL_SIZE_STRICT=2
    -s PTHREADS_DEBUG=1
    -s USE_SDL=2
    -s INVOKE_RUN
    -s EXIT_RUNTIME
    -s ENVIRONMENT=web,worker
    -s MODULARIZE
    -s EXPORT_NAME=FFmpegFactory
    -s EXPORTED_RUNTIME_METHODS="[FS,WORKERFS,IDBFS]"
    -lidbfs.js
    -lworkerfs.js
)
LINKER_FLAGS="${LINKER_FLAGS[@]}"

# export EMCC_CFLAGS="$COMPILER_FLAGS $LINKER_FLAGS"

# configure flags
CONFIG_FLAGS=(
    --target-os=none
    --arch=x86_32
    --enable-cross-compile
    --disable-x86asm
    --disable-inline-asm
    --disable-stripping
    --disable-doc
    --disable-runtime-cpudetect
    --disable-autodetect
    --disable-ffplay
    # --disable-debug
    --disable-hwaccels
    --pkg-config-flags="--static"
    --extra-cflags="$COMPILER_FLAGS"
    --extra-cxxflags="$COMPILER_FLAGS"
    --extra-ldflags="$COMPILER_FLAGS $LINKER_FLAGS"
    --nm=llvm-nm
    --ar=emar
    --ranlib=emranlib
    --cc=emcc
    --cxx=em++
    --objcc=emcc
    --dep-cc=emcc
    
    
    
    # licence options
    # --enable-gpl
    # --enable-version3
    
    
    
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
cd $FFMPEG_BUILD_DIR
DIST_DIR="../$DIST_DIR"
emconfigure ../ffmpeg/configure "${CONFIG_FLAGS[@]}"

# build ffmpeg
emmake make -j3

rm -rf $DIST_DIR
mkdir -p $DIST_DIR

# build ffmpeg.wasm
cp ./ff*_g* $DIST_DIR/
cd $DIST_DIR
for f in *_g; do
    mv -- "$f" "${f%_g}.js"
done
