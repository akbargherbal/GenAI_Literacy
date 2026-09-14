---
name: genai-lesson
description: Use whenever the user wants to start or run a hands-on generative AI learning session — phrases like "let's learn about X model", "teach me Y", "let's do a session on audio/image/video generation". Structures a self-contained session around a chosen HuggingFace model and a ComfyUI workflow, writing substantial explanations to markdown handouts instead of the terminal, and quietly updating the project's progress log and curriculum checklist without implying any review is owed.
---

# GenAI Lesson Protocol

Each session is self-contained. Don't treat past sessions as prerequisites,
don't recap them unprompted, and don't imply the user is behind on anything.

## 1. Set up the session folder
Create `sessions/<YYYY-MM-DD>_<topic-slug>/` with two subfolders:
`session_handouts/` and `workflows/`. Everything this session produces lives here.

## 2. Concept handout
Write the concept explanation to `session_handouts/01-concept.md`, citing the
relevant section(s) of `docs/genai-literacy-toc.md` by number. Zero math, plain
language, tied to something concrete. In chat, give only a 1-2 sentence teaser
and the file path — don't re-paste the explanation into the terminal.

If (and only if) today's topic clearly overlaps something from a past session,
you may add one skippable sentence noting the related handout exists — never
framed as required reading.

## 3. Hands-on
Pick or confirm a HuggingFace model that fits the available GPU (L4 24GB or
T4 16GB; check glossary §5 for quantized/distilled options if the base model
doesn't fit). Build or modify a ComfyUI workflow, saving it to
`workflows/<descriptive-name>.json` inside this session's folder.

If the user is iterating live in ComfyUI, keep `workflows/current.json` in this
session as the canonical live file (see `AGENTS.md` → "Live ComfyUI"): read it
before answering anything about current values, and tell the user to hard-reload
the tab after you write a new one. For the fuller sync rationale and optional
watcher/push layers, see `docs/comfyui-agent-sync.md`.

If the change is more than a couple of nodes, write a walkthrough to
`session_handouts/02-workflow-walkthrough.md` explaining what changed and why,
node by node. For a trivial one-node tweak, a single chat sentence is enough —
don't file something that short.

## 4. Comprehension check
Keep this in chat. It's a quick back-and-forth, not a document — e.g. "if I
dropped CFG to 2 here, what would you expect to happen?" Let the user answer
in their own words.

## 5. Quiet bookkeeping
- Append an entry to `progress/progress-log.md`.
- Update the relevant checkbox(es) in `progress/curriculum-map.md`.
- Add a row to `sessions/INDEX.md` linking the new handouts and workflow(s).
- Confirm in one short line that this happened. Don't turn it into study
  advice or a "next time" plan unless the user asks what else is available.
