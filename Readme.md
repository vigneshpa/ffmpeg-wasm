# FFmpeg - WASM
> This repo uses FFmpeg which may contain some media codecs that has their own licencing.

This software is intended to make ffmpeg run on browsers without any server side operations. This webassembly build of ffmpeg can run in browsers even without internet connection ( if you are caching the files using service worker ) 

## Building FFmpeg

To build the web assembly binary the build script uses Emscripten SDK.
So make sure you have installed Emscripten SDK and the installation directory is available at EMSDK environment variable.

To build the ffmpeg source code run the following commands after initilizing the ffmpeg and other submodules ( with depth 1 of master or latest release, to reduse data downloaded )
```bash
./installDeps.sh  # Builds and installs external libraries in the build directory
./build.sh        # Builds the ffmpeg binaries
```
