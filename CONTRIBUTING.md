# Contributing to MantraOS

Welcome, friend 🌱🐉

Thank you for your interest in helping grow the **Guardian Dragon**.  
This project is not only software and hardware — it is also a **practice of mindful design, sustainable craft, and gentle technology**.

This guide is for **technical contributors**: developers, designers, engineers, and artists.  
For the deeper vision and philosophy, see:

- [`sadhana.md`](./sadhana.md) – the project's guiding story and ethos
- [`README.md`](./README.md) – overview, roadmap, and audiences

---

## 🧭 Where to Contribute

### 1. Philosophy & Documentation
- Location: [`/philosophy`](./philosophy/)  
- Shape the stories, metaphors, and glossary entries that help teach MantraOS.  
- Tone: nurturing, accessible, wise.

### 2. Design
- Location: [`/design`](./design/)  
- System design, UI mockups, accessibility studies.  
- Style: calm, mindful, rooted in **human repairability** and **right-to-repair principles**.

### 3. Hardware
- Location: [`/hardware`](./hardware/)  
- Device sketches, modular board layouts, BOMs (bill of materials).  
- Focus: **durability**, **repairability**, **sustainable material choices**.

### 4. Firmware / Kernel
- Location: [`/firmware`](./firmware/)  
- Kernel runtime sketches, Rust code, microkernel modules, secure IPC design.  
- Focus: **minimal, reliable, mindful code**.

### 5. Logo & Mascot Assets
- Location: [`/assets/logo`](./assets/logo/)  
- Where the **Guardian Dragon mascot/logo** lives.  
- Includes:
  - [`logo-prompt-guide.md`](./assets/logo/logo-prompt-guide.md) – prompt tips for generating art  
  - [`CONTRIBUTING-assets.md`](./assets/logo/CONTRIBUTING-assets.md) – detailed contributor checklist  
  - [`tools/`](./assets/logo/tools/) – pipeline + validator

---

## 🛠️ Technical Contribution Workflow

1. **Fork & Branch**  
   Fork the repo and create a branch for your changes:
   ```bash
   git checkout -b feat/my-feature
   ```

2. **Write & Document**

   * Code contributions: Rust preferred.
   * Hardware sketches: Markdown diagrams, SVGs.
   * Assets: see [assets/logo/CONTRIBUTING-assets.md](./assets/logo/CONTRIBUTING-assets.md).

3. **Validate**

   * Run `make lint` or equivalent for code.
   * For logo assets: `make logo-validate`.

4. **Commit Guidelines**

   * Use clear, imperative commit messages:

     ```
     feat: add satsang-graph renderer
     fix: correct e-ink refresh rate logic
     docs: update sadhana glossary with ahimsa entry
     ```
   * Keep commits atomic and scoped.

5. **Pull Requests**

   * Open PRs against `main`.
   * PR template will remind you to run validations.
   * CI will check logo assets automatically.

---

## ⚖️ Licensing & Ethics

* This project uses **The Unlicense** (see [LICENSE](./LICENSE)).
* Contributions must be compatible with **public-domain dedication**.
* Please keep contributions:

  * **Non-violent**
  * **Family-friendly**
  * **Respectful of cultural traditions**

No proprietary IP, no copied franchise art, no license conflicts.

---

## 🫶 Thank You

Every contribution — whether it is a line of code, a hardware diagram, or a brushstroke of the Guardian Dragon — nourishes this vision.

Let us build tools that are **gentle, repairable, and sustainable**.
Together, we can raise the Guardian Dragon with care.
