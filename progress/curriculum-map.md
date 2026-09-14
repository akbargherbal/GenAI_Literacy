# Curriculum Map

This mirrors `docs/genai-literacy-toc.md` purely as a passive catalog of what's
been touched hands-on. **It is not a checklist to complete and not an order to
follow.** Sessions can jump around freely, repeat things, or skip whole
sections — check a box only after a session actually exercises it, and don't
let an unchecked box read as "owed."

## §1 Big picture pipeline
- [ ] Text → latent → decode flow

## §2 Core architecture vocabulary
- [ ] Diffusion vs. flow matching
- [ ] VAE encode/decode round trip
- [ ] U-Net vs. DiT
- [ ] Text encoder differences (CLIP / T5 / Llama-based)

## §3 Generation-time controls
- [ ] Sampler + scheduler pairing
- [ ] CFG / guidance scale
- [ ] Steps vs. distilled/turbo step counts
- [ ] Seed reproducibility
- [ ] Denoise strength (img2img / inpainting)

## §4 Adaptation & customization
- [ ] LoRA: loading, strength, stacking
- [ ] LyCORIS vs. LoRA
- [ ] Textual inversion / embedding
- [ ] ControlNet + a preprocessor
- [ ] IP-Adapter

## §5 Efficiency & quantization
- [ ] fp16/bf16 vs fp8
- [ ] A GGUF-quantized model
- [ ] Nunchaku/SVDQuant or similar 4-bit workflow
- [ ] Turbo/lightning/distilled variant vs. base
- [ ] Tiled VAE decode / VRAM troubleshooting

## §6 Model landscape
- [ ] SD1.5/SDXL-era model
- [ ] FLUX-family or DiT-based image model
- [ ] A video model (even scaled down)
- [ ] An audio/music model (e.g. ACE-Step)

## §7 ComfyUI vocabulary
- [ ] Read an unfamiliar workflow node-by-node before running it
- [ ] Installed a custom node via ComfyUI Manager
- [ ] Built a workflow from scratch

## §8 Hugging Face vocabulary
- [ ] Picked a model by reading its model card (VRAM, license, format)
- [ ] Compared safetensors vs. an older format

## §9 OpenCode / agent vocabulary
- [ ] Used OpenCode to modify a specific node in an existing workflow

---
*If a session surfaces a concept not yet in the glossary, add it to
`docs/genai-literacy-toc.md` and a row here at the same time — no need to ask
permission first.*
