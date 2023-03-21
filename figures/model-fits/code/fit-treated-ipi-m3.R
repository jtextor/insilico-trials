
source("../tools.R")
library(IPDfromKM)

dataset <- read.csv2("../data/ipi_placebo_digitized.csv", header=TRUE)
dataset_placebo <- dataset[dataset$drug == 'placebo',][, c('time', 'survival')]
dataset_ipi <- dataset[dataset$drug == 'ipi',][, c('time', 'survival')]

preprocess_placebo <- preprocess(dat = dataset_placebo, trisk = seq(0,24,4), 
                                 nrisk = c(252, 192, 136, 90, 73, 56, 44), 
                                 totalpts = 252, maxy = 1)
ipd_placebo <- getIPD(prep=preprocess_placebo,armID=0,tot.events=219)$IPD

preprocess_ipilimumab <- preprocess(dat = dataset_ipi, trisk = seq(0,24,4), 
                                    nrisk = c(250, 200, 159, 116, 92, 80, 69), 
                                    totalpts = 250, maxy = 1)
ipd_ipi <- getIPD(prep=preprocess_ipilimumab,armID=1,tot.events=193)$IPD

ipd <- rbind( ipd_ipi, ipd_placebo )

p_min <- Inf

dev <- function( x, N=250 ){
	if( x[2] <= 0 || x[3] > 1 || x[3] < 0 || x[4] < 1 ){
		return( Inf )
	}
	the_seed <- .Random.seed
	ipd_fake <- data.frame(
		time=get_s_M3(N,mean=x[1], sd=x[2], lower_growth=x[3]),
		status=1, treat=2
	)
	ipd <- rbind( ipd_placebo, ipd_fake )
	
	km <- survfit( Surv(ipd_fake$time,ipd_fake$status )~1 )
	survest <- stepfun(c(km$time,Inf), c(1, km$surv, 0))

	surv.fake <- survest( dataset_placebo$time[dataset_placebo$time<24] )
	p1 <- (surv.fake- dataset_placebo$survival[dataset_placebo$time<24])^2

	ipd_fake <- data.frame(
		time=get_s_M3(N,
		mean=x[1], sd=x[2], lower_growth=x[3], raise_killing=x[4]),
		status=1, treat=2
	)
	ipd2 <- rbind( ipd_ipi, ipd_fake )

	km <- survfit( Surv(ipd_fake$time,ipd_fake$status )~1 )
	survest <- stepfun(c(km$time,Inf), c(1, km$surv, 0))
	surv.fake <- survest( dataset_ipi$time[dataset_ipi$time<24] )
	p2 <- (surv.fake- dataset_ipi$survival[dataset_ipi$time<24])^2
	p <- mean( c(p1,p2) )
	if( p < p_min ){
		par( mfcol=c(1,2), mar=c(3,3,1,.2), bty="l", font.main=1, cex.main=1 )
		plot( survfit( Surv(ipd$time,ipd$status )~ipd$treat ), col=1:2, xlim=c(0,24), ylim=c(0,1),
			main=signif(p,2) )
		plot( survfit( Surv(ipd2$time,ipd2$status )~ipd2$treat ), col=1:2, xlim=c(0,24), ylim=c(0,1)  )
		p_min <<- p
		x_min <<- x
		attr( x_min, "seed" ) <<- the_seed
		if( Sys.getenv("DRAFT_MODE") != "" ){
			saveRDS( x_min, file="data/M3-ipi-xmin-draft.Rds" )
		} else {
			saveRDS( x_min, file="data/M3-ipi-xmin.Rds" )
		}
	}
	p
}

th_init <- c(-2, 0.8192923, 0.545386, 6)
th_prior <- function() c(runif(1,-6,-1), runif(1,0.5,1.5), runif(1,0.2,1), runif(1,1,15))
th_mut <- c(.1,.1,.05,.2)
p_min <- Inf

set.seed(42)

if( Sys.getenv("DRAFT_MODE") != "" ){
	r <- abc( th_init, th_mut, N=50, dev, th_prior, max_iter=6 )
	saveRDS( r, file="data/M3-ipi-abc-result-draft.Rds" )
	touch("data/M3-ipi-abc-result.Rds") 
} else {
	r <- abc( th_init, th_mut, N=500, dev, th_prior )
	saveRDS( r, file="data/M3-ipi-abc-result.Rds" )
}

