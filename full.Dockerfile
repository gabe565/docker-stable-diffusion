#syntax=docker/dockerfile:1.4

FROM python:3.10.11-slim AS base
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

    python3 -m venv venv
    . ./venv/bin/activate
    pip3 install --no-cache-dir --requirement=requirements.txt
    COMMANDLINE_ARGS=--skip-torch-cuda-test python3 -c \
      'from modules import launch_utils; launch_utils.prepare_environment()'

    apt-get purge -y build-essential
    apt-get autoremove --purge -y
    rm -rf /var/lib/apt/lists/*

    chown -R sd-webui:sd-webui /app
EOT

USER sd-webui
EXPOSE 7860
CMD ["./webui.sh", "--listen", "--data-dir=/data", "--medvram", "--xformers", "--enable-insecure-extension-access"]
