# Progress Log

A catalog, not a syllabus. Append one entry per session, most recent last.
Nothing here implies the next session needs to review or build on it — it's
here purely so you can look back later if you're curious, e.g. "did I ever
cover ControlNet preprocessors?"

## Entry template

```
### YYYY-MM-DD — <short session title>
- **Model(s):**
- **Glossary sections touched:**
- **Session folder:** sessions/<folder-name>/
- **Handouts:** session_handouts/01-....md, session_handouts/02-....md
- **Notes to self (optional, not homework):**
```

---

### 2026-09-14 — Agent ↔ ComfyUI sync (test session)
- **Model(s):** none loaded yet (only `Breeze-TTS-2` in `models/checkpoints/`; no image model on disk)
- **Glossary sections touched:** §7 (workflow/node/queue), §9 (agent tool-use loop, workflow JSON as shared artifact; added "live canvas vs. saved artifact" and "autosave / userdata API")
- **Session folder:** sessions/2026-09-14_agent-comfyui-sync/
- **Handouts:** none session-level; framework doc at `docs/comfyui-agent-sync.md` (+ new `AGENTS.md` "Live ComfyUI" section, `workflow-inspector` skill update)
- **Workflow(s):** workflows/opencode-test-txt2img-as-edited.json (agent-authored SD1.5 txt2img graph; user edited the positive prompt)
- **Notes to self (optional, not homework):** tested whether the agent can perceive/edit the live ComfyUI — confirmed it can read the autosaved workflow JSON and the settings file, but not the client-side canvas. User settings flipped (`Comfy.Minimap.Visible` false→true) as a visible-reach demo.
