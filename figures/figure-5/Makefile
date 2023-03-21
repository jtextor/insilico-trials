all : figure.pdf

export DRAFT_MODE=1  ## fewer and smaller simulations, remove for same settings as in paper

figure.pdf : figure.tex plots/power-analysis.pdf
	latexmk -use-make -xelatex $<

plots/%.pdf : code/plot-%.R data/%.Rdata
	Rscript $<

data/%.Rdata : code/prepare-%.R ../parameters.R
	Rscript $<


