#!/bin/bash -x

# Build options
WASM_MEMORY=1536mb                                 # Initial memory in Mega Bytes
MEMORY_GROWTH=0                                    # Wheater to allow memory growth
WORKER_THREADS='navigator.hardwareConcurrency-1'   # Setting thread pool to no of cores -1
DIST_DIR=package/dist/bin                          # Where to save final programs
BUILD_DIR=build                                    # Root of build directories
SRC_DIR=sources                                    # Ffmpeg source code directory
FFMPEG_BUILD_DIR=$BUILD_DIR/ffmpeg                 # where to build ffmpeg
LIB_BUILD_DIR=$BUILD_DIR/libs                      # where to build libraries




# parsing variables and validating

# making paths absolute
ROOT_DIR=$PWD
DIST_DIR=$PWD/$DIST_DIR
BUILD_DIR=$PWD/$BUILD_DIR
SRC_DIR=$PWD/$SRC_DIR
FFMPEG_BUILD_DIR=$PWD/$FFMPEG_BUILD_DIR
LIB_BUILD_DIR=$PWD/$LIB_BUILD_DIR

# creating disrectories
mkdir -p $DIST_DIR
mkdir -p $FFMPEG_BUILD_DIR
mkdir -p $LIB_BUILD_DIR


# loading Emscripten SDK and LLVM path variables
# $EMSDK/emsdk activate latest
source $EMSDK/emsdk_env.sh
export PATH=$EMSDK/upstream/bin:$PATH



# verify Emscripten existance
emcc -v

export EM_PKG_CONFIG_PATH=$LIB_BUILD_DIR/lib/pkgconfig


OPTIMIZATION_FLAGS=(
    -o3
    "--closure 1"
)
OPTIMIZATION_FLAGS=()                 # comment out this line to enable closure optimisations

COMPILER_FLAGS=(
    -pthread
    -I$LIB_BUILD_DIR/include
    -s USE_SDL=2
    -s USE_ZLIB
    "${OPTIMIZATION_FLAGS[@]}"
)

COMPILER_FLAGS="${COMPILER_FLAGS[@]}"

export EMCC_CFLAGS=$COMPILER_FLAGS
