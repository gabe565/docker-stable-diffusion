# Base image
FROM python:3.10.11-slim AS base

ARG SD_WEBUI_REPO=AUTOMATIC1111/stable-diffusion-webui
ARG SD_WEBUI_REF=v1.6.0

ARG USERNAME=sd-webui
ARG UID=1000
ARG GID=$UID
RUN groupadd --gid="$GID" "$USERNAME" \
    && useradd --create-home --uid="$UID" --gid="$GID" "$USERNAME"

RUN apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*


# Installs dependencies
FROM base AS installer
RUN apt-get update \
    && apt-get install -y build-essential \
    && rm -rf /var/lib/apt/lists/*

USER sd-webui
WORKDIR /app

RUN git clone -q \
        --config=advice.detachedHead=false \
        --branch="$SD_WEBUI_REF" \
        --depth=1 \
        "https://github.com/$SD_WEBUI_REPO.git" .

RUN set -x \
    && python3 -m venv venv \
    && . ./venv/bin/activate \
    && pip3 install --requirement=requirements.txt \
    && COMMANDLINE_ARGS=--skip-torch-cuda-test python3 -c 'from modules import launch_utils; launch_utils.prepare_environment()'


# Final image
FROM base

RUN apt-get update \
    && apt-get install -y --no-install-recommends libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

USER sd-webui
WORKDIR /app
COPY --from=installer --chown=1000 /app .

EXPOSE 7860
CMD ["./webui.sh", "--listen", "--data-dir=/data", "--medvram", "--xformers", "--enable-insecure-extension-access"]
