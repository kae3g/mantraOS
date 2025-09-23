#!/usr/bin/env python3
"""
Guardian Dragon Logo Asset Validator

Checks:
- Every PNG in assets/logo/drafts/processed/ has a matching SVG (same stem).
- Filenames follow guardian_<tag>_<stem>.{png,svg}.
- Size warnings for unusually large assets.
- OPTIONAL: Enforce Git LFS tracking for large PNGs under assets/logo/drafts/**
  if env MANTRA_LOGO_ENFORCE_LFS=1 is set.

Run locally:
  python assets/logo/tools/validate.py

Or via Makefile:
  make logo-validate
  MANTRA_LOGO_ENFORCE_LFS=1 make logo-validate
"""

import os
import re
import sys
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]  # repository root
LOGO_DIR = REPO_ROOT / "assets" / "logo"
PROCESSED = LOGO_DIR / "drafts" / "processed"
DRAFTS_DIR = LOGO_DIR / "drafts"

# Size guidance (soft caps)
PNG_MAX_MB = 5
SVG_MAX_MB = 2

# If LFS enforcing is enabled, any PNG in drafts/** above this must be LFS-tracked
PNG_LFS_ENFORCE_MB = 1

# Naming rule
NAME_RE = re.compile(r"^guardian_[A-Za-z0-9_-]+_[A-Za-z0-9_.-]+\.(png|svg)$")

ENFORCE_LFS = os.environ.get("MANTRA_LOGO_ENFORCE_LFS", "0") == "1"


def fail(msg: str):
    print(f"::error::{msg}")
    sys.exit(1)


def warn(msg: str):
    print(f"::warning::{msg}")


def size_mb(p: Path) -> float:
    try:
        return p.stat().st_size / (1024 * 1024)
    except FileNotFoundError:
        return 0.0


def git_check_attr(attr: str, file_path: Path) -> str:
    """
    Returns the value for a given git attribute on a path, or empty string if unknown.
    Example output:
      assets/logo/drafts/processed/guardian_x.png: filter: lfs
    """
    try:
        out = subprocess.check_output(
            ["git", "check-attr", attr, "--", str(file_path)],
            cwd=str(REPO_ROOT),
            text=True,
        ).strip()
    except Exception:
        return ""
    parts = out.split(":")
    if len(parts) >= 3:
        return parts[-1].strip()
    return ""


def is_lfs_tracked(p: Path) -> bool:
    """
    A file is considered LFS-tracked if any of these resolve to 'lfs':
      - filter=lfs OR diff=lfs OR merge=lfs
    """
    for attr in ("filter", "diff", "merge"):
        val = git_check_attr(attr, p)
        if val.lower() == "lfs":
            return True
    return False


def check_processed_pairs_and_sizes():
    if not PROCESSED.exists():
        print("No processed dir found; skipping processed checks (nothing to validate).")
        return

    pngs = sorted(PROCESSED.glob("*.png"))
    svgs = sorted(PROCESSED.glob("*.svg"))
    svg_stems = {p.stem for p in svgs}

    if not pngs and not svgs:
        print("No processed assets found; nothing to validate.")
        return

    # Naming & pairing checks
    for p in pngs + svgs:
        if not NAME_RE.match(p.name):
            warn(
                f"Nonconforming filename: {p.relative_to(LOGO_DIR)} "
                f"(expected guardian_<tag>_<name>.ext)"
            )

    missing = [p.stem for p in pngs if p.stem not in svg_stems]
    if missing:
        preview = ", ".join(missing[:10])
        fail(f"Missing SVG for PNG(s): {preview} ... (and possibly more)")

    # Size guidance (soft warnings)
    for p in pngs:
        mb = size_mb(p)
        if mb > PNG_MAX_MB:
            warn(
                f"PNG too large ({mb:.2f} MB): {p.name} "
                f"(soft threshold {PNG_MAX_MB} MB)"
            )
    for p in svgs:
        mb = size_mb(p)
        if mb > SVG_MAX_MB:
            warn(
                f"SVG unusually large ({mb:.2f} MB): {p.name} "
                f"(soft threshold {SVG_MAX_MB} MB)"
            )


def check_lfs_coverage_for_drafts():
    """
    Optionally enforce that PNGs under assets/logo/drafts/** above a small size
    threshold are tracked by Git LFS. OFF by default; enable with:
      MANTRA_LOGO_ENFORCE_LFS=1 make logo-validate
    """
    if not ENFORCE_LFS:
        print("LFS enforcement is OFF (set MANTRA_LOGO_ENFORCE_LFS=1 to enable).")
        return

    if not DRAFTS_DIR.exists():
        print("No drafts dir found; skipping LFS checks.")
        return

    pngs = list(DRAFTS_DIR.rglob("*.png")) + list(DRAFTS_DIR.rglob("*.PNG"))
    if not pngs:
        print("No draft PNGs found; skipping LFS checks.")
        return

    violations = []
    for p in pngs:
        mb = size_mb(p)
        if mb <= PNG_LFS_ENFORCE_MB:
            continue
        if not is_lfs_tracked(p):
            violations.append((p, mb))

    if violations:
        print("::group::LFS coverage issues")
        for p, mb in violations:
            print(
                f"::error::PNG not tracked by Git LFS ({mb:.2f} MB): "
                f"{p.relative_to(REPO_ROOT)}"
            )
        print("::endgroup::")
        fail(
            "Some large PNGs under assets/logo/drafts/** are not tracked by Git LFS. "
            "Enable LFS for these files or disable enforcement for this run."
        )
    else:
        print("Draft PNGs over size threshold are correctly LFS-tracked ✅")


def main():
    check_processed_pairs_and_sizes()
    check_lfs_coverage_for_drafts()
    print("Logo asset validation passed ✅")


if __name__ == "__main__":
    main()
