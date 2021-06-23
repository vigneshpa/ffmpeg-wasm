export type FFmpegOptions = Partial<typeof FFmpegWasm.prototype.options>;
export default class FFmpegWasm {
    options = {
        distFolder: "/ffmpeg" as string,
        tool: "ffmpeg" as ("ffmpeg" | "ffprobe" | "ffplay"),
        args:["-h"] as string[],
        bufferSize: 1024*1024 as number,
    };
    private worker: Worker | null = null;
    private reqHandlers:((ev:MessageEvent)=>void)[] = [];
    constructor(options?: FFmpegOptions) {
        assignOptions(this.options, options);
        options = this.options;
        this.worker = new Worker(this.options.distFolder + "/index.worker.js");
        this.worker.onmessage  = (ev:MessageEvent) => {
            if(ev.data.std)return console.log(`[${ev.data.std}]`, ev.data.buffer, ev.data.length);
            if(ev.data.event)return console.log(`[${ev.data.event}]\t${ev.data.data||''}`);
            console.log(ev.data);
        };
        this.worker.postMessage({ cmd: "init", options });
    }
    loadFile(name:string, file:File){
        return this.requestWorker({loadFile:name, file}) as Promise<null>;
    }
    getFile(name:string){
        return this.requestWorker({getFile:name}) as Promise<File>;
    }
    async loadWasm() {
        this.worker?.postMessage({ cmd: "loadWasm" });
    }
    private requestWorker(req:any):Promise<any>{
        return new Promise(resolve=>{
            const reqId = Math.random();
            this.worker!.postMessage({req, reqId});
            this.worker!.addEventListener("message", ev=>{
                if(ev.data?.reqId === reqId) resolve(ev.data.reqData);
            });
        });
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