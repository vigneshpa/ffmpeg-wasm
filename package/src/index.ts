export type FFmpegOptions = Partial<typeof FFmpegWasm.prototype.options>;
export  class FFmpegWasm {
    options = {
        disableWorker: false as boolean,
        distFolder: "/ffmpeg" as string,
        tool: "ffmpeg" as ("ffmpeg" | "ffprobe" | "ffplay")
    };
    constructor(options?: FFmpegOptions) {
        assignOptions(this.options, options);
    }
    worker: Worker | null = null;
    loadWorker(options?: FFmpegOptions) {
        assignOptions(this.options, options);
        this.worker = new Worker(this.options.distFolder + "/index.worker.js");
        this.worker.addEventListener("message", ev => {
            console.log(ev);
        });
        this.worker.postMessage({ cmd: "init", options: this.options });
    }
    async loadWasm() {
        this.worker?.postMessage({ cmd: "loadWasm" });
    }
}






function assignOptions(dest: typeof FFmpegWasm.prototype.options, source?: Partial<typeof FFmpegWasm.prototype.options>) {
    if (source) {
        for (const key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
                (<any>dest)[key] = (<any>source)[key];
            }
        }
    }
}