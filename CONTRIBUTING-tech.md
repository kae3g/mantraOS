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