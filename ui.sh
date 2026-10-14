#!/bin/bash
# the playground UI for Drama 3 on :7899. Uploaded reference audio lands
# in ./shared, which run.sh mounts into the server at the same path.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p shared
HOST="${HOST:-127.0.0.1}"
docker run -d --name drama3-ui --network host \
  -e GRADIO_TEMP_DIR=/shared -v "$PWD/shared:/shared" \
  sglang-omni-spark:22d4ace python -m playground.s2pro.app \
  --api-base "http://$HOST:8000" --host "$HOST" --port 7899
echo "UI on http://$HOST:7899"
