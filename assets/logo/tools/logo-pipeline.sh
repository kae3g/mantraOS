#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LINEART="$ROOT/guardian-dragon-lineart.svg"
DRAFTS="$ROOT/drafts"
INCOMING="$DRAFTS/incoming"
PROCESSED="$DRAFTS/processed"
ARCHIVE="$DRAFTS/archive"

mkdir -p "$INCOMING" "$PROCESSED" "$ARCHIVE"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }
}

timestamp() { date +"%Y%m%d-%H%M%S"; }

rasterize() {
  local OUT="$DRAFTS/lineart_2048.png"
  echo "→ Rasterizing $LINEART → $OUT"
  if command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w 2048 -h 2048 "$LINEART" -o "$OUT"
  elif command -v inkscape >/dev/null 2>&1; then
    inkscape "$LINEART" --export-type=png --export-filename="$OUT" -w 2048 -h 2048
  else
    echo "Need rsvg-convert or inkscape installed."
    exit 1
  fi
  echo "✓ Wrote $OUT"
}

vectorize_one() {
  local PNG="$1"
  local BASE="$(basename "$PNG")"
  local STEM="${BASE%.*}"
  local TAG="${2:-$(timestamp)}"

  # Normalize name: guardian_<tag>_<stem>.*
  local CLEAN_STEM="guardian_${TAG}_$(echo "$STEM" | tr '[:space:]' '_' | tr -cd '[:alnum:]_-.')"
  local TMPPBM
  TMPPBM="$(mktemp /tmp/guardian.XXXXXX.pbm)"

  echo "→ Vectorizing $BASE"

  # Convert to PBM (threshold) for potrace
  # Feel free to tweak threshold (55%) or add -alpha off if needed
  convert "$PNG" -alpha off -colorspace gray -threshold 55% "$TMPPBM"

  # Trace to SVG
  potrace "$TMPPBM" --svg -o "$PROCESSED/${CLEAN_STEM}.svg"

  # Copy cleaned PNG alongside SVG
  cp "$PNG" "$PROCESSED/${CLEAN_STEM}.png"

  rm -f "$TMPPBM"
  echo "✓ $PROCESSED/${CLEAN_STEM}.svg"
}

vectorize_all() {
  shopt -s nullglob
  local TAG="$(timestamp)"
  local found=0
  for f in "$INCOMING"/*.png "$INCOMING"/*.PNG; do
    found=1
    vectorize_one "$f" "$TAG"
  done
  if [[ "$found" -eq 0 ]]; then
    echo "No PNGs found in $INCOMING. Drop your generated drafts there first."
    exit 0
  fi
  echo "✓ All incoming PNGs processed → $PROCESSED"
}

archive_tag() {
  local TAG="${1:-$(timestamp)}"
  local DEST="$ARCHIVE/$TAG"
  mkdir -p "$DEST"
  shopt -s nullglob
  echo "→ Archiving processed assets to $DEST"
  mv "$PROCESSED"/* "$DEST"/ || true
  echo "✓ Archived."
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  rasterize        Rasterize guardian-dragon-lineart.svg → drafts/lineart_2048.png
  vectorize        Vectorize all PNGs from drafts/incoming → drafts/processed
  archive [tag]    Move processed results to drafts/archive/<tag>
EOF
}

main() {
  case "${1:-}" in
    rasterize) rasterize ;;
    vectorize) need convert; need potrace; vectorize_all ;;
    archive)   archive_tag "${2:-}" ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
