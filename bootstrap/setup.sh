#!/usr/bin/env bash
# GenAI Dojo — Colab bootstrap script
#
# Run this BACKGROUNDED while you do `./code tunnel` auth in the foreground,
# so the auth wait and the install/download time overlap instead of stacking:
#
#   bash bootstrap/setup.sh > /content/setup.log 2>&1 &
#   ./code tunnel
#
# This script is deliberately non-interactive. Do NOT add `read`/prompts
# here — if it's backgrounded (`&`) while you're typing into `./code tunnel`,
# a prompt here would hang forever waiting on stdin that's going elsewhere.
# Anything needing your input (e.g. "which model today?") belongs in the
# Colab notebook cell instead — see colab_cells.md — which runs BEFORE this
# script and writes its answer into /root/.secrets.env as MODEL_REPO.

set -e

# Non-interactive bash does NOT auto-source ~/.bashrc, so secrets have to be
# pulled in explicitly here rather than relying on shell startup files.
source /root/.secrets.env

echo "=== $(date) — GenAI Dojo setup starting ==="

# --- OpenCode ---
if ! command -v opencode &>/dev/null; then
  echo "Installing OpenCode..."
  curl -fsSL https://opencode.ai/install | bash
else
  echo "OpenCode already installed, skipping."
fi

# --- ComfyUI ---
if [ ! -d ComfyUI ]; then
  echo "Cloning ComfyUI..."
  git clone https://github.com/comfyanonymous/ComfyUI.git
fi
cd ComfyUI
# TODO (open item): pin to a known-good commit/tag once you've confirmed one
# works for you across a few real sessions. Until then this floats to HEAD,
# which is the one accepted risk we deferred this round.
# git checkout <PINNED_SHA_HERE>
pip install -q -r requirements.txt
cd ..

# --- Hugging Face auth ---
# Writes the token to ~/.cache/huggingface/token, which every later process
# on this VM (terminal, ComfyUI, custom nodes) reads automatically — no env
# var passing needed after this point. hf_xet handles fast downloads
# automatically in current huggingface_hub; no HF_HUB_ENABLE_HF_TRANSFER
# env var is needed (that flag is deprecated).
hf auth login --token "$HF_TOKEN"

# --- Model download (optional — chosen in the notebook cell before this ran) ---
if [ -n "$MODEL_REPO" ]; then
  echo "Downloading $MODEL_REPO ..."
  hf download "$MODEL_REPO" --local-dir "ComfyUI/models/checkpoints/$(basename "$MODEL_REPO")"
  echo "NOTE: if this is a split-component model (FLUX and similar — see"
  echo "docs/genai-literacy-toc.md), this single download is not enough."
  echo "Check the warning table before assuming the workflow will run."
else
  echo "No model requested this session — skipping download."
fi

echo "=== setup.sh done — tail /content/setup.log to check progress ==="
