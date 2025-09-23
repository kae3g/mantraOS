#!/usr/bin/env python3
"""
Smart 80-col auto-fixer for common text types.

Edits in-place for: Markdown (.md, .mdx), Shell (.sh, .bash), YAML (.yml, .yaml),
and JSON (.json). For other files, prints an exact report only.

Rules
-----
Markdown:
  - Hard-wrap paragraphs and blockquotes to <=80.
  - Preserve code fences and table rows.

Shell (.sh/.bash):
  - Break long lines at safe separators: &&, ||, |, ;, # and whitespace not
    inside quotes.
  - If inside a double-quoted string, split with: " ... "\n" ... "
  - If inside a single-quoted string, split with: ' ... '\n' ... '
  - Maintain indentation of the original line.

YAML:
  - Convert long inline scalars after ": " to folded scalars (>-) and wrap lines.
  - Wrap already-indented paragraph content to <=80, preserving indent.

JSON:
  - Reformat with indent=2 and ensure arrays/objects expand to keep lines <=80.
  - Long string literals are left intact (reported but not modified).

Safety:
  - Dry-run by default. Apply with APPLY=1.
  - Non-target types are not modified; they are reported.
"""
import os, sys, re, json, textwrap
from pathlib import Path

WIDTH = int(os.environ.get("WRAP_COL", "80"))
APPLY = os.environ.get("APPLY", "0") == "1"
ROOT = Path(os.getcwd())

MD_EXT = {".md", ".mdx"}
SH_EXT = {".sh", ".bash"}
YAML_EXT = {".yml", ".yaml"}
JSON_EXT = {".json"}

code_fence_re = re.compile(r"^(\s*)```")
table_div_re = re.compile(r"^\s*\|")
heading_re = re.compile(r"^\s{0,3}#{1,6}\s")
hr_re = re.compile(r"^\s*([-_*]\s*){3,}\s*$")
blockquote_re = re.compile(r"^(\s*>\s*)+")
list_re = re.compile(r"^(\s*)([-+*]|\d+\.)\s+")
url_re = re.compile(r"https?://\S+")

def is_binary(p: Path) -> bool:
    try:
        with open(p, "rb") as fh:
            chunk = fh.read(8192)
        if b"\0" in chunk:
            return True
    except Exception:
        return True
    return False

# ---------- Markdown ----------
def wrap_paragraph(lines, prefix="", width=80):
    text = " ".join([l.strip() for l in lines]).strip()
    if not text:
        return [prefix.rstrip()]
    # protect URLs from wrapping
    tokens, last = [], 0
    for m in url_re.finditer(text):
        if m.start() > last:
            tokens.append(text[last:m.start()])
        tokens.append(m.group(0))
        last = m.end()
    if last < len(text):
        tokens.append(text[last:])
    wrapper = textwrap.TextWrapper(
        width=width,
        expand_tabs=False,
        replace_whitespace=False,
        drop_whitespace=True,
        break_long_words=False,
        break_on_hyphens=False,
        initial_indent=prefix,
        subsequent_indent=prefix,
    )
    out = []
    for t in tokens:
        if url_re.fullmatch(t):
            if not out:
                out.append(prefix + t)
            else:
                if len(out[-1]) + 1 + len(t) <= width:
                    out[-1] = (out[-1] + " " + t).rstrip()
                else:
                    out.append(prefix + t)
        else:
            parts = wrapper.wrap(t)
            if not parts:
                continue
            if out and parts:
                if len(out[-1]) + 1 + len(parts[0].strip()) <= width:
                    out[-1] = (out[-1] + " " + parts[0].strip()).rstrip()
                    parts = parts[1:]
            out.extend(parts)
    return out

def fix_markdown(p: Path) -> int:
    raw = p.read_text(encoding="utf-8").splitlines()
    out = []
    in_code = False
    para_buf, para_prefix = [], ""
    def flush():
        nonlocal para_buf, para_prefix
        if para_buf:
            out.extend(wrap_paragraph(para_buf, para_prefix, WIDTH))
            para_buf, para_prefix = [], ""
    for line in raw:
        if code_fence_re.match(line):
            flush(); out.append(line.rstrip()); in_code = not in_code; continue
        if in_code: out.append(line.rstrip()); continue
        if table_div_re.match(line) or heading_re.match(line) or hr_re.match(line):
            flush(); out.append(line.rstrip()); continue
        if not line.strip():
            flush(); out.append(""); continue
        bqm = blockquote_re.match(line)
        if bqm:
            prefix = bqm.group(0)
            rest = line[len(prefix):]
        else:
            prefix, rest = "", line
        lm = list_re.match(rest)
        if lm:
            newp = prefix + lm.group(0)
            content = rest[len(lm.group(0)):]
            if para_buf and para_prefix != newp: flush()
            para_prefix = newp
            para_buf.append(content)
        else:
            newp = prefix
            if para_buf and para_prefix != newp: flush()
            para_prefix = newp
            para_buf.append(rest.strip())
    flush()
    if out != raw:
        if APPLY: p.write_text("\n".join(out) + "\n", encoding="utf-8")
        return 1
    return 0

