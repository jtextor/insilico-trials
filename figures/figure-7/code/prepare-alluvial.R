library(ldbounds)
source("../tools.R")
source("../parameters.R")

if( Sys.getenv("DRAFT_MODE") != "" ){
	n_trials <- 5
	n_patients <- 100
	strong_effect <- 24
	weak_effect <- 8
} else {
	n_trials <- 1000
	n_patients <- 200
	strong_effect <- 12
	weak_effect <- 4
}

trial_result <- function( times, alpha_bounds, rk_t=25 ){
	d <- rbind(
		data.frame( time=get_s_M1( N=n_patients, mean=baseline_m1[1], sd=baseline_m1[2],
				lower_growth=chemo_effect_m1 ), 
				arm="c" ),
		data.frame( time=get_s_M1( N=n_patients, mean=baseline_m1[1], sd=baseline_m1[2], 
				lower_growth=chemo_effect_m1, raise_killing=rk_t ), arm="t" ) )

	resulting_p <- sapply( times, 
		function(x){
		res <- factor( d$time>=x, levels=c(TRUE,FALSE) )
		#print( res )
		suppressWarnings(chisq.test(table( d$arm, res ))$p.value)
	} )

	if( any( !is.finite( resulting_p ) ) ){
		stop("weird p value!")
	}
	
	if( !any( resulting_p <= alpha_bounds ) ){
		return( c( length(times), 0 ) )
	}

	# Find first significant difference
	first_sig <- which.max( resulting_p <= alpha_bounds )

	# Get sign of effect
	eff <- mean((d$time>=times[first_sig])[d$arm=="t"]) - 
		mean((d$time>=times[first_sig])[d$arm=="c"])
	return( c(first_sig, sign(eff) ) )
}


result_to_stages <- function( trial_data, n_interim_analyses=0 ){
	r <- matrix( 0, ncol=4, nrow=n_interim_analyses+2 )
	for( i in seq(1,ncol(trial_data)) ){
		for( s in seq(0,trial_data[1,i]-1) ){
			r[s+1,1] <- r[s+1,1] + 1
		}
		if( trial_data[2,i] == 0 ){
			r[trial_data[1,i]+1,3] <- r[trial_data[1,i]+1,3]+1
		}
		if( trial_data[2,i] == 1 ){
			r[trial_data[1,i]+1,2] <- r[trial_data[1,i]+1,2]+1
		}
		if( trial_data[2,i] == -1 ){
			r[trial_data[1,i]+1,4] <- r[trial_data[1,i]+1,4]+1
		}
	}
	return( r )
}

get_trial_statistics <- function( n_trials=20, n_interim_analyses=0, rk_t=12 ){
	cat( n_trials, n_interim_analyses, rk_t, "\n" )
	times <- seq( 0,24,length.out=n_interim_analyses + 2 ) # n evenly spaced timepoints
	times <- tail( times, -1 ) # remove time 0 
	bounds <- commonbounds(length(times))$nom.alpha
	rr <- replicate( n_trials, trial_result(times,bounds,rk_t=rk_t))
	result_to_stages( rr, n_interim_analyses=n_interim_analyses )
}


stages_strong_0 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=0, rk_t=strong_effect ) 
stages_strong_1 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=1, rk_t=strong_effect ) 
stages_strong_2 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=2, rk_t=strong_effect ) 
stages_strong_3 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=3, rk_t=strong_effect ) 

stages_weak_0 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=0, rk_t=weak_effect ) 
stages_weak_1 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=1, rk_t=weak_effect ) 
stages_weak_2 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=2, rk_t=weak_effect ) 
stages_weak_3 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=3, rk_t=weak_effect ) 

stages_none_0 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=0, rk_t=0 ) 
stages_none_1 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=1, rk_t=0 ) 
stages_none_2 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=2, rk_t=0 ) 
stages_none_3 <- get_trial_statistics( n_trials=n_trials, n_interim_analyses=3, rk_t=0 ) 

save( stages_strong_0, stages_strong_1,	stages_strong_2, stages_strong_3, 
	stages_weak_0, stages_weak_1,	stages_weak_2, stages_weak_3, 
	stages_none_0, stages_none_1,	stages_none_2, stages_none_3,
	file="data/alluvial.Rdata" )

