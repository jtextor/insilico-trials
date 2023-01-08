
source("../tools.R")
source("../parameters.R")


## simulate data
mp1 <- pars_m1_ipi_baseline
mp1[["lower_growth"]] <- NULL
surv_m1 <- simulate_survival( model="M1", N=5000, model.pars=mp1, timepoints=1:24 )

set.seed(42)

th_init <- c(pars_m2_ipi_baseline[['mean']], pars_m2_ipi_baseline[['sd']])
th_prior <- function() c(runif(1,-6,-1), runif(1,0,2))
th_mut <- c(.1,.1)
dev <- mk_dev_1arm( ref_data=surv_m1, plot=TRUE,
	simulator=function(x){
		simulate_survival( model="M2", 
		timepoints=surv_m1$time, N=250, model.pars=list(mean=x[1], sd=x[2]) )
	} )

if( Sys.getenv("DRAFT_MODE") != "" ){
	r <- abc( th_init, th_mut, N=10, dev, th_prior, max_iter=3 )
	saveRDS( r, file="data/M2-m1-baseline-abc-result-draft.Rds" )
	R.utils::touchFile("data/M2-m1-baseline-abc-result.Rds") 
} else {
	r <- abc( th_init, th_mut, N=50, dev, th_prior )
	saveRDS( r, file="data/M2-m1-baseline-abc-result.Rds" )
}

