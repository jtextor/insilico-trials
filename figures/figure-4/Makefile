
.SECONDARY:
.DELETE_ON_ERROR:

PLOTS=plots/insilico-trials.pdf plots/insilico-trials-m2.pdf plots/insilico-trials-m3.pdf

figure.pdf : figure.tex $(PLOTS)
	latexmk -use-make -xelatex $<

plots/%.pdf : code/plot-%.R ../parameters.R code/helper-simulated-trial.R
	Rscript $<


