PDF_ENGINE?=xelatex

# Paths
LATEX_HEADER=030-edu/print-kit/latex-header.tex

all: demo workbook coloring guide

demo:
	pandoc 030-edu/print-kit/demo-sample.md \
	  --pdf-engine=$(PDF_ENGINE) \
	  --include-in-header=$(LATEX_HEADER) \
	  -o 030-edu/print-kit/demo-sample.pdf

workbook:
	pandoc 030-edu/worksheets/booklet.md \
	  --pdf-engine=$(PDF_ENGINE) \
	  --include-in-header=$(LATEX_HEADER) \
	  -o 030-edu/worksheets/booklet.pdf

coloring:
	pandoc 030-edu/coloring-book/booklet.md \
	  --pdf-engine=$(PDF_ENGINE) \
	  --include-in-header=$(LATEX_HEADER) \
	  -o 030-edu/coloring-book/booklet.pdf

guide:
	pandoc 030-edu/coloring-book/companion-guide.md \
	  --pdf-engine=$(PDF_ENGINE) \
	  --include-in-header=$(LATEX_HEADER) \
	  -o 030-edu/coloring-book/companion-guide.pdf

clean:
	rm -f 030-edu/print-kit/*.pdf 030-edu/worksheets/*.pdf 030-edu/coloring-book/*.pdf
