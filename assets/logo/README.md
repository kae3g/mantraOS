# Guardian Dragon – Logo Assets (for Technical Contributors)

This folder contains the Guardian Dragon **logo/mascot** assets and a small pipeline for working with generated drafts.

## What's here

```
assets/logo/
guardian-dragon-lineart.svg     # vector line-art "skeleton" for img2img workflows
logo-prompt-guide.md            # prompt guide for generating mascot/logo variations
drafts/
incoming/                     # drop newly generated PNGs here
processed/                    # vectorized & renamed outputs
archive/                      # optional, for dated/tagged sets
tools/
logo-pipeline.sh              # rasterize/convert helpers
validate.py                   # asset validator (pairing, naming, sizes; optional LFS checks)
```

## Quick Start

```bash
# 1) Rasterize the line-art for img2img (creates drafts/lineart_2048.png)
make logo-rasterize

# 2) Generate PNGs with your tool into:
#    assets/logo/drafts/incoming/*.png

# 3) Vectorize & sort
make logo-vectorize

# 4) (Optional) Archive processed results with a tag
make logo-archive TAG=v001

# 5) Validate the processed assets
make logo-validate
```

## Optional features (use when needed)

### A) Git LFS for large PNG drafts

Use Git LFS **only if** you plan to keep many large PNGs in `assets/logo/drafts/**`.

* We scope LFS narrowly in `.gitattributes` to:

  ```
  assets/logo/drafts/**/*.png filter=lfs diff=lfs merge=lfs -text
  ```
* Initialize locally:

  ```bash
  git lfs install
  ```
* **Validator behavior:** LFS enforcement is **OFF by default**.
  Turn **ON** by setting an env var:

  ```bash
  MANTRA_LOGO_ENFORCE_LFS=1 make logo-validate
  ```

### B) Pre-commit hook (local)

If you want local guardrails, install the project's pre-commit hook:

```bash
make install-git-hooks
# Now every commit runs the validator automatically.
# Skip once (not recommended): git commit --no-verify
```

### C) CI checks (pull requests / main)

A lightweight GitHub Actions workflow validates assets on PRs and pushes that touch `assets/logo/**`.
By default it **does not** enforce LFS; you can enable it by setting `MANTRA_LOGO_ENFORCE_LFS: "1"` inside the workflow.

## Validator checks

* **Pairing:** every processed `*.png` must have a matching `*.svg` (same stem).
* **Naming:** `guardian_<tag>_<name>.{png,svg}` (the pipeline renames for you).
* **Sizes:** gentle warnings if PNG > ~5 MB, SVG > ~2 MB.
* **Optional LFS enforcement:** if `MANTRA_LOGO_ENFORCE_LFS=1`, any PNG in `assets/logo/drafts/**` larger than **1 MB** must be LFS-tracked.

## Tips

* Keep the **final logo** as clean **SVG** (for UI + print).
* Use `drafts/` for explorations; migrate chosen results to top-level files as needed.
* See `logo-prompt-guide.md` for **prompting** and **img2img** tips.

## Ethics & Licensing

* Keep mascot art **non-violent** and **culturally respectful**.
* Avoid copying specific franchise IP.
* Confirm contributors have rights to contribute their images under the project's norms.
