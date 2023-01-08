library( TumorImmuneModels )

source("../tools.R")
source("../parameters.R")

endpoint_times <- seq( 3, 24, 3 )

RR <- 400
if( Sys.getenv("DRAFT_MODE") != "" ){
	RR <- 20
}

do_tests <- function( N_c=20, N_t=20, lg_t=1, lg_c=1, rk_t=1, type="chisq" ){
	require(survival)
	d_control <- truncate_survival( data.frame( time=get_s_M1( N=N_c,
		lower_growth=lg_c, chemo_duration=6,
		mean=baseline_m1[1], sd=baseline_m1[2] ),
		status=1, treatment="C" ) ) 
	d_treatment <- truncate_survival( data.frame( time=get_s_M1( N=N_t, 
		mean=baseline_m1[1], sd=baseline_m1[2], 
		lower_growth=lg_t, raise_killing=rk_t, chemo_duration=6 ), 
		status=1, treatment="T" ) )
	d <- rbind( d_control, d_treatment )
	if( type == "chisq" ){
		sapply( endpoint_times, function(x) {
			suppressWarnings(chisq.test(table( d$treatment, d$time>=x ))$p.value)
		} )
	} else {
		sapply( endpoint_times, function(x) {
			d2 <- d
			pchisq(survdiff( Surv(time,status) ~ treatment, data=truncate_survival(d2,x) )$chisq,1,
				lower.tail=FALSE)
		} )
	}
}

pwr <- function( N_c=10, N_t=10, R=RR, lg_t=1, lg_c=1, rk_t=1, alpha=0.05){
	cat( N_c + N_t, " " )
	res <- replicate( R, do_tests( N_t=N_t, N_c=N_c, lg_t = lg_t, lg_c=lg_c, rk_t=rk_t ) )
	res_mean <- apply( res, 1, function(x) 100*mean(x<alpha) )
	res_cis <- apply( res, 1, function(x) 100*binom.test(sum(x<alpha), R)$conf.int )
	list( res_mean, res_cis )
}


pwr_hr <- function( N_c=10, N_t=10, R=RR, lg_t=1, lg_c=1, rk_t=1, alpha=0.05){
	cat( N_c + N_t, " " )
	res <- replicate( R, do_tests( N_t=N_t, N_c=N_c, lg_t = lg_t, lg_c=lg_c, rk_t=rk_t, type="hr" ) )
	res_mean <- apply( res, 1, function(x) 100*mean(x<alpha) )
	res_cis <- apply( res, 1, function(x) 100*binom.test(sum(x<alpha), R)$conf.int )
	list( res_mean, res_cis )
}




if( T ){
	results_chemo <- lapply( c(50,100,200,400), function(x) pwr_hr(x,x,lg_t=chemo_effect_m1) )
	cat("\n")
	results_immuno <- lapply( c(100,200,400,600), function(x) pwr(x,x,rk_t=immuno_effect_m1,lg_t=chemo_effect_m1,lg_c=chemo_effect_m1) )
	cat("\n")
	results_chemo_rr <- lapply( c(150,200,225,180), function(x) pwr_hr(x,300-x,lg_t=chemo_effect_m1) )
	cat("\n")
	results_immuno_rr <- lapply( c(600,800,900,720), function(x) pwr(x,1200-x,rk_t=immuno_effect_m1,lg_t=chemo_effect_m1,lg_c=chemo_effect_m1) )
	cat("\n")
}

save( endpoint_times, results_chemo, results_immuno, results_chemo_rr, results_immuno_rr, file="data/insilico-trials.Rdata" )


