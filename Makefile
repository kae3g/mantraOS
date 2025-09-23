# ---------- MantraOS Root Makefile (logo helpers) ----------

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
