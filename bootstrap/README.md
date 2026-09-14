# Bootstrap

Environment setup for a Colab-backed session — deliberately kept separate
from the teaching content (`AGENTS.md`, `.opencode/skills/`, `sessions/`).
This folder answers "how do I get a working shell with OpenCode + ComfyUI
running," not "what does the agent teach once I'm in." OpenCode itself
never needs to read anything in here.

## Files

- `colab_cells.md` — paste these into your Colab notebook, in order, before
  opening the terminal. Handles secrets staging and (optionally) picking a
  model to download this session.
- `setup.sh` — run backgrounded from the Colab terminal, in parallel with
  `./code tunnel` auth. Installs OpenCode, clones ComfyUI, logs in to
  Hugging Face, downloads a model if one was requested.

## The one-time setup

Add two secrets in Colab's sidebar (key icon): `HF_TOKEN` and
`DEEPSEEK_API_KEY`. After that, every session is: run cell 1 from
`colab_cells.md`, switch to the terminal, run the two-line launch. No
copy-pasting keys, ever.

## Known open items (not yet solved — deferred on purpose, not forgotten)

- **ComfyUI isn't pinned to a commit.** `setup.sh` has a `TODO` where the
  `git checkout <sha>` would go. Floating to HEAD is the accepted risk for
  now; pin it once you've had a version that's worked reliably across a few
  sessions.
- **Port 8188 defaults to whatever ComfyUI/the tunnel set it to** — check
  the Ports panel in vscode.dev and set it to Private if you're leaving a
  session running unattended for a while.
- **Split-component models (FLUX and similar) aren't auto-fixed.** See the
  warning table addition for `docs/genai-literacy-toc.md` — the plan is
  warn-before-download, not repair-after.
