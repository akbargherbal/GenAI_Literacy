# GenAI Dojo

A stateless-agent-friendly setup for learning generative AI hands-on with
OpenCode + ComfyUI + Hugging Face models, on a Colab L4/T4 GPU — designed to
be read comfortably in a browser, and to never feel like a course with
homework.

## Why this structure

OpenCode has no memory between sessions. This repo *is* the memory, but
deliberately a low-pressure one:

- `AGENTS.md` — standing instructions read every session: teaching rules,
  and the rule that substantial explanations go to files, not the terminal.
- `.opencode/skills/genai-lesson/` — the reusable lesson protocol (concept
  handout → hands-on → quick check → quiet bookkeeping).
- `.opencode/skills/workflow-inspector/` — for "explain this workflow"
  requests that aren't a full lesson.
- `docs/genai-literacy-toc.md` — the shared glossary; explanations cite a
  section from here instead of re-deriving concepts each time.
- `sessions/` — one folder per session, `<date>_<topic-slug>/`, each with:
  - `session_handouts/` — numbered markdown files (`01-concept.md`,
    `02-workflow-walkthrough.md`, ...) meant to be opened in a browser.
  - `workflows/` — the ComfyUI `.json` file(s) built or modified that session.
- `sessions/INDEX.md` — a flat table linking every session's handouts and
  workflows, for browsing later. Not a syllabus.
- `progress/progress-log.md` and `progress/curriculum-map.md` — quiet
  bookkeeping the agent maintains for its own context and your optional
  curiosity. Nothing here is meant to be "caught up on" before a session.

## The no-pressure rule

This is explicitly not a course. Every session should be self-contained:

- Sessions never open with "last time we covered X, so..." — no recap is owed.
- Past handouts are referenced, if at all, as a single skippable aside
  ("there's also a handout on this from before, if you're curious") — never
  as a prerequisite.
- Reading a handout is optional. Doing a session out of order, repeating a
  topic, or never touching the checklist is all fine.

If this framing ever slips (the agent starts implying you're behind or need
to review something), that's a bug in `AGENTS.md` worth calling out directly.

## Reading handouts

Handouts are plain markdown files under `sessions/<...>/session_handouts/`.
Open them in whatever's convenient — a browser via a local file server, VS
Code's markdown preview, GitHub's rendering if you push the repo, etc. The
terminal is only used for the back-and-forth (hands-on building, quick
comprehension checks) — not for reading explanations.

## Colab persistence — read this before your first session

Colab's local disk does **not** survive a runtime restart. Since this system
depends on files on disk, use one of:

1. **Git repo** (recommended) — `git pull` at the start of a session,
   `git add -A && git commit && git push` at the end.
2. **Google Drive mount** — keep the whole `genai-dojo/` folder in Drive.

Either works. Without one of these, a runtime reset wipes every handout,
workflow, and log entry.

## Starting a session

Just talk to OpenCode normally — e.g. "let's do a session on LoRA using a
Z-Image checkpoint." The `genai-lesson` skill sets up today's session folder,
writes the concept explanation to a handout, builds the workflow, and does a
quick check in chat — no manual setup needed.
