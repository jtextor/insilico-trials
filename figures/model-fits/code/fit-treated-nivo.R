source("../tools.R")
library(IPDfromKM)


dataset <- read.csv2("../data/nivo_dacarb_digitized.csv", header=TRUE)
dataset_placebo <- dataset[dataset$drug == 'dacarbazine',][, c('time', 'survival')]
dataset_ipi <- dataset[dataset$drug == 'nivolumab',][, c('time', 'survival')]

preprocess_placebo <- preprocess(dat = dataset_placebo, trisk = seq(0,24,3), 
				nrisk = c(208, 179, 146, 122, 92, 76, 71, 62, 51),
                         	totalpts = 208, maxy = 1)
ipd_placebo <- getIPD(prep=preprocess_placebo,armID=0,tot.events=208)$IPD

preprocess_ipilimumab <- preprocess(dat = dataset_ipi, trisk = seq(0,24,3), 
				nrisk = c(210, 186, 171, 154, 143, 135, 128, 122, 116),
                           	totalpts = 210, maxy = 1)

ipd_ipi <- getIPD(prep=preprocess_ipilimumab,armID=1,tot.events=210)$IPD

ipd <- rbind( ipd_ipi, ipd_placebo )


dev <- function( x, N=210 ){
	if( x[2] <= 0 || x[3] > 1 || x[3] < 0 || x[4] < 1 ){
		return( Inf )
	}
	the_seed <- .Random.seed
	ipd_fake <- data.frame(
		time=get_s_M1( N, mean=x[1], sd=x[2], lower_growth=x[3] ), 
		status=1, treat=2
	)
	ipd <- rbind( ipd_placebo, ipd_fake )
	
	km <- survfit( Surv(ipd_fake$time,ipd_fake$status )~1 )
	survest <- stepfun(c(km$time,Inf), c(1, km$surv, 0))

	surv.fake <- survest( dataset_placebo$time[dataset_placebo$time<24] )
	p1 <- ((surv.fake- dataset_placebo$survival[dataset_placebo$time<24])^2)

	ipd_fake <- data.frame(
		time=get_s_M1(N,
		mean=x[1], sd=x[2], raise_killing=x[4]),
		status=1, treat=2
	)
	ipd2 <- rbind( ipd_ipi, ipd_fake )


	km <- survfit( Surv(ipd_fake$time,ipd_fake$status )~1 )
	survest <- stepfun(c(km$time,Inf), c(1, km$surv, 0))
	surv.fake <- survest( dataset_ipi$time[dataset_ipi$time<24] )
	p2 <- ((surv.fake - dataset_ipi$survival[dataset_ipi$time<24])^2)

	p <- mean(c(p1,p2))
	if( p < p_min ){
		par( mfcol=c(1,2), mar=c(3,3,1,.2), bty="l" )
		plot( survfit( Surv(ipd$time,ipd$status )~ipd$treat ), col=1:2, xlim=c(0,24), ylim=c(0,1),
			main=signif(p,2) )
		plot( survfit( Surv(ipd2$time,ipd2$status )~ipd2$treat ), col=1:2, xlim=c(0,24), ylim=c(0,1)  )
		p_min <<- p
		x_min <<- x
		attr( x_min, "seed" ) <<- the_seed
		if( Sys.getenv("DRAFT_MODE") != "" ){
			saveRDS( x_min, file="data/M1-nivo-xmin-draft.Rds" )
		} else {
			saveRDS( x_min, file="data/M1-nivo-xmin.Rds" )
		}
	}
	p
}

th_init <- c(2, 1, 0.95, 1)
th_prior <- function() c(runif(1,1.5,3.5), runif(1,0.5,1.5), runif(1,0.2,1), runif(1,1,25))
th_mut <- c(.1,.1,.05,.5)
N <- 20
p_min <- Inf

set.seed(42)

if( Sys.getenv("DRAFT_MODE") != "" ){
	r <- abc( th_init, th_mut, N=10, dev, th_prior, max_iter=3 )
	saveRDS( r, file="data/M1-nivo-abc-result-draft.Rds" )
	touch("data/M1-nivo-abc-result.Rds") 
} else {
	r <- abc( th_init, th_mut, N=500, dev, th_prior )
	saveRDS( r, file="data/M1-nivo-abc-result.Rds" )
}



