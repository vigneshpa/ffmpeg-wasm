//interfaces
interface Options {
    distFolder: string;
    tool: ("ffmpeg" | "ffprobe" | "ffplay");
    args: string[];
    bufferSize: number;
}
interface EmscriptenModule {
    FS: typeof FS;
}
interface WorkerGlobalScope {
    FFmpegFactory?: EmscriptenModuleFactory;
}





//Variables
let options: Options;
const files = [] as File[];
let isExecuting = false;





//Functions static
const init = (optionsa: Options) => {
    options = optionsa;
    if (!self.FFmpegFactory) importScripts(`${options.distFolder}/bin/${options.tool}.js`);
}
const loadFile = (file: File) => {
    files.push(file);
    return null;
};
const getFile = (name: string) => {
    return files[0];
};
const execute = async () => {
    if (!self.FFmpegFactory) throw Error("Please init before executing");
    if (isExecuting) throw Error("Wasm is already executing");
    isExecuting = true;
    const stdinp = () => { return null };
    const stdout = createBuffer(options.bufferSize, ({ buffer }, length) => postMessage({ std: "stdout", buffer, length }, [buffer]));
    const stderr = createBuffer(options.bufferSize, ({ buffer }, length) => postMessage({ std: "stderr", buffer, length }, [buffer]));
    const Module = {

        //Locating file
        locateFile(path, prefix) {
            return prefix + "bin/" + path;
        },

        // prerun
        preRun: [() => {
            Module.FS.init(stdinp, stdout.writer, stderr.writer);
        }],

        //Passing arguments
        arguments: options.args,

        //Logging and events
        logReadFiles: true,

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
}





//Adding event listener after initilising static functions
addEventListener("message", async ev => {
    if (ev.data.req) {
        const reqId = ev.data.reqId;
        if (ev.data.req.init) postMessage({ reqId, reqData: init(ev.data.req.init) });
        if (ev.data.req.execute) postMessage({ reqId, reqData: execute() });
        if (ev.data.req.loadFile) postMessage({ reqId, reqData: loadFile(ev.data.req.loadFile) });
        if (ev.data.req.getFile) postMessage({ reqId, reqData: getFile(ev.data.req.getFile) });
        throw new Error("Unknown request recived");
    }
})





// Hoisted Util functions
function createBuffer(bfrSize: number, flush: (bfr: Uint8Array, length: number) => void) {
    const buffer = new Uint8Array(bfrSize);
    let pointer = 0;
    const writer = (num: number | null) => {
        if (num !== null) {
            buffer[pointer] = num
            pointer += 1;
        }
        if (num === null || pointer == (bfrSize - 1)) {
            flush(buffer, pointer + 1);
            pointer = 0;
        };
    };
    return { writer, flush: () => flush(buffer, pointer + 1) };
}