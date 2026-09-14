---
name: workflow-inspector
description: Use when the user shares, points to, or asks to explain an existing ComfyUI workflow JSON file — e.g. "explain this workflow", "what does this node do", "walk me through workflows/x.json". Writes a node-by-node breakdown to a markdown handout instead of the terminal, tied to the project glossary, without treating the inspection as a full lesson unless the user says otherwise.
---

# Workflow Inspector Protocol

1. Read the target `.json` workflow file directly (don't guess from filename).
   If no path is given, resolve the active workflow per `AGENTS.md` → "Live
   ComfyUI": prefer the canonical `sessions/<date>_<topic>/workflows/current.json`
   if it exists, otherwise the most recently modified `.json` under
   `/content/ComfyUI/user/default/workflows/`. Note that this is the autosaved
   file, not the user's live canvas — if the canvas might have moved on, say so.
2. Write the node-by-node walkthrough to a markdown handout, not the terminal:
   - If there's an active session folder for today, save it as the next
     numbered file in that session's `session_handouts/`.
   - Otherwise, create `sessions/<date>_inspection-<short-name>/session_handouts/01-workflow-breakdown.md`.
   Walk the graph roughly in execution order — loaders (checkpoint, VAE, LoRA,
   ControlNet), then conditioning, then sampler, then decode/output — mapping
   each node to a section of `docs/genai-literacy-toc.md`.
3. In chat, give only a one-sentence headline (e.g. "uses ControlNet plus a
   distilled base checkpoint — full breakdown in the file") and the file path.
4. Call out anything unusual in the handout: custom nodes needing a specific
   extension, hardcoded values likely meant to be tuned, or VRAM-sensitive
   spots (e.g. no tiled VAE decode on a large image).
5. Don't log this as a lesson in `progress/progress-log.md` — an inspection is
   a lookup, not a lesson. Only hand off to the `genai-lesson` skill (and its
   logging step) if the user explicitly turns it into one.
