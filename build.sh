#!/bin/bash -x

set -eo pipefail

source common.h

# Build Flags

OPTIMIZATION_FLAGS=(
    -o3
    "--closure 1"
)
OPTIMIZATION_FLAGS=(-o3)                 # comment out this line to enable closure optimisations

COMPILER_FLAGS=(
    -pthread
    -I$LIB_BUILD_DIR/include
    "${OPTIMIZATION_FLAGS[@]}"
)


LINKER_FLAGS=(
    -s PTHREAD_POOL_SIZE=$WORKER_THREADS
    -s INITIAL_MEMORY=$WASM_MEMORY
    -s ALLOW_MEMORY_GROWTH=$MEMORY_GROWTH
    -s MODULARIZE
    -s EXPORT_NAME=FFmpegFactory
    -s EXPORTED_RUNTIME_METHODS="[FS]"#,WORKERFS,IDBFS]
    -s INVOKE_RUN
    -s EXIT_RUNTIME
    -s ENVIRONMENT=web,worker
    -s USE_SDL=2
    -s USE_ZLIB
    -L$LIB_BUILD_DIR/lib
    # -lidbfs.js
    # -lworkerfs.js
)

COMPILER_FLAGS="${COMPILER_FLAGS[@]}"
LINKER_FLAGS="${LINKER_FLAGS[@]}"

FFMPEG_CONFIG_FLAGS=(
    --target-os=none
    --arch=x86_32
    --enable-cross-compile
    --disable-x86asm
    --disable-inline-asm
    --disable-stripping
    --disable-doc
    --disable-debug
    --disable-runtime-cpudetect
    --disable-autodetect
    --extra-cflags="$COMPILER_FLAGS"
    --extra-cxxflags="$COMPILER_FLAGS"
    --extra-ldflags="$COMPILER_FLAGS $LINKER_FLAGS"
    --pkg-config-flags="--static"
    --nm=llvm-nm
    --ar=emar
    --ranlib=emranlib
    --cc=emcc
    --cxx=em++
    --objcc=emcc
    --dep-cc=emcc
    --enable-gpl
    --enable-nonfree
    --enable-zlib
    --enable-libx264
    # --enable-libx265
    --enable-libvpx
    --enable-libmp3lame
    --enable-libfdk-aac
    --enable-libtheora
    # --enable-libvorbis
    # --enable-libfreetype
    --enable-libopus
    # --enable-libwebp
    # --enable-libass
    # --enable-libfribidi
)

cd $FFMPEG_BUILD_DIR

echo "FFMPEG_CONFIG_FLAGS=${FFMPEG_CONFIG_FLAGS_BASE[@]}"
EM_PKG_CONFIG_PATH=${EM_PKG_CONFIG_PATH} emconfigure $SRC_DIR/ffmpeg/configure "${FFMPEG_CONFIG_FLAGS[@]}"

emmake make -j3

# copying ffmpeg.wasm
cp ./ff*_g* $DIST_DIR/
cd $DIST_DIR
for f in *_g; do
    mv -- "$f" "${f%_g}.js"
done