#!/usr/bin/env bash
set -euo pipefail

TASK="${1:-}"

ollama run dots.llm1 "$TASK"