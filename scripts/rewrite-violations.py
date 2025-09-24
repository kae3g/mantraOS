#!/usr/bin/env python3
"""
Rewrite only violating files to ensure max 80 columns.

Rules by type:
- Markdown (.md/.mdx): wrap paragraphs and blockquotes to <=80; skip code fences
and table rows.
- YAML (.yml/.yaml): convert long inline scalars to folded (>-) and wrap.
- JSON (.json): pretty-print indent=2.
- Shell (.sh/.bash): simple safe wrapping with line continuations.
- Other text: indent-preserving whitespace wrapping (conservative).

Use APPLY=1 to write changes. Otherwise dry-run report.
"""
import os, re, sys, json, subprocess
from pathlib import Path
import textwrap

WIDTH = int(os.environ.get("WRAP_COL", "80"))
APPLY = os.environ.get("APPLY", "0") == "1"

MD_EXT = {".md", ".mdx"}
YAML_EXT = {".yml", ".yaml"}
JSON_EXT = {".json"}
SH_EXT = {".sh", ".bash"}

code_fence_re = re.compile(r"^(\s*)```")
table_div_re = re.compile(r"^\s*\|")
heading_re = re.compile(r"^\s{0,3}#{1,6}\s")
hr_re = re.compile(r"^\s*([-_*]\s*){3,}\s*$")
blockquote_re = re.compile(r"^(\s*>\s*)+")
list_re = re.compile(r"^(\s*)([-+*]|\d+\.)\s+")

def is_binary(path: Path) -> bool:
    try:
        with open(path, 'rb') as fh:
            chunk = fh.read(8192)
        return b"\0" in chunk
    except Exception:
        return True

def any_line_exceeds(path: Path, width: int) -> bool:
    try:
        with path.open('r', encoding='utf-8', errors='ignore') as fh:
            for line in fh:
                if len(line.rstrip('\n')) > width:
                    return True
    except Exception:
        return False
    return False

def wrap_text_preserve_indent(line: str, width: int) -> list[str]:
    indent = re.match(r'^\s*', line).group(0)
    body = line[len(indent):].rstrip()
    if not body:
        return [indent.rstrip()]
    wrapper = textwrap.TextWrapper(width=width, replace_whitespace=False,
                                   drop_whitespace=True, break_long_words=False,
                                   break_on_hyphens=False,
                                   initial_indent=indent,
                                   subsequent_indent=indent)
    return wrapper.wrap(body) or [line.rstrip()] 

def wrap_md_lines(lines: list[str]) -> list[str]:
    out = []
    in_code = False
    buf: list[str] = []
    prefix = ""
    def flush():
        nonlocal buf, prefix
        if not buf:
            return
        text = " ".join(s.strip() for s in buf).strip()
        if not text:
            out.append("")
        else:
            wrapper = textwrap.TextWrapper(
                width=WIDTH,
                replace_whitespace=False,
                drop_whitespace=True,
                break_long_words=False,
                break_on_hyphens=False,
                initial_indent=prefix,
                subsequent_indent=prefix,
            )
            out.extend(wrapper.wrap(text) or [prefix.rstrip()])
        buf = []
        prefix = ""
    for line in lines:
        if code_fence_re.match(line):
            flush(); out.append(line.rstrip()); in_code = not in_code; continue
        if in_code:
            out.append(line.rstrip()); continue
        if (
            table_div_re.match(line)
            or heading_re.match(line)
            or hr_re.match(line)
        ):
            flush(); out.append(line.rstrip()); continue
        if not line.strip():
            flush(); out.append(""); continue
        bqm = blockquote_re.match(line)
        if bqm:
            new_prefix = bqm.group(0)
            rest = line[len(new_prefix):]
        else:
            new_prefix = ""
            rest = line
        lm = list_re.match(rest)
        if lm:
            pfx = new_prefix + lm.group(0)
            cont = rest[len(lm.group(0)):]
        else:
            pfx = new_prefix
            cont = rest
        if prefix != pfx:
            flush()
            prefix = pfx
        buf.append(cont.strip())
    flush()
    return out

