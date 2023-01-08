.SECONDARY:
.DELETE_ON_ERROR:

#export DRAFT_MODE=1

all : figure.pdf

figure.pdf : figure.tex plots/insilico-trials.pdf
	latexmk -use-make -xelatex $<

plots/%.pdf : code/plot-%.R data/%.Rdata
	Rscript $<

data/%.Rdata : code/prepare-%.R ../parameters.R
	Rscript $<
