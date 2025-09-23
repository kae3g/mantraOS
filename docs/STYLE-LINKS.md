# Markdown Link Style – MantraOS

We keep links **branch-agnostic** so they work in GitHub UI, local previews, and
docs sites.

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

001-sadhana       ✅ 001-sadhana         ❌ (jumps to default branch) 001-sadhana
❌ (goes up too far)

## Automation

- Local: `bash scripts/check-relative-links.sh` CI:
- `.github/workflows/relative-links-check.yml` If you must ignore a file
- temporarily:

export LINK_AUDIT_IGNORE="docs/legacy/.*|README-old.md"

*(Please remove ignores once fixed.)*

> **Update:** Scripture blocks (`> …`) and fenced code are **not** wrapped to 80
columns;
> they are visually meaningful. Prose paragraphs should be wrapped to `≤80`
> using `make wrap-md`.

### Context size in failures
When the audit finds issues, it prints the **tail** of the offending file to
help you fix quickly. You can tune how much context is shown:
```bash
TAIL_LINES=40 bash scripts/check-relative-links.sh
```
Default is 20 lines.

### Auto-fix helper
Use the smart wrapper for common types:
```bash
make wrap-auto     # md/sh/yaml/json
make list-long     # then fix any remaining offenders by hand
make check-80
```

### Line length helpers
- `make list-long` - Print top offenders (files/lines >80) to fix fast Use `vim
- +{line} {file}` to open specific lines for editing
