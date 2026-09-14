# Agent ↔ ComfyUI Sync

_How the agent sees and changes your running ComfyUI — and where the hard limits
are. The short, always-loaded version of this lives in `AGENTS.md`; this file is
the fuller rationale and design options._

---

## 1. The pitfall, named precisely

Three separate things get tangled together. Untangling them is the whole design.

1. **The live canvas is client-side state.** What's drawn in the browser tab is not
   on the server. ComfyUI exposes no API to read or overwrite the graph you're
   currently looking at. "Read my screen" is not a thing the agent can do.
2. **The frontend caches the workflow list and settings.** When the agent writes a
   new `.json` into the workflows folder, the server serves it immediately — but an
   already-open tab still holds the old list, so the sidebar looks unchanged until a
   hard reload.
3. **The agent has no background awareness.** It only runs when you send a turn.
   Between turns it is not watching anything. "Sync" therefore does not mean *the
   agent is watching live* — it means *when invoked, it can reconstruct your exact
   current state in one deterministic read.*

**So we're not chasing real-time — we're chasing "one reliable read."** Real-time is
a bonus layer you can add later.

---

## 2. What we get for free

Verified against this repo's ComfyUI (`/content/ComfyUI`, port 8188):

- **Autosave.** The frontend flushes the active workflow to
  `user/default/workflows/<name>.json`. This is *why* the agent can see edits at all:
  the file's size and mtime change on save.
- **The userdata API** — the exact call the sidebar makes:
  ```
  GET /userdata?dir=workflows&recurse=true&split=false&full_info=true
  → [{"path": "...", "size": ..., "modified": ..., "created": ...}]
  ```
  Even without parsing files, mtime+size tells the agent *that* something changed.
- **Run history.** After you press *Queue Prompt*, `/history` and `/queue` hold the
  exact graph that executed (API format), independent of any file.

**Gap that remains:** none of these say *which* file is the one on your canvas, and
none of them fire until the agent looks.

---

## 3. Design — layered, cheapest first

### Layer 0 — Diff the autosave (works today)
Agent lists the workflows dir, compares `size`/`modified`, parses the changed file,
diffs `widgets_values` and node set. Zero setup. Weakness: pull-only — the agent
must be told to look.

### Layer 1 — One canonical "live" file (a convention, ~free)
Agree that **one known path is always the working workflow**, e.g.
`sessions/<session>/workflows/current.json`, kept open in ComfyUI and saved there.
The agent's rule becomes: *read that path first, every time, before answering
anything about state.* Highest leverage for the effort.

### Layer 2 — A changelog watcher (small, cheap)
A background process watches the workflows dir and appends timestamped entries:

```bash
inotifywait -m -e close_write --format '%T %f' \
  --timefmt '%Y-%m-%dT%H:%M:%S' \
  /content/ComfyUI/user/default/workflows \
  >> sessions/<session>/workflows/.change.log
```

(No `inotifywait`? A 2-second `stat` poll loop does the same.) The agent tails that
log to see *when* and *what* changed since its last turn. Still pull-based, but it
removes the "I didn't notice" failure — the history is on disk, not just in the
agent's attention.

### Layer 3 — True push (real "no lag", more moving parts)
A tiny **frontend extension** hooks ComfyUI's graph-change events and, on a debounce
(~500 ms), mirrors the live graph somewhere readable — `POST` to a local endpoint or
write `.live.json`. The canvas is then mirrored *as you type*, not on save. Cost:
adding code inside ComfyUI; a new extension usually needs at least a page reload
(possibly a server restart, which is disruptive since ComfyUI runs from a terminal).

---

## 4. Recommendation

- **Layer 1 immediately** — a naming convention; makes every "what's the current
  value of X?" a single read.
- **Layer 2** if you want "what changed since last time" answered without you having
  to remember. No ComfyUI internals touched.
- **Hold Layer 3** until pull-based sync actually annoys you.

---

## 5. What no design fixes (honest limits)

- The agent only acts when you send a turn. "No lag" = *fast, reliable reconstruction
  on demand*, not a live feed it's watching.
- **Un-saved, in-memory edits** (before autosave/debounce) are invisible to every
  layer except a push extension.
- **Multiple open tabs = multiple live canvases.** Only the autosaved one lands on
  disk.
- Canvas *view* state — selection, viewport, undo stack — is never mirrored.

---

## 6. Quick reference — the exact hooks

| What | Where |
|---|---|
| ComfyUI install | `/content/ComfyUI` (default API `http://127.0.0.1:8188`) |
| Autosaved workflow | `/content/ComfyUI/user/default/workflows/<name>.json` |
| List w/ mtime+size | `GET /userdata?dir=workflows&recurse=true&split=false&full_info=true` |
| User settings (e.g. minimap) | `/content/ComfyUI/user/default/comfy.settings.json`, served at `GET /settings` |
| Last executed graph | `GET /history`, `GET /queue` |
| Installed node types | `GET /object_info` |
| Live events (execution only) | `ws://127.0.0.1:8188/ws` — fires on runs, **not** on canvas edits |

---

_Related glossary: §7 (workflow / node / queue), §9 (agent tool-use loop, workflow
JSON as shared artifact, live canvas vs. saved artifact, autosave / userdata API)._
