#!/bin/bash -x

set -eo pipefail

source common.h


##
##  These build scripts are got from ffmpeg.wasm project at https://github.com/ffmpegwasm/ffmpeg-core
##


# build x264
(
    LIB_PATH=$SRC_DIR/x264
    CONF_FLAGS=(
        --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
        --host=i686-gnu                                     # use i686 linux
        --enable-static                                     # enable building static library
        --disable-cli                                       # disable cli tools
        --disable-asm                                       # disable asm optimization
        --extra-cflags="-c -pthread $OPTIMIZATION_FLAGS"    # flags to use pthread and code optimization
    )
    (cd $LIB_PATH && emconfigure ./configure -C "${CONF_FLAGS[@]}")
    emmake make -C $LIB_PATH install-lib-static -j3
    emmake make -C $LIB_PATH clean
)




# # build x265

# (
#     LIB_PATH=$SRC_DIR/x265/source
#     CXXFLAGS="-s -pthread $OPTIMIZATION_FLAGS"
#     BASE_FLAGS=(
#         -DENABLE_LIBNUMA=OFF
#         -DENABLE_SHARED=OFF
#         -DENABLE_CLI=OFF
#     )
    
#     FLAGS_12BIT=(
#         ${BASE_FLAGS[@]}
#         -DHIGH_BIT_DEPTH=ON
#         -DEXPORT_C_API=OFF
#         -DMAIN12=ON
#     )
    
#     FLAGS_10BIT=(
#         ${BASE_FLAGS[@]}
#         -DHIGH_BIT_DEPTH=ON
#         -DEXPORT_C_API=OFF
#     )
    
#     FLAGS_MAIN=(
#         ${BASE_FLAGS[@]}
#         -DCMAKE_INSTALL_PREFIX=$LIB_BUILD_DIR
#         -DEXTRA_LIB="x265_main10.a;x265_main12.a"
#         -DEXTRA_LINK_FLAGS=-L.
#         -DLINKED_10BIT=ON
#         -DLINKED_12BIT=ON
#     )
    
#     cd $LIB_PATH
#     rm -rf build
#     mkdir -p build
#     cd build
#     mkdir -p main 10bit 12bit
    
#     cd 12bit
#     emmake cmake ../.. -DCMAKE_CXX_FLAGS="$CXXFLAGS" ${FLAGS_12BIT[@]}
#     emmake make -j
    
#     cd ../10bit
#     emmake cmake ../.. -DCMAKE_CXX_FLAGS="$CXXFLAGS" ${FLAGS_10BIT[@]}
#     emmake make -j
    
#     cd ../main
#     ln -sf ../10bit/libx265.a libx265_main10.a
#     ln -sf ../12bit/libx265.a libx265_main12.a
#     emmake cmake ../.. -DCMAKE_CXX_FLAGS="$CXXFLAGS" ${FLAGS_MAIN[@]}
#     emmake make install -j
    
#     mv libx265.a libx265_main.a
    
#     # Merge static libraries
# emar -M <<EOF
# CREATE libx265.a
# ADDLIB libx265_main.a
# ADDLIB libx265_main10.a
# ADDLIB libx265_main12.a
# SAVE
# END
# EOF
    
#     cp libx265.a $LIB_BUILD_DIR/lib
    
#     emmake make -C . clean
#     emmake make -C ../10bit clean
#     emmake make -C ../12bit clean
    
#     cd $ROOT_DIR
# )





# build libvpx

(
    LIB_PATH=$SRC_DIR/libvpx
    FLAGS="-c -pthread $OPTIMIZATION_FLAGS"
    CONF_FLAGS=(
        --prefix=$LIB_BUILD_DIR                                # install library in a build directory for FFmpeg to include
        --target=generic-gnu                               # target with miminal features
        --disable-install-bins                             # not to install bins
        --disable-examples                                 # not to build examples
        --disable-tools                                    # not to build tools
        --disable-docs                                     # not to build docs
        --disable-unit-tests                               # not to do unit tests
        --disable-dependency-tracking                      # speed up one-time build
        --extra-cflags="$FLAGS"                            # flags to use pthread and code optimization
        --extra-cxxflags="$FLAGS"                          # flags to use pthread and code optimization
    )
    echo "CONF_FLAGS=${CONF_FLAGS[@]}"
    (cd $LIB_PATH && LINKER_FLAGS="$FLAGS" STRIP="llvm-strip" emconfigure ./configure "${CONF_FLAGS[@]}")
    emmake make -C $LIB_PATH install -j3
    emmake make -C $LIB_PATH clean
)







# build lame

