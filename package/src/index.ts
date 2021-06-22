export type FFmpegOptions = Partial<typeof FFmpegWasm.prototype.options>;
export default class FFmpegWasm {
    options = {
        disableWorker: false as boolean,
        binFolder: "/ffmpeg" as string
    };
    constructor(options?: FFmpegOptions) {
        assignOptions(this.options, options);
    }
    worker: Worker | null = null;
    async loadWorker(options?: FFmpegOptions) {
        assignOptions(this.options, options);
        this.worker = new Worker(this.options.binFolder + "/ffmpeg.worker.js");
        this.worker.addEventListener("message", ev => {
            console.log(ev);
        });
        this.worker.postMessage({cmd:"load"});
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