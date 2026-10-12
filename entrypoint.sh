#!/bin/sh
# Descarga el modelo la primera vez (queda en el volumen) y arranca el servidor.
set -e

MODEL="${WHISPER_MODEL:-large-v3-turbo-q5_0}"
MODEL_FILE="/models/ggml-${MODEL}.bin"

if [ ! -f "$MODEL_FILE" ]; then
  echo "Descargando modelo ${MODEL}…"
  /app/download-ggml-model.sh "$MODEL" /models
fi

exec /app/whisper-server \
  -m "$MODEL_FILE" \
  -l "${WHISPER_LANG:-es}" \
  -t "${WHISPER_THREADS:-4}" \
  --host 0.0.0.0 \
  --port 8080
