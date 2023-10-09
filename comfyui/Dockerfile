#syntax=docker/dockerfile:1.4

FROM python:3.10.11-slim
WORKDIR /app

ARG REPO=comfyanonymous/ComfyUI
ARG REF=master

ARG USERNAME=sd
ARG UID=1000
ARG GID=$UID
RUN <<EOT
    set -eux
    groupadd --gid="$GID" "$USERNAME"
    useradd --create-home --uid="$UID" --gid="$GID" "$USERNAME"

    apt-get update
    apt-get install -y --no-install-recommends \
      git wget
    rm -rf /var/lib/apt/lists/*

    git clone -q \
      --config=advice.detachedHead=false \
      --branch="$REF" \
      --depth=1 \
      "https://github.com/$REPO.git" .

    chown -R sd:sd /app
EOT
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

USER sd
EXPOSE 8188
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--listen", "--output-directory=/data/output"]