(
    LIB_PATH=$SRC_DIR/lame
    COMPILER_FLAGS="-pthread $OPTIMIZATION_FLAGS"
    CONF_FLAGS=(
        --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
        --host=i686-linux                                   # use i686 linux
        --disable-shared                                    # disable shared library
        --disable-frontend                                  # exclude lame executable
        --disable-analyzer-hooks                            # exclude analyzer hooks
        --disable-dependency-tracking                       # speed up one-time build
        --disable-gtktest
    )
    echo "CONF_FLAGS=${CONF_FLAGS[@]}"
    (cd $LIB_PATH && COMPILER_FLAGS=$COMPILER_FLAGS emconfigure ./configure "${CONF_FLAGS[@]}")
    emmake make -C $LIB_PATH install -j3
    emmake make -C $LIB_PATH clean
)





# build fdk-aac

(
    LIB_PATH=$SRC_DIR/fdk-aac
    COMPILER_FLAGS="-pthread $OPTIMIZATION_FLAGS"
    CONF_FLAGS=(
        --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
        --host=i686-linux                                   # use i686 linux
        --disable-shared                                    # disable shared library
        --disable-dependency-tracking                       # speedup one-time build
    )
    echo "CONF_FLAGS=${CONF_FLAGS[@]}"
    (cd $LIB_PATH && \
        emconfigure ./autogen.sh && \
    COMPILER_FLAGS=$COMPILER_FLAGS emconfigure ./configure -C "${CONF_FLAGS[@]}")
    emmake make -C $LIB_PATH install -j3
    emmake make -C $LIB_PATH clean
)






# build ogg

(
    LIB_PATH=$SRC_DIR/ogg
    CFLAGS="-s -pthread $OPTIMIZATION_FLAGS"
    CONF_FLAGS=(
        --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
        --host=i686-linux                                   # use i686 linux
        --disable-shared                                    # disable shared library
        --disable-dependency-tracking                       # speed up one-time build
        --disable-maintainer-mode
    )
    echo "CONF_FLAGS=${CONF_FLAGS[@]}"
    (cd $LIB_PATH && \
        emconfigure ./autogen.sh && \
    CFLAGS=$CFLAGS emconfigure ./configure -C "${CONF_FLAGS[@]}")
    emmake make -C $LIB_PATH install -j
    emmake make -C $LIB_PATH clean
)





# -------------------------------------------------------------------------------------------------------------------------NOT Working
# # build vorbis

# (
#     LIB_PATH=$SRC_DIR/vorbis
#     CFLAGS="-s -pthread $OPTIMIZATION_FLAGS -I$LIB_BUILD_DIR/include"
#     LDFLAGS="-L$LIB_BUILD_DIR/lib"
#     CONF_FLAGS=(
#         --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
#         --host=i686-linux                                   # use i686 linux
#         --enable-shared=no                                  # disable shared library
#         --enable-docs=no
#         --enable-examples=no
#         --enable-fast-install=no
#         --disable-oggtest                                   # disable oggtests
#         --disable-dependency-tracking                       # speed up one-time build
#     )
#     echo "CONF_FLAGS=${CONF_FLAGS[@]}"
#     (cd $LIB_PATH && \
#         emconfigure ./autogen.sh && \
#     CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS emconfigure ./configure -C "${CONF_FLAGS[@]}")
#     emmake make -C $LIB_PATH install -j
#     emmake make -C $LIB_PATH clean
# )









# build theora
# !/bin/bash
(
    LIB_PATH=$SRC_DIR/theora
    COMPILER_FLAGS="-pthread $OPTIMIZATION_FLAGS -I$LIB_BUILD_DIR/include"
    LINKER_FLAGS="-L$LIB_BUILD_DIR/lib"
    CONF_FLAGS=(
        --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
        --host=i686-linux                                   # use i686 linux
        --enable-shared=no                                  # disable shared library
        --enable-docs=no
        --enable-fast-install=no
        --disable-spec
        --disable-asm
        --disable-examples
        --disable-oggtest                                   # disable ogg tests
        --disable-vorbistest                                # disable vorbis tests
        --disable-sdltest                                   # disable sdl tests
    )
    echo "CONF_FLAGS=${CONF_FLAGS[@]}"
    (cd $LIB_PATH && \
    COMPILER_FLAGS=$COMPILER_FLAGS LINKER_FLAGS=$LINKER_FLAGS emconfigure ./autogen.sh -C "${CONF_FLAGS[@]}")
    emmake make -C $LIB_PATH install -j3
    emmake make -C $LIB_PATH clean
)






