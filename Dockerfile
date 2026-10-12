# whisper.cpp compilado desde el código fuente: vale igual para x86 que para
# ARM (Oracle Always Free). Compila en la máquina donde va a correr, porque
# por defecto se optimiza para la CPU que lo construye.
FROM debian:bookworm-slim AS build

ARG WHISPER_VERSION=v1.7.6

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential cmake git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "$WHISPER_VERSION" https://github.com/ggml-org/whisper.cpp /src
WORKDIR /src
RUN cmake -B build -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release \
  && cmake --build build -j --config Release --target whisper-server

FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends libgomp1 curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/bin/whisper-server /app/whisper-server
COPY --from=build /src/models/download-ggml-model.sh /app/download-ggml-model.sh
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh /app/download-ggml-model.sh

VOLUME /models
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
