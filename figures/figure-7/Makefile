.SECONDARY:
.DELETE_ON_ERROR:

export DRAFT_MODE=1 ## fewer and smaller simulations, remove for same settings as in paper

all : figure.pdf

figure.pdf : figure.tex plots/alluvial.pdf
	latexmk -use-make -xelatex $<

plots/%.pdf : code/plot-%.R data/%.Rdata
	Rscript $<

data/%.Rdata : code/prepare-%.R ../parameters.R
	Rscript $<

