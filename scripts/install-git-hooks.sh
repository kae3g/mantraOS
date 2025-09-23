#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
HOOKS_DIR="$ROOT/.git/hooks"

mkdir -p "$HOOKS_DIR"

cat > "$HOOKS_DIR/pre-commit" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
# Run the Markdown link audit before committing.
if [ -x "scripts/check-relative-links.sh" ]; then
  bash scripts/check-relative-links.sh
else
  echo "Warning: scripts/check-relative-links.sh not found or not executable."
fi
EOF

chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Installed pre-commit hook to run link audit before each commit."
