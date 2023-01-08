
source("../tools.R")
source("../parameters.R")

library( survival )

if( Sys.getenv("DRAFT_MODE") != "" ){
	R <- 10
} else {
	R <- 250
}

do_tests <- function( N=20, lg_t=1, lg_c=1, rk_t=1, model="M1", baseline_pars=baseline_m1 ){
	f <- get(paste0("get_s_",model))
	cat(".")
	d_control <- truncate_survival( data.frame( time=f( N=N,
		lower_growth=lg_c, chemo_duration=6,
		mean=baseline_pars[1], sd=baseline_pars[2] ),
		status=1, treatment="C" ) ) 
	d_treatment <- truncate_survival( data.frame( time=f( N=N, 
		mean=baseline_pars[1], sd=baseline_pars[2], 
		lower_growth=lg_t, raise_killing=rk_t, chemo_duration=6 
		), 
		status=1, treatment="T" ) )
	d <- rbind( d_control, d_treatment )
	c( chisq.test(table( d$treatment, d$time>=24 ))$p.value,
		pchisq(survdiff( Surv(time,status) ~ treatment, data=d )$chisq,1,
		lower.tail=FALSE) )
}

power_estimate_chisq <- function( reps ){
	c( sum(reps[1,] < 0.05), sum(reps[1,] >= 0.05) )
}

power_estimate_lr <- function( reps ){
	c( sum(reps[2,] < 0.05), sum(reps[2,] >= 0.05) )
}

population_sizes <- seq(50,550,by=100) 

y_chemo_placebo_m1 <- rbind( population_sizes, 
	sapply( population_sizes, function(x){
	cat(x,"\t")
	reps <- replicate( R, do_tests( x, lg_t=chemo_effect_m1 ) )
	cat("\n")
	c( power_estimate_chisq( reps ), power_estimate_lr( reps ) )
} ) )

y_chemo_placebo_m2 <- rbind( population_sizes, 
	sapply( population_sizes, function(x){
	cat(x,"\t")
	reps <- replicate( R, do_tests( x, lg_t=chemo_effect_m2, model="M2", baseline_pars=baseline_m2 ) )
	cat("\n")
	c( power_estimate_chisq( reps ), power_estimate_lr( reps ) )
} ) )


population_sizes <- seq(10,110,by=20) 

y_chemo_placebo_m3 <- rbind( population_sizes,
	sapply( population_sizes, function(x){
	cat(x,"\t")
	reps <- replicate( R, do_tests( x, lg_t=chemo_effect_m3, model="M3", baseline_pars=baseline_m3 ) )
	cat("\n")
	c( power_estimate_chisq( reps ), power_estimate_lr( reps ) )
} ) )

population_sizes <- seq(50,300,by=50)

y_immunochemo_chemo_m1 <- rbind( population_sizes,
	sapply( population_sizes, function(x){
	cat(x,"\t")
	reps <- replicate( R, do_tests( x, lg_c=chemo_effect_m1, lg_t=chemo_effect_m1, rk_t=immuno_effect_m1, model="M1", baseline_pars=baseline_m1 ) )
	cat("\n")
	c( power_estimate_chisq( reps ), power_estimate_lr( reps ) )
} ) )

population_sizes <- seq(10,110,by=20) 

y_immunochemo_chemo_m2 <- rbind( population_sizes,
	sapply( population_sizes, function(x){
	cat(x,"\t")
	reps <- replicate( R, do_tests( x, lg_c=chemo_effect_m2, lg_t=chemo_effect_m1, rk_t=immuno_effect_m2, model="M2", baseline_pars=baseline_m2 ) )
	cat("\n")
	c( power_estimate_chisq( reps ), power_estimate_lr( reps ) )
} ) )

y_immunochemo_chemo_m3 <- rbind( population_sizes,
	sapply( population_sizes, function(x){
	cat(x,"\t")
	reps <- replicate( R, do_tests( x, lg_c=chemo_effect_m3,  lg_t=chemo_effect_m1, rk_t=immuno_effect_m3, model="M3", baseline_pars=baseline_m3 ) )
	cat("\n")
	c( power_estimate_chisq( reps ), power_estimate_lr( reps ) )
} ) )


save( y_chemo_placebo_m1, y_chemo_placebo_m2, y_chemo_placebo_m3, 
	y_immunochemo_chemo_m1, y_immunochemo_chemo_m2, y_immunochemo_chemo_m3,
	file="data/power-analysis.Rdata" )
