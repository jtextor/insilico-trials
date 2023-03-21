.SECONDARY:
.DELETE_ON_ERROR:

all : figure.pdf

PLOTS=plots/a1.pdf plots/a2.pdf plots/a3.pdf plots/b1.pdf plots/b2.pdf plots/b3.pdf plots/c1.pdf plots/c2.pdf plots/c3.pdf plots/d1.pdf plots/d2.pdf plots/d3.pdf


figure.pdf : figure.tex $(PLOTS)
	latexmk -use-make -xelatex $<

plots/%.pdf : code/plot-%.R data/%.Rdata
	Rscript $<

data/b1.Rdata : data/M1-lung-xmin.Rds
data/c1.Rdata : data/M2-lung-xmin.Rds
data/d1.Rdata : data/M3-lung-xmin.Rds

data/b2.Rdata : data/M1-ipi-xmin.Rds
data/c2.Rdata : data/M2-ipi-xmin.Rds
data/d2.Rdata : data/M3-ipi-xmin.Rds

data/b3.Rdata : data/M1-nivo-xmin.Rds
data/c3.Rdata : data/M2-nivo-xmin.Rds
data/d3.Rdata : data/M3-nivo-xmin.Rds


data/%.Rdata : code/prepare-%.R
	Rscript $<
