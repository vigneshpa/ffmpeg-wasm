interface Options {
    distFolder: string;
    tool: ("ffmpeg" | "ffprobe" | "ffplay");
}
let options: Options;
const init = (optionsa: Options) => {
    options = optionsa;
}
const loadWasm = () => {
    (<any>self).Module = {
        locateFile(path: string, prefix: string) {
            return prefix + "/bin/" + path;
        },
        logReadFiles:true,
        onAbort(){
            postMessage({event:"abort"});
        }
    }
    importScripts(`${options.distFolder}/bin/${options.tool}.js`);
}
addEventListener("message", ev => {
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
    }
})