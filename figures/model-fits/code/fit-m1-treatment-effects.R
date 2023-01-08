
source("../tools.R")
source("../parameters.R")

## simulate data

surv_m1 <- data.frame( time=24, surv=.25 )

set.seed(42)

th_init <- 12 # c(pars_m1_ipi_baseline[['raise_killing']] )
th_prior <- function() c(runif(1,1,25))
th_mut <- .5
th_lower <- 1
th_upper <- Inf

dev <- mk_dev_1arm( ref_data=surv_m1, plot=FALSE,
	simulator=function(x){
		simulate_survival( model="M1", 
		timepoints=surv_m1$time, N=250, 
			model.pars=list(mean=pars_m1_ipi_baseline[['mean']],
				sd=pars_m1_ipi_baseline[['sd']],
				lower_growth=1,
				raise_killing=x[1]) )
	} )

max_iter <- Inf
N <- 500
fout <- "data/M2-m1-baseline-abc-result.Rds"
if( Sys.getenv("DRAFT_MODE") != "" ){
	max_iter <- 3
	N <- 10
	R.util::touchFile( fout )
	fout <- gsub( ".Rds", "", fout )
	fout <- paste0( fout, "-draft.Rds ")
}

r <- abc( th_init, th_mut, N=N, dev, th_prior, th_lower, th_upper, max_iter=max_iter )
saveRDS( r, file=fout )


