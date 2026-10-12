# whisper-server

Transcripción de voz propia para los dictados del blog: [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
detrás de Caddy, que pone HTTPS y exige un secreto. Corre fuera de Vercel, en
cualquier máquina con Docker.

```
móvil ──WAV──▶ Vercel (/api/...) ──WAV + Bearer──▶ Caddy ──▶ whisper-server ──▶ { "text": "…" }
```

## Puesta en marcha

1. Apunta un dominio a la IP de la máquina y abre
   los puertos 80 y 443.
2. Configura:

   ```bash
   cp .env.example .env
   openssl rand -hex 32   # pégalo en WHISPER_SECRET
   ```

3. Arranca. La primera vez compila whisper.cpp (unos minutos) y descarga el
   modelo al volumen `models`:

   ```bash
   docker compose up -d --build
   docker compose logs -f whisper
   ```

Compila en la propia máquina: el binario se optimiza para la CPU que lo construye.

## Probar

```bash
curl -H "Authorization: Bearer $WHISPER_SECRET" \
  https://{DOMINIO}/inference \
  -F file=@audio.wav -F response_format=json
```

Sin el secreto responde `401`. Acepta WAV de 16 kHz mono, que es lo que graba
`src/lib/recorder.ts` en el blog.

## Modelos

Se elige con `WHISPER_MODEL` en `.env`. Al cambiarlo se descarga el nuevo en el
siguiente arranque (`docker compose up -d`).

| Modelo | Tamaño | Notas |
|---|---|---|
| `large-v3-turbo-q5_0` | ≈550 MB | Por defecto. Buena calidad en español |
| `small` | ≈470 MB | Algo peor, algo más rápido |
| `base` | ≈140 MB | Rápido, flojo en español |

## Sin dominio (Cloudflare Tunnel o en local)

Pon `DOMAIN=:80` y Caddy sirve HTTP sin certificado; el túnel pone el HTTPS.
El secreto se sigue exigiendo.
