
plt <- function( model="M1", rk_c = 1, rk_t=1, rk_t_delay = 0, lg_c = 1, lg_t = 1, seed=3, N=600, 
	chemo_duration_c=6,
	chemo_duration_t=6, 
	col_c="gray", col_t="black", main="Chemotherapy vs. placebo", xlab="Time (months)",
	get_s=get_s_M1, baseline_pars=baseline_m1, mfrow=c(1,3), 
	treatment_schedule=NULL ){
	require( survival )
	require( bshazard )

	par( family="sans", mfrow=mfrow, cex=1, bty="n", mar=c(3,4.5,1.2,0.2), mgp=c(1.8,.7,0) )

	set.seed( seed )
	d_control <- truncate_survival( data.frame( time=get_s( 
			mean=baseline_pars[1], sd=baseline_pars[2],
			N=N, raise_killing=rk_c, chemo_duration=chemo_duration_c, lower_growth=lg_c ),
		status=1, treatment="C" ) )

	set.seed( seed )
	d_treatment <- truncate_survival( data.frame( time=get_s( N=N, 
			mean=baseline_pars[1], sd=baseline_pars[2],
			raise_killing=rk_t, treatment_delay=rk_t_delay,
			lower_growth=lg_t, chemo_duration=chemo_duration_t ), 
		status=1, treatment="T" ) )

	d <- rbind( d_control, d_treatment )

	fit <- survfit( Surv( time, status ) ~ treatment, d )

	plot( fit, xaxt="n", yaxt="n", xlab=xlab, ylab="",
		xlim=c(-1.4,24), ylim=c(-.3,1), col=c(col_c,col_t) )
	
	axis( 1, at=seq(0,24,6) )
	axis( 2, las=2, at=seq(0,1,.25) )
	mtext( paste0(main," (",model,")"), 3, line=-1, adj=0.5, outer=TRUE )
	mtext( "   Survival", 2, line=3 )

	text( -.8, -.05, "T", col=col_t )
	text( -.8, -.25, "C", col=col_c )


	if( !is.null(treatment_schedule) ){
		eval( treatment_schedule )
	}

	# Estimate the hazard functio non-parametrically from a survival object
	fit_control <- bshazard(Surv(time, status)~1, data = d_control, nbin = 48, alpha = .05, lambda=500 )
	fit_treatment <- bshazard(Surv(time, status)~1, data = d_treatment, nbin = 48, alpha = .05, lambda=500 )

	with( fit_control, {
		plot( hazard ~ time, type='l', xlab=xlab, col=col_c,
			ylab="Hazard estimate\n ", xlim=c(0,24), 
			ylim=c(0,max(c(fit_control$upper.ci,fit_treatment$upper.ci))), xaxt="n", yaxt="n" );
		polygon( c(time,rev(time)), c(lower.ci,rev(upper.ci)), border=NA, col=t_col(col_c) ) 
	} )
	axis( 1, at=seq(0,24,6) )
	axis( 2, las=2 )
	with( fit_treatment, {
		lines( hazard ~ time, col=col_t )
		polygon( c(time,rev(time)), c(lower.ci,rev(upper.ci)), border=NA, col=t_col(col_t) ) 
	})

	plot( fit_treatment$time, fit_treatment$hazard / fit_control$hazard, type='l',
		xlab=xlab, col="gray", ylab="Hazard ratio", log="y", xaxt="n", yaxt="n", ylim=c(0.2,5), lwd=2 )
	axis( 1, at=seq(0,24,6) )
	axis( 2, las=2 )
	arrows( c(24,24), c(1,1), c(24,24), c(3,1/3), length=.05 )
	text( 24, 3, "C", adj=c(0.5,-.4) )
	text( 24, 1/3, "T", adj=c(0.5,1.4) )

	points( 24, mean(fit_treatment$hazard / fit_control$hazard), col="red", pch=19, xpd=TRUE )

	abline(h=1, lty=2)

}

plt_series <- function( model, baseline_pars, lower_growth, raise_killing ){
	get_s <- get(paste0("get_s_",model))
	plt( lg_t=lower_growth, xlab="", get_s=get_s, baseline_pars=baseline_pars, treatment_schedule = {
		segments( 0, -.05, 6, -.05, lwd=1.5, lend=1 )
		}, model=model )

	#plt( rk_t=raise_killing, get_s=get_s, main="Immunotherapy vs. Placebo", col_t="firebrick", xlab="", 
	#	 baseline_pars=baseline_pars, treatment_schedule = {
	#	segments( 0, -.05, 24, -.05, lwd=1.5, lend=1, col="firebrick" )
	#} )

	plt( rk_t=raise_killing, lg_t=lower_growth, lg_c=lower_growth, get_s=get_s, baseline_pars=baseline_pars, 
		main="Chemoimmunotherapy vs. Chemotherapy", treatment_schedule = {
			segments( 0, -.25, 6, -.25, lwd=2, lend=1 )
			segments( 0, -.05+.02, 6, -.05+.02, lwd=1.5, lend=1, col="black" )
			segments( 0, -.05-.02, 24, -.05-.02, lwd=1.5, lend=1, col="firebrick" )
		}, col_t="darkcyan", col="black", xlab="", model=model )
	
	plt( lg_c=lower_growth, rk_t=raise_killing, main="Immunotherapy vs. Chemotherapy", get_s=get_s, baseline_pars=baseline_pars,
		treatment_schedule = {
			segments( 0, -.25, 6, -.25, lwd=1.5, lend=1 )
			segments( 0, -.05, 24, -.05, lwd=1.5, lend=1, col="firebrick" )
		}, col_t="firebrick", col_c="black", xlab="", model=model )

	plt( rk_t=raise_killing, lg_t=lower_growth, rk_c=raise_killing, rk_t_delay=6, 
		main="Induction chemotherapy, followed by immunotherapy vs. Immunotherapy", 
		get_s=get_s, baseline_pars=baseline_pars, treatment_schedule = {
		segments( 0, -.25, 24, -.25, lwd=1.5, lend=1, col="firebrick" )
		segments( 0, -.05, 6, -.05, lwd=1.5, lend=1, col="black" )
		segments( 6, -.05, 24, -.05, lwd=1.5, lend=1, col="firebrick" )
		}, col_t="darkcyan", col_c="firebrick", model=model )
}
