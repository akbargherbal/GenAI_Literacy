# Generative AI Literacy — A User's Table of Contents
*For working with ComfyUI + Hugging Face models + OpenCode, on an L4/T4 GPU. No math required — this is "know what the knob does," not "derive the knob."*

---

## How to use this doc

Each section is a cluster of terms you'll bump into together. Work top to bottom — later sections assume you're loosely familiar with earlier ones. For each term: a plain-English definition, and *where you'll actually see it* (a ComfyUI node, a HF model card field, or a filename pattern).

---

## 1. The Big Picture Pipeline

Before the vocabulary, the shape of the whole thing. Almost every image/audio/video generative model you'll touch follows this pipeline:

```
Text prompt → Text Encoder → "Latent space" → Diffusion/Denoising loop → VAE Decode → Pixels/Waveform
```

- **Text-to-X** — text is turned into a numeric representation, then that representation guides an iterative "sculpting" process that ends in an image, audio clip, or video.
- **Latent space** — a compressed, abstract representation of the image/audio that the model actually works in (not raw pixels). Compression is *why* generation is fast enough to run on a consumer GPU.
- **Pipeline** — HF's word for "the whole chain of components (text encoder + model + VAE) wired together to go from prompt to output."

---

## 2. Core Architecture Vocabulary
*(You need to recognize these words on a model card. You don't need to know the math behind them.)*

| Term | Plain-English meaning | Where you'll see it |
|---|---|---|
| **Diffusion model** | A model that generates by starting from random noise and gradually "denoising" it into a coherent output over many steps. | Most SD/SDXL/FLUX-era models |
| **Flow matching** | A newer, related generation method (used by FLUX, Qwen-Image, Z-Image) — same "start messy, end clean" idea, but the math path is different. As a user, treat it like diffusion: same knobs (steps, sampler), often faster convergence. | Model cards for FLUX, Qwen-Image, Z-Image |
| **VAE (Variational Autoencoder)** | The component that translates between latent space and real pixels/audio. "VAE Decode" = latent → final image. "VAE Encode" = image → latent (needed for image-to-image). | `VAELoader`, `VAEDecode`, `VAEEncode` nodes in ComfyUI |
| **U-Net** | The older-style "denoiser" architecture (SD1.5, SDXL). | Legacy models |
| **DiT (Diffusion Transformer)** | The newer denoiser architecture (FLUX, Z-Image, Qwen-Image, most video/audio models now). Just know: DiT-based models are the current generation and tend to scale better. | Model cards, "Transformer" loader nodes |
| **Text encoder / CLIP** | Converts your prompt text into the numeric guidance signal. Different models use different text encoders (CLIP, T5, Llama-based) — this is why prompt style that works for SD1.5 doesn't always work for FLUX. | `CLIPLoader`, `DualCLIPLoader` nodes |
| **Attention** | The mechanism that lets the model relate different parts of the prompt to different parts of the image. You'll mostly meet this indirectly, via *attention/prompt weighting* syntax like `(word:1.3)`. | Prompt syntax |
| **Checkpoint** | A saved, trained model — the actual file you load. "Loading a checkpoint" = loading a specific model's brain. | `.safetensors` files, `CheckpointLoader` node |

---

## 3. Generation-Time Controls
*(These are the dials you'll turn constantly. This is the highest-leverage section for hands-on fluency.)*

- **Sampler** — the specific step-by-step algorithm used to do the denoising (e.g., Euler, DPM++ 2M, UniPC). Different samplers trade off speed vs. quality vs. "look." Practically: try 2–3, keep the one you like.
- **Scheduler** — controls *how much* noise is removed at each step across the run (e.g., normal, karras, sgm_uniform). Paired with the sampler in ComfyUI's `KSampler` node.
- **Steps** — how many denoising iterations to run. More steps ≈ more refinement, with diminishing returns (and some models are specifically distilled to need very few — see §5).
- **CFG / Guidance Scale** — how strongly the model is pushed to follow your prompt vs. wander freely. Low = more creative/loose, high = more literal (and can get "crispy"/over-saturated if too high).
- **Seed** — the starting random noise pattern. Same seed + same settings = reproducible output. This is your "undo/redo" for experimentation.
- **Denoise strength** — used in image-to-image and inpainting: how much of the original image to destroy and rebuild (1.0 = full regeneration, 0.3 = light restyle).
- **Latent** — the in-progress "canvas" that gets passed between nodes before final VAE decode. In ComfyUI you'll literally see "Latent" as a wire/data type connecting nodes.
- **Positive / negative prompt** — what to aim for vs. what to steer away from.

---

## 4. Adaptation & Customization
*(How people make a base model do something specific without retraining it from scratch — this is most of what makes ComfyUI powerful.)*

- **LoRA (Low-Rank Adaptation)** — a small "patch" file (tens to hundreds of MB, vs. GBs for a full model) that nudges a base model toward a specific style, character, or concept. You stack these, adjust their **strength/weight**, and can load several at once. This is the single most important adaptation concept for a ComfyUI user.
- **LyCORIS** — a family of LoRA-like alternatives (LoHa, LoCon, etc.) with different trade-offs; functionally, treat like "a fancier LoRA."
- **Textual Inversion / Embedding** — an even smaller file that teaches the model a new *word* (tied to a concept/style) rather than adjusting model weights. Less powerful than LoRA, but tiny.
- **DreamBooth** — a *training method* (not a file type) for teaching a model a specific subject by fine-tuning on a handful of images. You'll see this term mostly in the context of "how was this checkpoint/LoRA made," not something you do casually.
- **ControlNet** — a companion network that lets you guide generation using a structural signal — an edge map, a depth map, a pose skeleton — instead of (or alongside) text. Needs a matching **preprocessor** (e.g., Canny edge detector, DWPose, Depth Anything) to turn your reference image into the control signal first.
- **IP-Adapter** — lets you use a reference *image* as a style/identity guide (instead of a structural map like ControlNet). Common for "make it look like this person/style."
- **Control-LoRA** — a lighter-weight alternative to full ControlNet, packaged as a LoRA.

---

## 5. Efficiency & Quantization
*(This is the section that actually matters for your L4/T4 — what makes a model fit and run fast.)*

- **Precision (fp32 / fp16 / bf16 / fp8)** — how many bits are used to store each number in the model. Lower precision = smaller file, less VRAM, faster — usually with a small, often invisible quality cost. Most ComfyUI workflows default to fp16 or bf16 already.
- **Quantization** — more aggressive compression than just lowering precision, often down to 8-bit, 4-bit, or lower. This is *the* technique for running big models (FLUX, Qwen-Image) on 8–24GB cards.
- **GGUF** — a quantized file format (borrowed from the LLM world) increasingly used for diffusion/DiT models in ComfyUI. If you see a model with a `.gguf` extension and a "Q4/Q8" label, that's this.
- **SVDQuant / Nunchaku** — a specific modern 4-bit quantization method + its ComfyUI plugin, notable for keeping quality high at 4-bit. Worth knowing by name since it shows up a lot for FLUX/Qwen-Image/Z-Image on smaller GPUs.
- **Distilled / Turbo / Lightning / LCM models** — versions of a base model specifically retrained to need far fewer steps (e.g., 4–8 instead of 20–30) for similar quality. Huge deal for iteration speed on a single GPU.
- **CPU offload** — moving parts of the model to system RAM when they're not actively needed, trading speed for the ability to run bigger models on less VRAM.
- **Tiled VAE / Tiled decoding** — decoding a large latent in chunks instead of all at once, so you don't run out of VRAM at the final image-decode step (a common failure point, not the main model!).
- **VRAM** — GPU memory. The single most common thing you'll be managing as a hands-on user. L4 = 24GB, T4 = 16GB — both fine for quantized versions of most current open models.

---

## 6. The Model Landscape (2026 snapshot)
*(Names you'll see on Hugging Face and in ComfyUI workflow templates.)*

- **Image**: Stable Diffusion 1.5 / SDXL (older, U-Net-based, huge LoRA ecosystem) → FLUX (DiT/flow-matching, high quality, heavier) → Qwen-Image, Z-Image Turbo (newer DiT models, strong at smaller footprints, fast "Turbo" variants).
- **Video**: Wan, AnimateDiff (motion added on top of an image model), Step-Video, HunyuanVideo — heavier, usually need aggressive quantization or shorter clips on an L4.
- **Audio/Music**: ACE-Step (text-to-music, including a fast 1.5 line with quantized/turbo variants; supports LoRA fine-tuning per artist/style), Stable Audio Open — this is the closest audio analogue to what SD did for images.
- **Base model vs. fine-tune vs. merge** — a "base model" is the original release; a "fine-tune" is retrained on more data for a specific look; a "merge" blends the weights of two+ checkpoints together (common in the SD1.5/SDXL "checkpoint culture" you'll see on CivitAI).

---

## 7. ComfyUI-Specific Vocabulary
*(The tool itself, since your workflow will be built as a JSON graph.)*

- **Node** — one processing block in the graph (e.g., "Load Checkpoint," "KSampler," "VAE Decode"). Each does one job.
- **Workflow** — the full graph of connected nodes, saved as a `.json` file — this is the thing your agent (OpenCode) can generate and you drag-and-drop.
- **Widget vs. Input** — a node's settings can either be a fixed value you type in (widget) or a wire coming from another node (input) — this distinction is what lets you, e.g., swap a hardcoded seed for a random-seed generator.
- **Custom nodes** — community-built extensions (installed via **ComfyUI Manager**) that add support for new models, techniques (Nunchaku, ACE-Step, IPAdapter, etc.), or conveniences. Almost everything past "vanilla Stable Diffusion" requires installing custom nodes.
- **Model / VAE / LoRA / ControlNet loaders** — the family of nodes whose only job is "point me at a file on disk and hand its data downstream."
- **Preprocessor** — a node that converts a plain image into a control signal for ControlNet (e.g., turning a photo into a depth map or edge map).
- **Queue** — ComfyUI executes a workflow when you hit "Queue Prompt"; understanding the queue (and that only *changed* parts of the graph re-run) explains why iterating is fast.

---

## 8. Hugging Face-Specific Vocabulary

- **Model card** — the README-style page for a model; check here for VRAM requirements, license, and example usage before downloading.
- **`safetensors`** — the standard, safe (no arbitrary code execution) file format for model weights today; prefer these over older `.ckpt`/`.bin` files.
- **`diffusers`** — Hugging Face's Python library for running diffusion pipelines outside ComfyUI (relevant if OpenCode ever writes you a raw Python/Colab script instead of a ComfyUI workflow).
- **Repo / revision / branch** — a HF model lives in a git-like repo; "revision" lets you pin a specific version (useful when a model updates and breaks your workflow).
- **License tags** (Apache-2.0, OpenRAIL, non-commercial, etc.) — worth a glance before you use outputs commercially; varies a lot model to model (e.g., ACE-Step is Apache-2.0/commercial-friendly).

---

## 9. Working With OpenCode as Your "Instructor"

A few working concepts, since you're using an agent as the interface:

- **Agent / tool-use loop** — OpenCode isn't just chatting; it's calling tools (reading files, running code, hitting the ComfyUI API) and reacting to results. Useful to know so you can tell when it's "looking something up" vs. "guessing."
- **MCP (Model Context Protocol)** — the standard way agents like OpenCode connect to external tools/services (e.g., a ComfyUI server, a file system). This is the plumbing that lets it "see" your ComfyUI setup.
- **Workflow JSON as the shared artifact** — the most productive way to use OpenCode here is treating the `.json` workflow file as the thing you co-edit: ask it to modify a specific node's settings or add a node, rather than "regenerate everything," so you can track what changed.

---

## Suggested order to actually learn this

1. **§1 + §3** (pipeline shape + generation controls) — get comfortable turning knobs on an existing workflow.
2. **§7** (ComfyUI nodes) — learn to read a graph before building one.
3. **§4** (LoRA/ControlNet) — this is where "user literacy" pays off most; it's 90% of what people do with ComfyUI day to day.
4. **§5** (quantization/efficiency) — once you hit your first VRAM error, this section becomes very motivating.
5. **§2 + §6** (architecture + model landscape) — background literacy for reading model cards and understanding *why* a new model behaves differently, without needing the underlying math.
6. **§8 + §9** — pick up as needed when you start scripting outside pure drag-and-drop.

---

*Note: quantization method names, model releases (Z-Image, ACE-Step 1.5, etc.), and specific ComfyUI node names move fast — treat the model/tool names in §5–§6 as a snapshot of September 2026, and expect the underlying concepts (LoRA, VAE, quantization, sampler/scheduler) to stay stable much longer than any specific model name.*
