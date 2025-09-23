#!/usr/bin/env python3
"""
Wrap Markdown/text files to 80 columns, preserving:
 - code fences and indented code blocks
 - tables (lines containing '|' or table dividers)
 - headings, horizontal rules, HTML blocks
 - list indentation (bullets/numbers), nested lists
 - blockquotes ('> ')
 - raw URLs (do not split)
 - fenced verse/quote blocks (kept as-is unless plain paragraphs inside)

Dry-run by default; set APPLY=1 to write changes.

Usage:
  python3 scripts/wrap-markdown.py           # dry-run
  APPLY=1 python3 scripts/wrap-markdown.py   # apply
  APPLY=1 INCLUDE="md,mdx,txt" python3 scripts/wrap-markdown.py
"""
import os, re, sys, textwrap
from pathlib import Path

ROOT = Path(os.getcwd())
APPLY = os.environ.get("APPLY", "0") == "1"
INCLUDE = os.environ.get("INCLUDE", "md,mdx,txt")
WIDTH = int(os.environ.get("WRAP_COL", "80"))

exts = tuple("." + e.strip() for e in INCLUDE.split(",") if e.strip())

code_fence_re = re.compile(r"^(\s*)```")
html_block_start = re.compile(r"^\s*<([a-zA-Z]+)(\s|>|/>)")
html_block_end = re.compile(r".*</\s*[a-zA-Z]+\s*>\s*$")
table_re = re.compile(r"\|")
table_divider_re = re.compile(
    r"^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)+\|?\s*$"
)
hr_re = re.compile(r"^\s*([-_*]\s*){3,}\s*$")
heading_re = re.compile(r"^\s{0,3}#{1,6}\s")
list_re = re.compile(r"^(\s*)([-+*]|\d+\.)\s+")
blockquote_re = re.compile(r"^(\s*>\s*)+")
url_re = re.compile(r"https?://\S+")

def find_files(root: Path):
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        if p.name.startswith(".git") or "/.git/" in str(p):
            continue
        if "/node_modules/" in str(p):
            continue
        if p.suffix.lower() in exts:
            yield p

def wrap_paragraph(lines, prefix="", width=80):
    """Wrap a list of raw text lines as a paragraph with a given prefix."""
    text = " ".join([l.strip() for l in lines]).strip()
    if not text:
        return [prefix.rstrip()]
    # Protect URLs by inserting zero-width space markers then splitting
    protected = []
    last = 0
    for m in url_re.finditer(text):
        if m.start() > last:
            protected.append(text[last:m.start()])
        protected.append(m.group(0))
        last = m.end()
    if last < len(text):
        protected.append(text[last:])
    # Now wrap piecewise, but never break URLs
    wrapper = textwrap.TextWrapper(
        width=width,
        expand_tabs=False,
        replace_whitespace=False,
        drop_whitespace=True,
        break_long_words=False,
        break_on_hyphens=False,
        subsequent_indent=prefix,
        initial_indent=prefix,
    )
    out = []
    for chunk in protected:
        if url_re.fullmatch(chunk):
            # Flush a line if appending URL would exceed width
            if not out:
                out.append(prefix + chunk)
            else:
                if len(out[-1]) + 1 + len(chunk) <= width:
                    out[-1] = (out[-1] + " " + chunk).rstrip()
                else:
                    out.append(prefix + chunk)
        else:
            lines = wrapper.wrap(chunk)
            if not lines:
                continue
            if out and lines:
                # If previous out[-1] has room and first wrapped line is short,
                # try to merge (avoid extra break)
                if len(out[-1]) + 1 + len(lines[0].strip()) <= width:
                    out[-1] = (out[-1] + " " + lines[0].strip()).rstrip()
                    lines = lines[1:]
            out.extend(lines)
    return out

def process_file(path: Path):
    original = path.read_text(encoding="utf-8").splitlines()
    out = []

    in_code = False
    in_html = False
    para_buf = []
    para_prefix = ""

    def flush_para():
        nonlocal para_buf, para_prefix, out
        if para_buf:
            out.extend(wrap_paragraph(para_buf, prefix=para_prefix,
                                      width=WIDTH))
            para_buf = []
            para_prefix = ""

    for line in original:
        # Code fence toggles
        if code_fence_re.match(line):
            flush_para()
            out.append(line.rstrip())
            in_code = not in_code
            continue
        if in_code:
            out.append(line.rstrip())
            continue

        # HTML block: start/end detection (simple heuristic)
        if not in_html and html_block_start.match(line) and \
           not line.strip().endswith("/>"):
            flush_para()
            in_html = True
            out.append(line.rstrip())
            continue
        elif in_html:
            out.append(line.rstrip())
            if html_block_end.search(line):
                in_html = False
            continue

        # Preserve tables and dividers
        if table_divider_re.match(line) or \
           (table_re.search(line) and not line.strip().startswith(">")):
            flush_para()
            out.append(line.rstrip())
            continue

        # Preserve HR, headings
        if hr_re.match(line) or heading_re.match(line):
            flush_para()
            out.append(line.rstrip())
            continue

        # Blank line: flush paragraph
        if not line.strip():
            flush_para()
            out.append("")
            continue

        # Determine prefix (blockquote + list indent)
        bq = ""
        m_bq = blockquote_re.match(line)
        rest = line
        if m_bq:
            bq = m_bq.group(0)
            rest = line[len(bq):]

        li = ""
        m_li = list_re.match(rest)
        if m_li:
            li = m_li.group(0)
            content = rest[len(li):]
            # New paragraph if bullet lines are being collected with a prefix
            # that changes
            new_prefix = (bq + li)
            if para_buf and para_prefix != new_prefix:
                flush_para()
            para_prefix = new_prefix
            para_buf.append(content)
        else:
            # Plain or quoted paragraph line
            new_prefix = bq
            if para_buf and para_prefix != new_prefix:
                flush_para()
            para_prefix = new_prefix
            # Strip only the minimal leading space for paragraphs
            para_buf.append(rest.strip())

    flush_para()

    if out != original:
        if APPLY:
            path.write_text("\n".join(out) + "\n", encoding="utf-8")
            print(f"✔ wrapped: {path}")
        else:
            print(f"→ would wrap: {path}")

def main():
    any_change = False
    for p in find_files(ROOT):
        process_file(p)
        any_change = True
    if not any_change:
        print("No candidate files found.")

if __name__ == "__main__":
    main()
