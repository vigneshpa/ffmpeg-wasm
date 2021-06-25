export type FFmpegOptions = Partial<typeof FFmpegWasm.prototype.options>;

export default class FFmpegWasm {
    options = {
        distFolder: "/ffmpeg" as string,
        tool: "ffmpeg" as ("ffmpeg" | "ffprobe" | "ffplay"),
        args: ["-h"] as string[],
        bufferSize: 1024 * 1024 as number,
    };
    private worker: Worker | null = null;
    private reqHandlers: { [reqId: number]: ((ev: MessageEvent) => void) } = {};


    constructor(options?: FFmpegOptions) {
        Object.assign(this.options, options);
        options = this.options;
        this.worker = new Worker(this.options.distFolder + "/index.worker.js");
        this.worker.onmessage = (ev: MessageEvent) => {
            if (ev.data.std) return console.log(`[${ev.data.std}]`, ev.data.buffer, ev.data.length);
            if (ev.data.event) return console.log(`[${ev.data.event}]\t${ev.data.data || ''}`);
            if (ev.data.reqId) return this.reqHandlers[ev.data.reqId](ev.data.reqData);
            console.log(ev.data);
        };
        this.worker.postMessage({ cmd: "init", options });
    }


    loadFile(name: string, file: File) {
        return this.requestWorker({ loadFile: file }) as Promise<null>;
    }


    getFile(name: string) {
        return this.requestWorker({ getFile: name }) as Promise<File>;
    }


    execute() {
        return this.requestWorker({execute:true}) as Promise<void>;
    }


    private requestWorker(req: any): Promise<any> {
        return new Promise(resolve => {
            const reqId = Math.floor(Math.random() * 10000) + 1;
            this.reqHandlers[reqId] = data => { resolve(data); delete this.reqHandlers[reqId] };
            this.worker!.postMessage({ req, reqId });
        });
    }
}