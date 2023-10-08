#syntax=docker/dockerfile:1.4

FROM python:3.10.11-slim
WORKDIR /app

ARG SD_WEBUI_REPO=AUTOMATIC1111/stable-diffusion-webui
ARG SD_WEBUI_REF=v1.6.0

ARG USERNAME=sd-webui
ARG UID=1000
ARG GID=$UID
RUN <<EOT
    set -eux
    groupadd --gid="$GID" "$USERNAME"
    useradd --create-home --uid="$UID" --gid="$GID" "$USERNAME"

    apt-get update
    apt-get install -y git build-essential libgl1 libglib2.0-0

    git clone -q \
       --config=advice.detachedHead=false \
       --branch="$SD_WEBUI_REF" \
       --depth=1 \
       "https://github.com/$SD_WEBUI_REPO.git" .

    chown -R sd-webui:sd-webui /app
EOT
USER sd-webui
ENV venv_dir=/data/venv

WORKDIR /app
CMD ["./webui.sh", "--listen", "--data-dir=/data", "--medvram", "--xformers", "--enable-insecure-extension-access"]
