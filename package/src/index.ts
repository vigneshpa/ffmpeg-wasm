export type FFmpegOptions = Partial<typeof FFmpegWasm.prototype.options>;

export default class FFmpegWasm {
    options = {
        distFolder: "/ffmpeg" as string,
        tool: "ffmpeg" as ("ffmpeg" | "ffprobe" | "ffplay"),
        args: ["-h"] as string[],
        bufferSize: 1024 * 1024 as number,
        getStdErrFile: false as boolean,
        getStdOutFile: true as boolean
    };
    private worker: Worker | null = null;
    private running = false as boolean;
    private reqHandlers: { [reqId: number]: ((ev: MessageEvent) => void) } = {};


    constructor(options?: FFmpegOptions) {
        Object.assign(this.options, options);
        options = this.options;
        this.worker = new Worker(this.options.distFolder + "/index.worker.js");
        this.worker.onmessage = (ev: MessageEvent) => {
            if (ev.data.std) return console.log(`[${ev.data.std}]`, ev.data.buffer, ev.data.length);
            if (ev.data.print) return console.log(`[${ev.data.stream}]`, ev.data.message);
            if (ev.data.event) return console.log(`[${ev.data.event}]\t${ev.data.data || ''}`);
            if (ev.data.reqId) return this.reqHandlers[ev.data.reqId](ev.data.reqData);
            console.log(ev.data);
        };
    }


    loadFile(file: File) {
        return this.requestWorker({ loadFile: file }) as Promise<void>;
    }


    getFile(name: string) {
        return this.requestWorker({ getFile: name }) as Promise<File>;
    }


    async execute() {
        if(this.running)throw new Error("Cannot execute:Wasm is running");
        this.running = true;
        await this.requestWorker({ execute: true }) as Promise<void>;
        this.running = false;
    }

    init(init: FFmpegOptions) {
        Object.assign(this.options, init);
        return this.requestWorker({ init: this.options }) as Promise<void>;
    }


    private requestWorker(req: any): Promise<any> {
        if (this.running && !req.execute) {
            console.error("Cannot make request:Wasm is running", req);
            throw new Error("Cannot make request:Wasm is running");
        }
        return new Promise(resolve => {
            const reqId = Math.floor(Math.random() * 10000) + 1;
            this.reqHandlers[reqId] = data => { resolve(data); delete this.reqHandlers[reqId] };
            this.worker!.postMessage({ req, reqId });
        });
    }

    destroy() {
        this.worker?.terminate();
    }
}