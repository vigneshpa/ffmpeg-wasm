# FFmpeg - WASM
> This repo uses FFmpeg which may use some media codecs that has their own licencing.

> This software is in developement phase

This repo is intended to make ffmpeg run on browsers without any server side operations. This webassembly build of ffmpeg can run in browsers even without internet connection ( only if you are caching the files using a service worker )

## Using this build of ffmpeg

This build of ffmpeg is not completely ready. Once it is ready the prebuilt binaries will be released in npm registry for public use.

To use this build I have created an API which abstracts the complexcities of the built javascript Emscripten module. This interface is completely written in typescript and hence has first class typescript support.
>It is not necessary to use TypeScript to use this module in your application.

To learn how to use this library head over to [package](package/Readme.md).

## Building FFmpeg

To build the web assembly binary the build script uses Emscripten SDK.
So make sure you have installed Emscripten SDK and the installation directory is available at EMSDK environment variable.

To build ffmpeg from the source code run the following commands after initilizing the ffmpeg and other submodules ( with depth 1 of master or latest release, to reduse data downloaded )
```bash
./installDeps.sh  # Builds and installs external libraries in the build directory
./build.sh        # Builds the ffmpeg binaries
```

## Goals of this build
are:
- To be easy with system memory by not acclocating huge RAM.
- To be able to handle large files without loading them to memory ( It is possible by using WORKERFS , IDBFS or stdio streams )