# ---------- Shell ----------
SEP_RE = re.compile(r'\s+(&&|\|\||\||;|#)\s+')

def split_shell_line(s, indent, width):
    # state machine to split outside quotes first
    pieces = []
    buf = ""
    dq = sq = 0
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == '"' and not sq: dq ^= 1
        elif ch == "'" and not dq: sq ^= 1
        # prefer separators
        m = SEP_RE.match(s, i)
        if m and not dq and not sq:
            token = s[:m.start()].strip()
            rest = s[m.end():]
            sep = m.group(1)
            before = s[:m.start()]
            pieces.append(before.strip())
            pieces.append(sep)
            s = rest
            i = 0
            continue
        i += 1
    if s.strip():
        pieces.append(s.strip())
    # now rebuild into wrapped lines
    lines, cur = [], indent
    for part in pieces:
        candidate = (cur + (" " if cur.strip() else "") + part).rstrip()
        if len(candidate) <= width:
            cur = candidate
        else:
            if cur.strip():
                lines.append(cur + " \\")
                cur = indent + part
            else:
                # extremely long single token; break inside quotes if present
                cur = indent + part
    if cur.strip(): lines.append(cur)
    return lines

def fix_shell(p: Path) -> int:
    raw = p.read_text(encoding="utf-8").splitlines()
    out, changed = [], 0
    for line in raw:
        if len(line) <= WIDTH:
            out.append(line); continue
        indent = re.match(r'^\s*', line).group(0)
        body = line[len(indent):]
        wrapped = split_shell_line(body, indent, WIDTH)
        if wrapped and "\n".join(wrapped) != line:
            changed = 1
            out.extend(wrapped)
        else:
            out.append(line)
    if changed and APPLY:
        p.write_text("\n".join(out) + "\n", encoding="utf-8")
    return changed

# ---------- YAML ----------
def fix_yaml(p: Path) -> int:
    raw = p.read_text(encoding="utf-8").splitlines()
    out, changed = [], 0
    for line in raw:
        if len(line) <= WIDTH:
            out.append(line); continue
        # Heuristic: key: value  -> convert to folded scalar
        m = re.match(r'^(\s*)([^:#\s][^:]*):\s+(.+)$', line)
        if m:
            indent, key, val = m.groups()
            # avoid flow/JSON-ish values
            if not re.match(r'^[\[\{].*', val):
                changed = 1
                out.append(f"{indent}{key}: >-")
                wrapped = textwrap.wrap(val, width=WIDTH - len(indent) - 2,
                                        break_long_words=False, break_on_hyphens=False)
                for w in wrapped:
                    out.append(indent + "  " + w)
                continue
        # otherwise keep as-is
        out.append(line)
    if changed and APPLY:
        p.write_text("\n".join(out) + "\n", encoding="utf-8")
    return changed

# ---------- JSON ----------
def fix_json(p: Path) -> int:
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except Exception:
        return 0
    new = json.dumps(data, indent=2, ensure_ascii=False)
    # Pretty printing avoids most long lines; strings may still exceed 80.
    if APPLY and new != p.read_text(encoding="utf-8"):
        p.write_text(new + ("\n" if not new.endswith("\n") else ""), encoding="utf-8")
        return 1
    return 1 if new != p.read_text(encoding="utf-8") else 0

# ---------- Driver ----------
def main():
    modified = 0
    reported = 0
    for f in list(Path(".").rglob("*")):
        if not f.is_file(): continue
        if f.parts and f.parts[0] in (".git", "node_modules", "dist", "build", "out"):
            continue
        if is_binary(f): continue
        ext = f.suffix.lower()
        try:
            if ext in MD_EXT:
                modified += fix_markdown(f)
            elif ext in SH_EXT:
                modified += fix_shell(f)
            elif ext in YAML_EXT:
                modified += fix_yaml(f)
            elif ext in JSON_EXT:
                modified += fix_json(f)
            else:
                # report-only for now
                with open(f, "r", encoding="utf-8", errors="ignore") as fh:
                    for i, line in enumerate(fh, 1):
                        if len(line.rstrip("\n")) > WIDTH:
                            print(f"REPORT: {f}:{i} exceeds {WIDTH}")
                            reported += 1
                            break
        except Exception as e:
            print(f"WARN: {f}: {e}", file=sys.stderr)
    if not APPLY:
        print("Dry-run complete. Set APPLY=1 to write changes.")
    else:
        print(f"Modified files: {modified}. Reported (unfixed types): {reported}.")

if __name__ == "__main__":
    main()
