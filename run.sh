#!/bin/bash
# Fish Audio Drama 3 on SGLang-Omni. The model is read-only; FlashInfer's SM121 kernels,
# compiled on the first start, persist in ./flashinfer-cache so later starts skip it.
# ./shared is where the playground UI saves uploaded reference audio; the server reads it at the same path.
set -euo pipefail
cd "$(dirname "$0")"
HOST="${HOST:-127.0.0.1}"   # the address to listen on; set your LAN or VPN address to reach it from elsewhere
mkdir -p flashinfer-cache shared
SNAP=/hf/hub/models--fishaudio--drama-3/snapshots/e0a9218aa48888270f06ef1ed9ea67622c0e17d2
docker run -d --name drama3 --gpus all --ipc host -p "$HOST:8000:8000" \
  -v "$HOME/.cache/huggingface:/hf:ro" -v "$PWD/flashinfer-cache:/root/.cache/flashinfer" \
  -v "$PWD/shared:/shared:ro" \
  -e HF_HUB_OFFLINE=1 --log-opt max-size=50m --log-opt max-file=3 \
  sglang-omni-spark:22d4ace sgl-omni serve --model-path "$SNAP" --host 0.0.0.0 --port 8000 \
  --vocoder.factory.codec_path "$SNAP"   # drama-3 ships the same codec.pth as the default s2-pro pin
echo "started. follow with: docker logs -f drama3"
