#!/usr/bin/env bash
set -euo pipefail

TASK="${1:-}"

ollama run qwen3.5:35b-a3b-coding-nvfp4 "$TASK"