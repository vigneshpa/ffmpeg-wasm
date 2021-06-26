# FFmpeg - WASM
> This repo uses FFmpeg which may contain some media codecs that has their own licencing.

This software is intended to make ffmpeg run on browsers

## Building FFmpeg

To build the web assembly binary this program uses Emscripten SDK.
So make sure you have installed Emscripten SDK and the installation directory is available at EMSDK environment variable.

To build the ffmpeg source code run the following command after cloning the ffmpeg submodule(with depth 1 of master or latest release, to reduse data downloaded)
```bash
./build.sh
```
