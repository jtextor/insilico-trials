.SECONDARY:
.DELETE_ON_ERROR:

# export DRAFT_MODE=1

all : data/M1-ipi-abc-result.Rds data/M1-nivo-abc-result.Rds data/M1-lung-abc-result.Rds

data/M1-ipi-abc-result.Rds : code/fit-treated-ipi.R
	Rscript $<

data/M1-nivo-abc-result.Rds : code/fit-treated-nivo.R
	Rscript $<

data/M1-lung-abc-result.Rds : code/fit-lung.R
	Rscript $<



