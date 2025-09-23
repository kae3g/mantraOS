# Contributing Logo & Mascot Assets

Welcome, Guardian Dragon caretakers 🐉✨

This guide is for technical contributors, designers, and artists working on the **logo/mascot assets** of MantraOS.  
It describes **how to contribute drafts**, **how to validate assets**, and **the style guidelines we follow**.

---

## 🪶 Our Design Spirit

- **Guardian Dragon** is **gentle, protective, and dignified**.  
- Inspired by **East Asian serpentine dragons** with flowing, asymmetric brushstroke motion.  
- **Face shield helmet**, **calm dark eyes**, **whiskers and ear-fins**, **closed mouth**.  
- **Natural armor** (bamboo/hemp plates), **warm brown body**, **furnace-orange glow** beneath scales, **daylight-gold highlights**, protecting a **sapling or book**.  
- Style: **not cartoony**, **not aggressive**, brush-textured yet iconic.  
- See `logo-prompt-guide.md` for detailed prompt references.

---

## 📂 Folder Layout

```
assets/logo/
guardian-dragon-lineart.svg     # Vector skeleton (starting point for img2img)
logo-prompt-guide.md            # Prompting guide for generation workflows
drafts/
incoming/                     # Drop generated PNGs here
processed/                    # Vectorized & renamed outputs (*.png + *.svg)
archive/                      # Optional long-term storage, tagged
tools/
logo-pipeline.sh              # Rasterize & vectorize helper
validate.py                   # Validation script
README.md                       # Developer overview
CONTRIBUTING-assets.md          # This file
```

---

## 🛠️ Contribution Workflow

### 1. Generate Drafts
- Use `guardian-dragon-lineart.svg` as a base (img2img preferred).
- Follow the **prompt guide** in `logo-prompt-guide.md`.
- Export **PNG drafts** at high resolution (1024px+).
- Drop them into:
```
assets/logo/drafts/incoming/
```

### 2. Vectorize & Process
Run the pipeline:
```bash
make logo-vectorize
```

This:

* Vectorizes PNGs → SVG via `potrace`.
* Renames files to `guardian_<tag>_<name>.{png,svg}`.
* Moves them to `drafts/processed/`.

### 3. Validate

Check that all assets are named, paired, and not oversized:

```bash
make logo-validate
```

Warnings will flag large files or nonconforming names.
Errors stop commits/CI if rules are broken.

### 4. Archive (Optional)

If you have a set of results worth keeping together:

```bash
make logo-archive TAG=v001
```

Results move into `drafts/archive/v001/`.

---

## ⚖️ File Size & Git LFS

* For **a few small PNG/SVG files**, no special setup is needed.

* If you expect to keep many **large PNGs (over 1 MB)**, use **Git LFS**:

  ```bash
  git lfs install
  ```

  Files under `assets/logo/drafts/**/*.png` are already scoped in `.gitattributes`.

* **Validator behavior**:

  * By default: no LFS enforcement.
  * Enforce via:

    ```bash
    MANTRA_LOGO_ENFORCE_LFS=1 make logo-validate
    ```

---

## 🔒 Pre-commit Hook (Optional)

To run validation automatically before every commit:

```bash
make install-git-hooks
```

* Runs `validate.py` on staged assets.
* Blocks commit if errors are found.
* Skip once (not recommended): `git commit --no-verify`.

---

## ✅ Checklist for Submitting Assets

Before opening a PR:

* [ ] PNGs in `incoming/` processed → `processed/` via pipeline.
* [ ] Every `*.png` has a matching `*.svg`.
* [ ] Filenames follow `guardian_<tag>_<name>.{png,svg}`.
* [ ] Assets pass `make logo-validate`.
* [ ] Preview PNGs are <5 MB each.
* [ ] SVGs render cleanly at 32px–256px sizes.
* [ ] No copied/trademarked IP in your art.
* [ ] Style matches the **gentle Guardian Dragon vision**.

---

## 🙏 Thank You

Every contribution brings our Guardian Dragon closer to flight.
By keeping assets consistent, we ensure the mascot remains clear, respectful, and reusable across all contexts of MantraOS.