# build opus
# !/bin/bash
(
    LIB_PATH=$SRC_DIR/opus
    COMPILER_FLAGS="-pthread $OPTIMIZATION_FLAGS"
    CONF_FLAGS=(
        --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
        --host=i686-gnu                                     # use i686 linux
        --enable-shared=no                                  # not to build shared library
        --disable-asm                                       # not to use asm
        --disable-rtcd                                      # not to detect cpu capabilities
        --disable-doc                                       # not to build docs
        --disable-extra-programs                            # not to build demo and tests
        --disable-stack-protector
    )
    echo "CONF_FLAGS=${CONF_FLAGS[@]}"
    (cd $LIB_PATH && \
        emconfigure ./autogen.sh && \
    COMPILER_FLAGS=$COMPILER_FLAGS emconfigure ./configure -C "${CONF_FLAGS[@]}")
    emmake make -C $LIB_PATH install -j3
    emmake make -C $LIB_PATH clean
)




# --------------------------------------------------------------------------------------------------------------------------NOT WORKING
# # build freetype2

# (
#     LIB_PATH=$SRC_DIR/freetype
#     CFLAGS="-s -pthread $OPTIMIZATION_FLAGS"
#     CONF_FLAGS=(
#         --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
#         --host=i686-gnu                                     # use i686 linux
#         --enable-shared=no                                  # not to build shared library
#     )
#     echo "CONF_FLAGS=${CONF_FLAGS[@]}"
#     (cd $LIB_PATH && \
#         emconfigure ./autogen.sh && \
#     CFLAGS=$CFLAGS emconfigure ./configure -C "${CONF_FLAGS[@]}")
#     emmake make -C $LIB_PATH install -j
#     emmake make -C $LIB_PATH clean
# )



# -------------------------------------------------------------------------------------------------------------------------NOT WORKING
# # build libwebp

# (
#     LIB_PATH=$SRC_DIR/libwebp
#     CXXFLAGS="-pthread $OPTIMIZATION_FLAGS"
#     CM_FLAGS=(
#         -DCMAKE_INSTALL_PREFIX=$LIB_BUILD_DIR
#         -DBUILD_SHARED_LIBS=OFF
#         # -DZLIB_LIBRARY=$LIB_BUILD_DIR/lib
#         # -DZLIB_INCLUDE_DIR=$LIB_BUILD_DIR/include
#         -DWEBP_ENABLE_SIMD=ON
#         -DWEBP_BUILD_ANIM_UTILS=OFF
#         -DWEBP_BUILD_CWEBP=OFF
#         -DWEBP_BUILD_DWEBP=OFF
#         -DWEBP_BUILD_GIF2WEBP=OFF
#         -DWEBP_BUILD_IMG2WEBP=OFF
#         -DWEBP_BUILD_VWEBP=OFF
#         -DWEBP_BUILD_WEBPINFO=OFF
#         -DWEBP_BUILD_WEBPMUX=OFF
#         -DWEBP_BUILD_EXTRAS=OFF
#     )
#     echo "CM_FLAGS=${CM_FLAGS[@]}"

#     cd $LIB_PATH
#     mkdir -p build
#     cd build
#     emmake cmake .. -DCMAKE_C_FLAGS="$CXXFLAGS" ${CM_FLAGS[@]}
#     emmake make install
#     emmake make clean
#     cd $ROOT_DIR
# )





# ---------------------------------------------------------------------------------------------------------------------------NOT WORKING
# # build fribidi

# (
#     LIB_PATH=$SRC_DIR/fribidi
#     COMPILER_FLAGS="-pthread $OPTIMIZATION_FLAGS"
#     CONF_FLAGS=(
#         --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
#         --host=i686-gnu                                     # use i686 linux
#         --enable-shared=no                                  # not to build shared library
#         --enable-static
#         --disable-dependency-tracking
#         --disable-debug
#         --disable-docs
#     )
#     echo "CONF_FLAGS=${CONF_FLAGS[@]}"
#     (cd $LIB_PATH && \
#         emconfigure ./autogen.sh && \
#     COMPILER_FLAGS=$COMPILER_FLAGS emconfigure ./configure -C "${CONF_FLAGS[@]}")
#     emmake make -C $LIB_PATH install -j3
#     emmake make -C $LIB_PATH clean
# )





# -------------------------------------------------------------------------------------------------------------------------------NOT WORKING  DEPENDS ON FREE TYPE
# # build libass

# (
#     LIB_PATH=$SRC_DIR/libass
#     CONF_FLAGS=(
#         --prefix=$LIB_BUILD_DIR                                 # install library in a build directory for FFmpeg to include
#         --host=i686-gnu                                     # use i686 linux
#         --disable-shared
#         --enable-static
#         --disable-asm                                       # disable asm optimization
#         --disable-fontconfig
#         --disable-require-system-font-provider
#     )
#     echo "CONF_FLAGS=${CONF_FLAGS[@]}"
#     (cd $LIB_PATH && ./autogen.sh && EM_PKG_CONFIG_PATH=$EM_PKG_CONFIG_PATH emconfigure ./configure -C "${CONF_FLAGS[@]}")
#     emmake make -C $LIB_PATH install -j3
#     emmake make -C $LIB_PATH clean
# )