def fix_markdown_file(path: Path) -> bool:
    raw = path.read_text(encoding='utf-8').splitlines()
    new = wrap_md_lines(raw)
    if new != raw and APPLY:
        path.write_text("\n".join(new) + "\n", encoding='utf-8')
        return True
    return new != raw

def fix_yaml_file(path: Path) -> bool:
    raw = path.read_text(encoding='utf-8').splitlines()
    out, changed = [], False
    for line in raw:
        if len(line) <= WIDTH:
            out.append(line); continue
        m = re.match(r'^(\s*)([^:#\s][^:]*):\s+(.+)$', line)
        if m and not re.match(r'^[\[\{].*', m.group(3)):
            indent, key, val = m.groups()
            out.append(f"{indent}{key}: >-")
            wrapped = textwrap.wrap(val, width=WIDTH - len(indent) - 2,
                                    break_long_words=False,
                                    break_on_hyphens=False)
            for w in wrapped:
                out.append(indent + "  " + w)
            changed = True
        else:
            out.extend(wrap_text_preserve_indent(line, WIDTH))
            changed = True
    if changed and APPLY:
        path.write_text("\n".join(out) + "\n", encoding='utf-8')
    return changed

def fix_json_file(path: Path) -> bool:
    try:
        data = json.loads(path.read_text(encoding='utf-8'))
    except Exception:
        return False
    new = json.dumps(data, indent=2, ensure_ascii=False)
    if APPLY and new != path.read_text(encoding='utf-8'):
        if not new.endswith("\n"):
            new += "\n"
        path.write_text(new, encoding='utf-8')
        return True
    return new != path.read_text(encoding='utf-8')

def fix_shell_file(path: Path) -> bool:
    raw = path.read_text(encoding='utf-8').splitlines()
    out, changed = [], False
    for line in raw:
        if len(line) <= WIDTH:
            out.append(line); continue
        indent = re.match(r'^\s*', line).group(0)
        body = line[len(indent):].rstrip()
        # naive tokenization on separators
        parts = re.split(r'\s+(&&|\|\||\||;|#)\s+', body)
        cur = indent
        for part in parts:
            candidate = (cur + (" " if cur.strip() else "") + part).rstrip()
            if len(candidate) <= WIDTH:
                cur = candidate
            else:
                if cur.strip():
                    out.append(cur + " \\")
                    cur = indent + part
                else:
                    cur = indent + part
        if cur.strip():
            out.append(cur)
        changed = True
    if changed and APPLY:
        path.write_text("\n".join(out) + "\n", encoding='utf-8')
    return changed

def fix_generic_file(path: Path) -> bool:
    raw = path.read_text(encoding='utf-8', errors='ignore').splitlines()
    out, changed = [], False
    for line in raw:
        if len(line) <= WIDTH:
            out.append(line); continue
        out.extend(wrap_text_preserve_indent(line, WIDTH))
        changed = True
    if changed and APPLY:
        path.write_text("\n".join(out) + "\n", encoding='utf-8')
    return changed

def main():
    # Build list of violating files from git ls-files
    root = Path('.')
    files: list[Path] = []
    for f in root.rglob('*'):
        if not f.is_file():
            continue
        if f.parts and f.parts[0] in ('.git', 'node_modules', 'dist', 'build',
        'out'):
            continue
        if is_binary(f):
            continue
        if any_line_exceeds(f, WIDTH):
            files.append(f)

    modified = 0
    for f in files:
        ext = f.suffix.lower()
        changed = False
        try:
            if ext in MD_EXT:
                changed = fix_markdown_file(f)
            elif ext in YAML_EXT:
                changed = fix_yaml_file(f)
            elif ext in JSON_EXT:
                changed = fix_json_file(f)
            elif ext in SH_EXT:
                changed = fix_shell_file(f)
            else:
                changed = fix_generic_file(f)
        except Exception as e:
            print(f"WARN: {f}: {e}", file=sys.stderr)
        if changed:
            modified += 1
            print(f"FIXED: {f}")

    if not APPLY:
        print(f"Dry-run complete. {modified} would be modified.")
    else:
        print(f"Modified files: {modified}")

if __name__ == '__main__':
    main()


