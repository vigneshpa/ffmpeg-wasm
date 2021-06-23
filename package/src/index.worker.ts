interface WorkerGlobalScope {
    Module: Partial<EmscriptenModule>
}
interface Options {
    distFolder: string;
    tool: ("ffmpeg" | "ffprobe" | "ffplay");
    args: string[];
    bufferSize: number;
}
let options: Options;
const files = {
    stdin: new File([""], "stdin"),
} as { [key: string]: File };
const init = (optionsa: Options) => {
    options = optionsa;
}
const loadFile = (name: string, file: File) => {
    files[name] = file;
    return null;
};
const getFile = (name: string) => {
    return files[name];
};
const loadWasm = () => {
    self.Module = {

        //Locating file
        locateFile(path: string, prefix: string) {
            return prefix + "bin/" + path;
        },

        // prerun
        preRun: [() => {
            const input = () => { return null };
            const output = getWriter(options.bufferSize, ({ buffer }, length) => postMessage({ std: "stdout", buffer, length }, [buffer]));
            const error = getWriter(options.bufferSize, ({ buffer }, length) => postMessage({ std: "stderr", buffer, length }, [buffer]));
            FS.init(input, output[0], error[0]);
        }],

        //Passing arguments
        arguments: options.args,

        //Logging and events
        logReadFiles: true,
        onAbort() {
            postMessage({ event: "abort" });
        },
        onRuntimeInitialized() {
            postMessage({ event: "runtimeInitialized" });
        },
        // print(data: string) {
        //     postMessage({ event: "stdout", data })
        // },
        // printErr(data: string) {
        //     postMessage({ event: "stderr", data })
        // },

        //exit runtime after execution
        noExitRuntime: false,
    }
    importScripts(`${options.distFolder}/bin/${options.tool}.js`);
}
addEventListener("message", ev => {
    if (ev.data.cmd)
        switch (ev.data.cmd) {
            case "init":
                init(ev.data.options);
                break;
            case "loadWasm":
                loadWasm();
                break;
            default:
                console.log(`Unknown command ${ev.data.cmd} recived from main thread`);
                break;
        };
    if (ev.data.req) {
        const reqId = ev.data.reqId;
        let reqData: any;
        if (ev.data.req.loadFile) reqData = loadFile(ev.data.req.loadFile, ev.data.req.file);
        if (ev.data.req.getFile) reqData = getFile(ev.data.req.getFile);
        postMessage({ reqId, reqData });
    }
})
function getWriter(bfrSize: number, flush: (bfr: Uint8Array, length: number) => void): [((num: number | null) => void), typeof flush] {
    const buffer = new Uint8Array(bfrSize);
    let pointer = 0;
    const writer = (num: number | null) => {
        if (num !== null) {
            buffer[pointer] = num
            pointer += 1;
        }
        if (num === null || num === 10 || pointer == (bfrSize - 1)) {
            flush(buffer, pointer + 1);
            pointer = 0;
        };
    };
    return [writer, flush];
}