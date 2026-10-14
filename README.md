# Fish Audio Drama 3 on a DGX Spark

Fish Audio's [Drama 3](https://huggingface.co/fishaudio/drama-3) (35B MoE text-to-speech, 3B active) on one NVIDIA DGX Spark (GB10, arm64, CUDA 13), with [SGLang-Omni](https://github.com/sgl-project/sglang-omni) and the original FP8 weights. Built with Fish Audio.

**Measured on one Spark:** 30.1 s of speech in 27.4 s, 1.10× real time (one request, non-streaming, temperature 1.0, top-p 0.9). 37.5 GiB of weights, 244 s to load.

## Quick start

```
hf download fishaudio/drama-3 --revision e0a9218aa48888270f06ef1ed9ea67622c0e17d2
docker build -t sglang-omni-spark:22d4ace .
./run.sh      # server on :8000, ~5 min to start
./ui.sh       # web UI on :7899
```

Both listen on 127.0.0.1. To open them from another machine: `HOST=<this machine's LAN or VPN address> ./run.sh` and the same for `./ui.sh`.

## What it takes on a Spark

The upstream SGLang-Omni Dockerfile (@22d4ace) with five changes:

1. No flashinfer-cache stage. That image is amd64 only. FlashInfer compiles for SM121 on the first start.
2. SGLang-Omni is cloned at a pinned commit at build time.
3. Only the `fishaudio` extra.
4. OpenFst 1.8.3 built from source. pynini has no aarch64 wheel.
5. The playground opens with Drama 3's sampling defaults (1.0 / 0.9), not S2 Pro's (0.8 / 0.8). At 0.8 / 0.8 the voice sounds flat.

And two run settings:

- `codec_path` points at drama-3's own `codec.pth`. It is the same file as the s2-pro pin (same sha256), so nothing else downloads.
- The UI and the server share `./shared`, because the UI sends reference audio as a file path.

## On GB10 today

The fast codebook sampling and fused tower layers run on Hopper only, so on GB10 they fall back to PyTorch. There is no tuned MoE kernel config for GB10. Both are open room for speed.

## License

The scripts: MIT. Drama 3 and SGLang-Omni's playground: their own licenses (Fish Audio Community License).
