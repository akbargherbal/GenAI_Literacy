# Colab notebook cells — GenAI Dojo bootstrap

These run in the notebook, *before* you open the Colab terminal. Paste each
into its own cell, in this order.

## Cell 1 — stage secrets + pick today's model (interactive, runs first)

This is the only interactive step in the whole bootstrap. It reads your
Colab secrets (the key icon in the left sidebar — make sure `HF_TOKEN` and
`DEEPSEEK_API_KEY` are added there first) and writes them to a file every
later shell can read, then asks once whether you want a model downloaded
this session.

```python
from google.colab import userdata

model_choice = input("Model repo to download this session (blank = skip): ").strip()

with open('/root/.secrets.env', 'w') as f:
    f.write(f'export DEEPSEEK_API_KEY="{userdata.get("DEEPSEEK_API_KEY")}"\n')
    f.write(f'export HF_TOKEN="{userdata.get("HF_TOKEN")}"\n')
    if model_choice:
        f.write(f'export MODEL_REPO="{model_choice}"\n')

marker = 'source /root/.secrets.env'
with open('/root/.bashrc') as f:
    already_wired = marker in f.read()
if not already_wired:
    with open('/root/.bashrc', 'a') as f:
        f.write(f'\n{marker}\n')

print("Secrets staged. Open the Colab terminal now.")
```

**Why the model question is here and not in `setup.sh`:** `setup.sh` gets
run backgrounded (`&`) so it can overlap with `./code tunnel` auth. A prompt
inside a backgrounded script hangs silently forever, waiting on stdin that's
actually going to the tunnel auth. Asking here, before anything is
backgrounded, avoids that trap entirely.

## Cell 2 — nothing to run, just a reminder

Once cell 1 has printed "Secrets staged," switch to the **Colab terminal**
(not a notebook cell) and run:

```
bash bootstrap/setup.sh > /content/setup.log 2>&1 &
./code tunnel
```

Do the tunnel authentication while `setup.sh` installs OpenCode, clones
ComfyUI, and (if you gave one) downloads today's model in the background.
Check `/content/setup.log` afterward, or `tail -f /content/setup.log` in a
second terminal tab if you want to watch it live.
