all : figure.pdf

figure.pdf : figure.tex plots/power-analysis.pdf
	latexmk -use-make -xelatex $<

plots/%.pdf : code/plot-%.R data/%.Rdata
	Rscript $<

data/%.Rdata : code/prepare-%.R ../parameters.R
	Rscript $<


