.SECONDARY:
.DELETE_ON_ERROR:

#export DRAFT_MODE=1 ## to set draft mode with fewer and smaller simulations

all : figure.pdf

figure.pdf : figure.tex plots/alluvial.pdf
	latexmk -use-make -xelatex $<

plots/%.pdf : code/plot-%.R data/%.Rdata
	Rscript $<

data/%.Rdata : code/prepare-%.R ../parameters.R
	Rscript $<

