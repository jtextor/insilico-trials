
source("../tools.R")

DAYS_IN_MONTH = 30.44

library( survival )

ipd <- lung[,c("time","status")]
ipd$time <- ipd$time / DAYS_IN_MONTH
ipd$treat <- 1

fit <- survfit( Surv(ipd$time, ipd$status)~1 )

dataset <- data.frame( time=summary(fit)$time, prop=summary(fit)$surv )

p_min <- Inf

dev <- function( x, N=228 ){
	if( x[2] <= 0 || x[3] > 1 || x[3] < 0 ){
		return( Inf )
	}
	the_seed <- .Random.seed
	ipd_fake <- data.frame(time=get_s_M2(N, mean=x[1], sd=x[2], lower_growth=x[3]), status=2, treat=2)
	ipd <- rbind( ipd, ipd_fake )
	
	km <- survfit( Surv(ipd_fake$time,ipd_fake$status )~ipd_fake$treat )
	survest <- stepfun(c(km$time,Inf), c(1, km$surv, 0))
	surv.fake <- survest( dataset$time )
	p <- mean((surv.fake-dataset$prop)^2)

	if( p < p_min ){
		plot( survfit( Surv(ipd$time,ipd$status )~ipd$treat ), col=1:2,
			xlim=c(0,24), ylim=c(0,1),
			bty="l", main=signif(p,2) )
		p_min <<- p
		x_min <<- x
		attr( x_min, "seed" ) <<- the_seed
		if( Sys.getenv("DRAFT_MODE") != "" ){
			saveRDS( x_min, file="data/M2-lung-xmin-draft.Rds" )
		} else {
			saveRDS( x_min, file="data/M2-lung-xmin.Rds" )
		}
	}
	p
}

th_init <- c(-4, 1, 0.9)
th_prior <- function() c(runif(1,-6,-2), runif(1,0.5,1.5), runif(1,0.3,1))
th_mut <- c(.1,.1,.05)

set.seed(42)

if( Sys.getenv("DRAFT_MODE") != "" ){
	r <- abc( th_init, th_mut, N=10, dev, th_prior, max_iter=3 )
	saveRDS( r, file="data/M2-lung-abc-result-draft.Rds" )
	touch( "data/M2-lung-abc-result.Rds" )
} else {
	r <- abc( th_init, th_mut, N=500, dev, th_prior )
	saveRDS( r, file="data/M2-lung-abc-result.Rds" )
}

