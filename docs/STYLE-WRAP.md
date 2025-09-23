# ✂️ Line-Wrapping Guide (80 Columns)

🔙 Return to the Dragon's Front Door: [../README.md](../README.md)  
🗺️ Repository Map (lantern scroll): [../REPOSITORY.md](../REPOSITORY.md)

Our scrolls prefer **hard wraps at 80 columns** to improve reviewability,
diff clarity, and accessibility in narrow viewports.

---

## ✅ What the wrapper respects

The wrapper keeps these structures intact and unbroken:

- **Code fences** (```), and **indented code blocks**
- **Tables** (lines containing `|`) and table dividers
- **Headings** (`#`), **horizontal rules** (`---`, `***`, etc.)
- **Blockquotes** (`> `) — including nested ones
- **Bulleted/numbered lists** with correct indentation
- **Raw URLs** (will not be split)
- Basic **HTML blocks**

It only reflows **paragraph text**.

---

## 🛠 Commands

Wrap Markdown and text files:

```bash
# Dry-run (shows which files would change)
python3 scripts/wrap-markdown.py

# Apply changes
APPLY=1 python3 scripts/wrap-markdown.py

# With Makefile aliases:
make wrap-md
```

Enforce 80 columns via checker:

```bash
make check-80
# or
bash scripts/enforce-80.sh
```

Increase failure context (lines shown) in logs:

```bash
TAIL_LINES=40 bash scripts/enforce-80.sh
```

---

## 🧪 CI

Workflow: `.github/workflows/line-length.yml`

This runs on pushes/PRs and fails if any tracked text file has lines
**longer than 80 columns**.

---

## ⚠️ Known edge cases

- Very long **unbreakable tokens** (e.g., a single mega-URL) will remain long.
- Complex **custom HTML** sections are left intact.
- If a paragraph is intentionally formatted (poetry/verse), consider placing it
  inside a blockquote or code fence to opt it out of wrapping.

If you hit a tricky case, please open an issue so we can extend the wrapper.
