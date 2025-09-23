# 🧪 Continuous Integration – MantraOS Docs

🔙 Return to the Dragon's Front Door: [../README.md](../README.md) 🗺️ Repository
Map (lantern scroll): [../REPOSITORY.md](../REPOSITORY.md)

This document explains the **automated checks** that run on every push and pull
request to ensure our documentation remains consistent, navigable, and
accessible.

We aim for **branch-agnostic links**, **seamless navigation**, and a
**consistent scriptural voice** throughout the repository.

> **Update:** CI now treats **scriptural blockquotes** and **code fences** as
> **exempt** from the 80-column rule, and scopes the **relative links check** to
> `README.md`, `001-sadhana.md`, and `030-edu/*.md`. Reference scrolls (like
> `docs/**`) are informational and not audited for ribbons.

---

## ✅ Workflows

### 1) Relative Links & Navigation Ribbons
- **Workflow:** `.github/workflows/relative-links-check.yml` **Script:**
- `scripts/check-relative-links.sh` **What it enforces:**
  - No absolute Markdown links (no `](/path.md)`) No over-up relative paths
  - (`../../something.md`) Required nav ribbons in curriculum files Required
  - Quick Links in all stage scrolls (Stages 1–10)
- **Scope:** `README.md`, `001-sadhana.md`, and every `030-edu/*.md`.
Reference docs under `docs/**` and `website/**` are excluded.
- **Local run:**
  ```bash
  make links-check
  # or
  bash scripts/check-relative-links.sh
  ```
- **Tip:** Increase failure context in logs
`TAIL_LINES=40 make links-check`

### 2) Uddhava Verse Index (Regenerator)
- **Workflow:** `.github/workflows/verse-index.yml` **Script:**
- `scripts/build-verse-index.sh` **What it does:**
  - Scans all files for `[#SB-11.xx.yy]` anchors Regenerates
  - `docs/VERSE-INDEX.md` automatically Fails if the index is out of date (needs
  - commit)
- **Local run:**
  ```bash
  make verse-index
  # or
  bash scripts/build-verse-index.sh
  ```

### 3) 80-Column Line-Length Enforcer
- **Workflow:** `.github/workflows/line-length.yml` **Scripts:**
- `scripts/wrap-markdown.py`, `scripts/enforce-80.sh`,
- `scripts/list-long-lines.sh` **What it enforces:**
  - **All tracked files** must keep **≤ 80 columns** **For Markdown only:** code
  - fences and table rows are exempt (never auto-wrap those)
  - **Blockquotes/verses must wrap** like other prose
- **Local run:**
  ```bash
  make wrap-auto   # md/sh/yaml/json auto-fix
  make wrap-md     # md-only (if you prefer)
  make check-80
  make list-long
  ```

If after wrap-auto you still see offenders, they are likely:
- JSON files with single ultra-long string literals (unbreakable without
- semantics changes), or source files in languages we don't auto-edit. Edit
- those lines by hand.

---

## 🧷 One-liner to run everything locally

```bash
make ci-all
```

This runs:
- link/ribbon/Quick-Links audit verse index rebuild (and checks if it changed)
- 80-column enforcement

If something fails, the script prints **the tail of the offending file(s)** for
context. You can configure the context length: `TAIL_LINES=40 make links-check`.

---

## 🔧 Configuration

### Environment Variables
- `TAIL_LINES` - Number of context lines to show on failures (default: 20)
- `MAX_COL` - Maximum column width for line-length checks (default: 80)
- `LENGTH_IGNORE` - Regex pattern to ignore files in line-length checks
- `LINK_AUDIT_IGNORE` - Regex pattern to ignore files in link audits

### File Patterns
- **Link checks:** All `.md` files **Verse index:** All files containing
- `[#SB-11.xx.yy]` anchors **Line length:** All tracked text files (excludes
- binaries)

---

## 🚨 Troubleshooting

### Link Check Failures
- Check for absolute links: `](/path.md)` Verify relative paths don't go too far
- up: `../../` Ensure nav ribbons and Quick Links are present

### Verse Index Out of Date
- Run `make verse-index` and commit the changes Check that all verse anchors
- follow `[#SB-11.xx.yy]` format

### Line Length Violations
- Run `make wrap-md` to auto-fix Markdown files For other file types, manually
- wrap long lines Use `LENGTH_IGNORE` to temporarily exclude problematic files

---

## 🙏 Closing Thought

> **Uddhava Gītā (Śrīmad-Bhāgavatam 11.7.41)** *ātmaupamyena bhūteṣu dayāṁ
> kurvanti sūrayaḥ* [#SB-11.7.41] **Translation (ISKCON):** "Saintly persons
> extend mercy to all living beings,
seeing them as equal to themselves."

These automated checks are our way of extending mercy to future readers,
ensuring their journey through our documentation is smooth and accessible.
