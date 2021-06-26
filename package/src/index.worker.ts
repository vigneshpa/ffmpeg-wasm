//interfaces
interface Options {
    distFolder: string;
    tool: ("ffmpeg" | "ffprobe" | "ffplay");
    args: string[];
    bufferSize: number;
    getStdErrFile: boolean;
    getStdOutFile: boolean;
}
interface EmscriptenModule {
    FS: typeof FS;
    IDBFS: Emscripten.FileSystemType;
    WORKERFS: Emscripten.FileSystemType;
    mainScriptUrlOrBlob: string | Blob;
}
interface WorkerGlobalScope {
    FFmpegFactory?: EmscriptenModuleFactory;
}


//Variables
let options: Options;
const files = [] as File[];
let isExecuting = false;
let mainScript: string;





//Functions static
const init = (optionsa: Options) => {
    options = optionsa;
    if (!self.FFmpegFactory) {
        mainScript = `${options.distFolder}/bin/${options.tool}.js`;
        importScripts(mainScript);
    };
    return;
}
const loadFile = (file: File) => {
    files.push(file);
    return;
};
const getFile = (name: string) => {
    return files[0];
};
const execute = async () => {
    if (!self.FFmpegFactory) return console.error("Please init before executing");
    if (isExecuting) return console.error("Wasm is already executing");
    isExecuting = true;
    const stdout = createBuffer(!options.getStdOutFile, ({ buffer }, length) => postMessage({ std: "stdout", buffer, length }, [buffer]));
    const stderr = createBuffer(!options.getStdErrFile, ({ buffer }, length) => postMessage({ std: "stderr", buffer, length }, [buffer]));
    const Module = {

        // Locating file
        locateFile(path, prefix) {
            return prefix + "bin/" + path;
        },
        mainScriptUrlOrBlob:mainScript,

        // prerun
        preRun: [() => {
            Module.FS.init(null, stdout.writer, stderr.writer);
            Module.FS.mkdir("/input");
            Module.FS.mount(Module.WORKERFS, { files }, "/input");
            Module.FS.mkdir("/output");
            Module.FS.mount(Module.IDBFS, {}, "/output");
        }],

        // Passing arguments
        arguments: options.args,

        // Logging and events
        logReadFiles: false,

        // Print streams
        print(print) {
            postMessage({ stream: "stdOut", print });
        },
        printErr(print) {
            postMessage({ stream: "stdErr", print });
        },

        // postrun
        postRun: [
            () => {
                stdout.flush();
                stderr.flush();
                postMessage({ event: "postRun" });
            }
        ],

        onAbort() {
            postMessage({ event: "abort" });
        },
        onRuntimeInitialized() {
            postMessage({ event: "runtimeInitialized" });
        },
    } as Partial<EmscriptenModule> as EmscriptenModule;
    await self.FFmpegFactory(Module);
    isExecuting = false;
    return;
}





//Adding event listener after initilising static functions
addEventListener("message", async ev => {
    if (ev.data.req) {
        const reqId = ev.data.reqId;
        if (ev.data.req.init) return postMessage({ reqId, reqData: init(ev.data.req.init) });
        if (ev.data.req.execute) return postMessage({ reqId, reqData: await execute() });
        if (ev.data.req.loadFile) return postMessage({ reqId, reqData: loadFile(ev.data.req.loadFile) });
        if (ev.data.req.getFile) return postMessage({ reqId, reqData: getFile(ev.data.req.getFile) });
        console.error("Unknown request recived", ev.data);
    }
})





// Hoisted Util functions
function createBuffer(isNull: boolean, flush: (bfr: Uint8Array, length: number) => void) {
    if (isNull) return { writer: null, flush: () => null };
    const buffer = new Uint8Array(options.bufferSize);
    let pointer = 0;
    const writer = (num: number | null) => {
        if (num !== null) {
            buffer[pointer] = num
            pointer += 1;
        }
        if (num === null || pointer == (options.bufferSize - 1)) {
            flush(buffer, pointer + 1);
            pointer = 0;
        };
    };
    return { writer, flush: () => flush(buffer, pointer + 1) };
}