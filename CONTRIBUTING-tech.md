# Contributing to MantraOS 🐉

Welcome, friend. Thank you for wishing to walk with our **Guardian Dragon**.  
This page explains how to build, test, and extend MantraOS, whether you are a young learner, a new developer, or a seasoned engineer.

---

## 📖 Philosophy of Contribution

- **Ahimsa (Do No Harm):** Code should protect, not exploit.  
- **Sādhanā (Daily Practice):** Write small, consistent commits.  
- **Seva (Service):** Contributions serve the community, not ego.  
- **Satsang (Shared Truth):** Documentation is as valuable as code.  

---

## ⚙️ Development Environment

### Requirements
- **Rust** (latest stable, via [rustup](https://rustup.rs))  
- **Cargo** (bundled with Rust)  
- **Python 3.10+** (for some utilities)  
- **Make** and **Docker** (for educational kit builds)  
- **Pandoc + LaTeX** (optional, if you want to export PDFs outside Docker)  

On Debian/Ubuntu:
```bash
sudo apt-get install build-essential pkg-config libssl-dev make docker.io
```

On macOS:

```bash
brew install rustup-init make docker pandoc
rustup-init
```

---

## 🧪 Building MantraOS

### 1. Clone the Repository

```bash
git clone https://github.com/kae3g/mantraOS
cd mantraOS
```

### 2. Build the Kernel & Guardian Services

```bash
cd software
cargo build --release
```

### 3. Run Tests

```bash
cargo test
```

### 4. Cross-Compile (for embedded boards)

Set your target (e.g., ESP32, RISC-V):

```bash
rustup target add riscv32imac-unknown-none-elf
cargo build --release --target=riscv32imac-unknown-none-elf
```

> 🐉 **Note:** Hardware bring-up instructions live in `/hardware/bringup.md`.

---

## 🖨️ Building the Educational Kit PDFs

The **Workbook**, **Coloring Book**, and **Companion Guide** can all be built into PDFs.

### With Docker (recommended)

```bash
cd 030-edu/print-kit
docker build -t mantraos-pdf .
docker run --rm -v $PWD/../..:/workspace mantraos-pdf
```

### Without Docker (native build)

```bash
cd 030-edu/print-kit
make all
```

Outputs:

* `030-edu/worksheets/booklet.pdf`
* `030-edu/coloring-book/booklet.pdf`
* `030-edu/coloring-book/companion-guide.pdf`

---

## 📂 Repository Structure (for Developers)

```
/philosophy/          ← stories and dharma grounding
/docs/                ← design documents (kernel/runtime, networking, etc.)
/hardware/            ← BOMs, modular diagrams, test plans
/software/            ← Rust code: kernel, Guardian Services
/030-edu/             ← educational kit: worksheets, coloring, print system
README.md             ← main vision & orientation
CONTRIBUTING-tech.md  ← this file
```

---

## 🧠 Coding Style & Practices

* **Rust Clarity:** prefer explicit lifetimes and types.
* **Capability Model:** no ambient authority; every resource via capability.
* **Logs:** human-readable, e.g.,

  ```
  2025-09-23 09:15 Silence Bell: a soft ring reminded you to breathe.
  ```
* **Commits:** short, descriptive titles + reference file/module.
* **Docs:** all public functions documented with `///` comments.

---

## 🌍 Sustainability & Hardware Hacking

* **BOM:** see `/hardware/000-bom.md`.
* **Modules:** RAM, battery, and screen are serviceable.
* **Tests:** drop + IPX4 tests in `/hardware/tests/`.

Encourage **right-to-repair** and **long lifespan design** in all contributions.

---

## 🐛 Issues & Contributions

* Use **GitHub Issues** for bugs, enhancements, and questions.

* Tag with:

  * `philosophy` – if about vision or ethics
  * `design` – if about architecture or specs
  * `hardware` – if about BOM, enclosure, or testing
  * `software` – if about Rust code
  * `edu` – if about the educational kit

* Pull Requests:

  1. Fork the repo.
  2. Create a branch: `git checkout -b feature/guardian-timer`.
  3. Commit changes: `git commit -m "Add mercy mode dimmer"`.
  4. Push branch: `git push origin feature/guardian-timer`.
  5. Open PR with description + references.

---

## 🙏 Blessing for Contributors

> **SB 11.20.32**
> *bhaktyāham ekayā grāhyaḥ śraddhayātmā priyaḥ satām*
>
> "I am attained only by devotion,
> and am dear to those with faith."

May your contributions be acts of devotion.
May your code bring peace, resilience, and clarity.
May you always remember: **you are co-raising the Guardian Dragon.**

---
