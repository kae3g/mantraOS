# Markdown Link Style – MantraOS

We keep links **branch-agnostic** so they work in GitHub UI, local previews, and docs sites.

## ✅ Use relative paths

- From a file inside a subfolder to a file in the **same folder**:
  - `See [Stage 3](003-memory-library.md)`
- From a file inside a subfolder to a file in the **parent folder**:
  - `See [Sadhana](../001-sadhana.md)`
- From the **repo root** down into a subfolder:
  - `See [Stage 2](030-edu/002-kernel-tree.md)`

## ❌ Avoid

- **Leading slash absolute paths**:
  - `](/path/to/file.md)` ← **don't** (use relative paths instead)
- **Over-up relative paths** (two `..` or more) unless absolutely necessary:
  - `](../../something.md)` ← usually wrong from subdirectories

## Quick sanity check

From `030-edu/000-curriculum.md` (one level deep), link to root:

001-sadhana       ✅
001-sadhana         ❌ (jumps to default branch)
001-sadhana    ❌ (goes up too far)

## Automation

- Local: `bash scripts/check-relative-links.sh`
- CI: `.github/workflows/relative-links-check.yml`
- If you must ignore a file temporarily:

export LINK_AUDIT_IGNORE="docs/legacy/.*|README-old.md"

*(Please remove ignores once fixed.)*
