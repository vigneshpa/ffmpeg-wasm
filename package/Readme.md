# FFmpeg - WASM npm module
> This repo uses FFmpeg which may use some media codecs that has their own licencing.

> This module is intended to run only in browsers. It may have issues runnig in JavaScript runtimes that are not within browsers e.g. NodeJS

> This software is in developement phase

FFmpeg - WASM is intended to make ffmpeg run on browsers without any server side operations. This webassembly build of ffmpeg can run in browsers even without internet connection ( only if you are caching the files using a service worker )

## Installation

>This module is not completely ready. Once it is ready it will be available to pulblic.

To install the module run
```
npm install @vigneshpa/ffmpeg-wasm
```

Or if you prefer to use Yarn insted of NPM run
```bash
yarn add @vigneshpa/ffmpeg-wasm
```

## How to use

The file in your 'node_modules/@vigneshpa/ffmpeg-wasm/dist' are static files that are used by this module to function they must be server by your server and the URL must be passed via the options object of the constructor

The following typescript example gets a file from the user and console logs the details of the file using ffprobe

This file needs to be compiled with javascript bundlers like webpack or rollup to import the npm module

```typescript
// Importing the library
import FFmpegWasm from "vigneshpa/ffmpeg-wasm";

// Importing type definitions of the options object
import { FFmpegOptions } from "vigneshpa/ffmpeg-wasm";

// Creating a new button and a file picker
const filePicker = document.createElement("input");
filePicker.type = "file";
const button = document.createElement("button");
button.onclick = ev => filePicker.click();
button.innerHTML = "Select a file to analyze";
document.body.appendChild(button)

//Function to be called when a File is selected
const getFileDetails = async ev => {

    // Creating options object to pass to the constructor
    const options: FFmpegOptions = {

        // Specify the URL of directory where the dist folder
        // of this module is served by the server.
        // Defaults to "/ffmpeg"
        dist: "/assets/ffmpeg",

        // Specity the program to be used "ffmpeg" or "ffprobe"
        tools: "ffprobe",

        // Specify the arguments to be passed
        args: [`/input/${filePicker.files[0].name}`],
    }

    // This creates an instance of ffmpeg
    // and a new worker thread to do the operations
    const ffmpeg = new FFmpegWasm(options);

    // Passing the selected file
    await ffmpeg.loadFile(filePicker.files[0]);

    // Initilizes and loads the wasm module scripts for the selected tool
    await ffmpeg.init();

    // Downloads the wasm binary and starts the execution
    await ffmpeg.execute();

    // Do not forget to call the destroy method
    ffmpeg.destroy();

    // This method do not destory the object but destries the worker
    // threads which may be using many system resources
    // the ffmpeg object will be destroyed by the garbage collector
}
filePicker.onchange = getFileDetails;
```

The javascript version will be the same but without any type definitions