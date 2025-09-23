# 🛠️ Contributing to MantraOS (Technical Guide)

🔙 Return to the Dragon's Front Door: [README.md](README.md)  
🔗 For non-technical companions: see [CONTRIBUTING.md](CONTRIBUTING.md)


This document is for **technical contributors**: developers, designers, hardware engineers, and asset creators.  
For a general community welcome, see [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## 📂 Areas of Contribution

1. **Philosophy / Docs** → [philosophy](philosophy), [001-sadhana.md](001-sadhana.md)  
   Shape metaphors, glossary entries, and stories.

2. **Design** → [design](design)  
   System design, UI, accessibility studies.

3. **Hardware** → [hardware](hardware)  
   Board layouts, BOMs, sustainable materials.

4. **Firmware / Kernel** → [firmware](firmware)  
   Rust microkernel code, IPC, runtime sketches.

5. **Logo & Mascot Assets** → [assets/logo](assets/logo)  
   Mascot prompts, vectorizations, and validator tools.  
   See section below.

---

## 🖼️ Asset Contributions (Mascot/Logo)

Detailed in [assets/logo/CONTRIBUTING-assets.md](assets/logo/CONTRIBUTING-assets.md).

Quick summary:

- Drop PNG drafts into `assets/logo/drafts/incoming/`.  
- Run `make logo-vectorize` → produces paired `.png + .svg` in `processed/`.  
- Run `make logo-validate` → checks naming, pairs, sizes.  
- Archive optional sets via `make logo-archive TAG=v001`.  
- Style: Guardian Dragon, calm, protective, asymmetrical, natural armor.

---

## 🧪 Docs QA: Link Audit, Nav Ribbons, and Quick Links

We enforce a gentle-but-strict docs discipline so learners never get lost:

**What's checked automatically**
- **No absolute Markdown links** (no `](/path.md)`), so links are branch-agnostic.
- **No over-up `../../` paths** (keeps structure simple and portable).
- **Nav Ribbon required** at the top of:
  - `001-sadhana.md`
  - all curriculum files in `030-edu/`
  (must contain "Return to the Dragon's Front Door", "Repository Map (lantern scroll)", and "Curriculum Index")
- **Quick Links footer required** for *all* stage scrolls (Stages 1–10):
  - must contain "Curriculum Index", "Visual Tree Diagram", and "Return to README".

**Run locally**
```bash
bash scripts/check-relative-links.sh
```
If everything is fine, you'll see:
```
✅ Link audit clean. All Markdown links are branch-agnostic.
```
On failures, the script prints the offending lines and the **tail of the file** for context.  
You can adjust the context length:
```bash
TAIL_LINES=40 bash scripts/check-relative-links.sh
```

**Pre-commit hook (recommended)**
```bash
bash scripts/install-git-hooks.sh
```
This installs a `pre-commit` hook that runs the audit automatically before each commit.

**CI checks**
- GitHub Actions runs the same audit on pushes/PRs:
  - `.github/workflows/relative-links-check.yml`
- If you add deeper subdirectories or special cases, update:
  - `scripts/check-relative-links.sh`
  - (Optional) set `LINK_AUDIT_IGNORE` for temporary exceptions.

**Style guidance**
- See `docs/STYLE-LINKS.md` for examples of correct relative links from various folders.
- From `030-edu/` to repo root, prefer `../README.md` style.
- Avoid leading slashes and multiple `..` hops unless absolutely necessary.

**Optional one-off cleanup**
```bash
# If any legacy docs still mention "Bhagavad Gita", normalize them to
# "Śrīmad-Bhāgavatam (Uddhava Gītā, Canto 11)" across text-like files:
make purge-bhagavad
```
This is a convenience wrapper around `scripts/purge-bhagavad-gita.sh`.  
It is **not** part of CI and is intended for occasional maintenance only.  
Once the cleanup has been applied and committed, please **delete the script**
(`scripts/purge-bhagavad-gita.sh`) and remove its Makefile target.

> Our goal is kindness for future readers: consistent navigation, no dead ends, and links that work everywhere.

---

## ✂️ 80-Column Line Wrapping (Markdown)

We keep Markdown/text at **≤ 80 columns** for clean diffs and readability.

**Wrap locally**
```bash
# Dry-run
python3 scripts/wrap-markdown.py
# Apply
APPLY=1 python3 scripts/wrap-markdown.py

# With Make
make wrap-md
```

**Enforce locally**
```bash
make check-80
# or
MAX_COL=80 bash scripts/enforce-80.sh
```

**CI**
- Workflow: `.github/workflows/line-length.yml`
- The checker prints the tail of offending files for context.
- Increase context:
  `TAIL_LINES=40 make check-80`

See `docs/STYLE-WRAP.md` for details and edge cases.

---

## 🛠️ Technical Workflow

1. **Fork & Branch**
   ```bash
   git checkout -b feat/my-feature
   ```

2. **Develop & Document**

   * Rust for firmware.
   * Markdown for diagrams/specs.
   * SVG for final assets.

3. **Validate**

   ```bash
   make lint          # code (if available)
   make logo-validate # assets
   ```

4. **Commit Style**

   ```
   feat: add satsang-graph renderer
   fix: correct e-ink refresh
   docs: update sadhana glossary
   ```

5. **Pull Requests**

   * Open PR against `main`.
   * Use the [PR template](.github/pull_request_template.md).
   * CI validates logo assets automatically.

---

## ⚖️ Ethics & Licensing

* **The Unlicense** → public domain dedication.
* No proprietary or franchise IP.
* Contributions must be respectful, non-violent, inclusive.

---

## 🙏 Closing Thought

Technical work here is **service** (*seva*).
Just as roots nourish the tree unseen, your careful commits nourish the Guardian Dragon unseen.
Thank you for your service 🌱🐉.