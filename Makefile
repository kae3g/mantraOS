# MantraOS Developer Convenience Targets
# --------------------------------------
# These are wrappers around our scripts so contributors can remember fewer
# commands.

.PHONY: help verse-index links-check docs-check ci-all wrap-md check-80
.PHONY: test

help:
	@echo "MantraOS Make targets:"
	@echo "  make verse-index   - Rebuild docs/VERSE-INDEX.md from [#SB-11.*] anchors"
	@echo "  make links-check   - Audit relative links/ribbons in core docs"
	@echo "                      (README, 001-sadhana.md, 030-edu/*)"
	@echo "  make docs-check    - Run all docs checks"
	@echo "                      (links-check + verse-index freshness)"
	@echo "  make ci-all        - Run all repo docs guards locally"
	@echo "                      (links, verse index, wrap checks)"
	@echo ""
	@echo "Tips:"
	@echo "  TAIL_LINES=40 make links-check   # increase failure context in logs"
	@echo ""
	@echo "80-column hard wrap:"
	@echo "  make wrap-md      - Wrap Markdown to 80 (preserve code/table rows)"
	@echo "  make wrap-auto    - Smart auto-fix (md/sh/yaml/json); report others"
	@echo "  make wrap-fix     - Rewrite only violating files to <=80 (aggressive)"
	@echo "  make check-80     - Report lines >80 across all files"
	@echo "  make list-long    - Print top offenders (files/lines >80)"

verse-index:
	bash scripts/build-verse-index.sh

links-check:
	bash scripts/check-relative-links.sh

docs-check: links-check verse-index
	@git diff --quiet -- docs/VERSE-INDEX.md || (echo >&2 "VERSE-INDEX changed; commit it"; exit 1)

ci-all: links-check verse-index
	@echo "All docs checks completed (links + verse index)."

wrap-md:
	APPLY=1 python3 scripts/wrap-markdown.py

wrap-auto:
	APPLY=1 python3 scripts/wrap-anytext.py

wrap-fix:
	APPLY=1 python3 scripts/rewrite-violations.py

check-80:
	bash scripts/enforce-80.sh

list-long:
	bash scripts/list-long-lines.sh

# ---------- Tests ----------

test:
	@echo "[tests] enforcing 80-col on synthetic fixtures..."
	@echo "> blockquote long line *a* *b*" > tests_tmp.md
	@LENGTH_FILES="tests_tmp.md" bash scripts/enforce-80.sh || true
	@sed -E -i '' 's/\* a\* \*b/* a*\n> *b/' tests_tmp.md
	@LENGTH_FILES="tests_tmp.md" bash scripts/enforce-80.sh
	@rm -f tests_tmp.md
	@echo "[tests] relative links scope override works..."
	@echo "## 🔗 Quick Links\n* 📘 [Curriculum Index](030-edu/000-curriculum.md)\n* 🌐 [Visual Tree Diagram](030-edu/CURRICULUM-TREE.md)" > tests_links.md
	@LINKS_FILES="tests_links.md" bash scripts/check-relative-links.sh
	@rm -f tests_links.md
	@echo "✅ tests passed"

# ---------- Logo helpers ----------

LOGO_TOOLS := assets/logo/tools/logo-pipeline.sh

.PHONY: logo-rasterize logo-vectorize logo-archive logo-tree

## Rasterize the SVG line-art into a high-res PNG for img2img workflows
logo-rasterize:
	@bash $(LOGO_TOOLS) rasterize

## Vectorize all PNG drafts in assets/logo/drafts/incoming/ back to SVG and sort them
logo-vectorize:
	@bash $(LOGO_TOOLS) vectorize

## Archive processed results with an optional tag: make logo-archive TAG=v001
logo-archive:
	@bash $(LOGO_TOOLS) archive $(TAG)

## Show the logo asset tree for quick inspection
logo-tree:
	@printf "\nassets/logo/\n"; \
	find assets/logo -maxdepth 3 -print | sed 's|^|  |'

# ------------------------------------------------------------
# (Optional) Shortcuts for common sequences
#   make logo           -> rasterize + show tree
#   make logo-full      -> vectorize + archive (auto-tag) + show tree
# ------------------------------------------------------------

.PHONY: logo logo-full
logo: logo-rasterize logo-tree

logo-full: logo-vectorize
	@bash $(LOGO_TOOLS) archive
	@$(MAKE) logo-tree

# ---------- Logo validation target ----------

.PHONY: logo-validate
logo-validate:
	@python assets/logo/tools/validate.py || (echo "Logo validation failed"; exit 1)

.PHONY: install-git-hooks
install-git-hooks:
	@bash scripts/setup-git-hooks.sh
