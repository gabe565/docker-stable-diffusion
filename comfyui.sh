#!/usr/bin/env bash
set -euxo pipefail

python3 -m venv /data/venv
. /data/venv/bin/activate

pip install -r requirements.txt
exec python main.py "$@"
