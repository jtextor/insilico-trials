library( TumorImmuneModels )

dev_chemo_1arm <- function( get_s ){ 
	function( x, N=250, plot=FALSE ){
		if( x[2] <= 0 || x[3] > 1 || x[3] < 0 ){
			return( Inf )
		}
		ipd_fake <- data.frame(
			time=get_s(N,mean=x[1], sd=x[2], lower_growth=x[3]),
			status=1, treat=2
		)
		ipd <- rbind( sdata$ipd_pl, ipd_fake )
	
		km <- survfit( Surv(ipd_fake$time,ipd_fake$status )~1 )
		survest <- stepfun(c(km$time,Inf), c(1, km$surv, 0))

		surv.fake <- survest( sdata$data_pl$time[sdata$data_pl$time<24] )
		p <- sum((surv.fake - sdata$data_pl$survival[sdata$data_pl$time<24])^2)

		if( plot || (exists("p_min") && p < p_min) ){
			plot( survfit( Surv(ipd$time,ipd$status )~ipd$treat ), 
				col=1:2, xlim=c(0,24), ylim=c(0,1),
				main=signif(p,2) )
			p_min <<- p
		}
		p
	}
}

get_survival_data <- function( dset = "ca184-024" ){
	require(IPDfromKM)
	if( dset == "ca184-024" ){
		dataset <- read.csv2("../figure_2/data/ipi_placebo_digitized.csv", header=TRUE)
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
		return( list(ipd_pl = ipd_placebo, ipd_tx = ipd_ipi,
			data_pl = dataset_placebo, data_tx = dataset_ipi  ) )
	}
}

plot_posteriors <- function( abc_result, N=1 ){
	th_all <- abc_result$th_all
	best_point <- abc_result$best_point
	n <- ncol(th_all)-1
	mx <- max(th_all[,1])
	for( j in seq(1,n) ){
		cc <- N
		dns <- density( th_all[ th_all[,1]==mx-N+1, j+1 ])
		dns$y <- dns$y / max( dns$y )
		plot( dns, xlim=c(min(th_all[th_all[,1]>=mx-N+1,j+1]),max(th_all[th_all[,1]>=mx-N+1,j+1])),
			ylim=c(0,1.1), main=paste("posterior",j), col=cc, yaxt="n", ylab="",
			bty="n"  )
		abline( v=best_point[j] )
		if( N > 1 ){
			for( i in (mx-N+2):mx ){
				cc <- cc - 1
				dns <- density(  th_all[ th_all[,1]==i, j+1 ] )
				dns$y <- dns$y / max( dns$y )
				lines( dns, col=cc,
					lwd=c(1,2)[1+(cc==1)] )
			}
		}
	}
}

get_s <- function( get_survival ) function( N=100, mean=2, sd=1, sddiag=0.25, sddeath=0.25, raise_killing=1, lower_growth=1,
	treatment_delay=0, treatment_duration=Inf, chemo_duration=Inf ){
	x <- rep(0,N); i <- 0; tr <- 0
	while(  i < N ){
		tr <- tr + 1 
		if( tr > 5*N ){
			return(rep(Inf, N))
		}
		R <- rlnorm(1,meanlog=mean, sdlog=sd)
		diag <- 10^rnorm(1,log10(65*1e8)-2*sddiag,sddiag)
		death <- 10^rnorm(1,log10(1e12)-2*sddeath,sddeath)

		# Untreated patient
		y <- get_survival( R, 1, 1, diag, death )
		if( is.finite(y) ){
			i <- i+1
			if( raise_killing > 1 || lower_growth < 1 ){
				y <- get_survival( R, raise_killing, lower_growth, diag, death, 
					TREATMENT_DELAY=treatment_delay, 
					TREATMENT_DURATION=treatment_duration, CHEMO_DURATION=chemo_duration )
			}
			x[i] <- y
		}
	}
	x
}

##
## @param th_init example value(s) of fitted parameter(s), used to get an idea about typical 
##  error values
## @param th_mut mutation standard deviation(s) per dimension
## @param N population size
## @param dev function computing the distance value
## @param th_prior function that samples individual parameter vectors from the prior
## @param do_kde_estimate logical, whether to find the mode from the distribution using KDE after
##  each run (can also be done afterwards from output)
## @param max_iter cap on the amount of iterations
abc <- function( th_init, th_mut, N, dev, th_prior, th_lower=rep(-Inf,length(th_init)),
	th_upper=rep(Inf,length(th_init)),
	do_kde_estimate=FALSE, 
	target_rejection_rate=0.9, max_iter=Inf ){
	k <- N
	ndim <- length(th_init)
	tol <- 10*mean( replicate(10, dev( th_init ) ) )
	th_all <- matrix( nrow=0, ncol=1+ndim )

	i <- 0;
	fl <- 0; tr <- 1; stuck <- 0

	best_point <- NULL

	tryCatch( 
		while( stuck < 2 && i < max_iter ){
			cat(round(tol,5)," ")
			if( i > 0 ){
				th_previous <- th_current
			}
			th_current <- matrix( nrow=0, ncol=ndim )
			tr <- 0; fl <- 0
			while( nrow( th_current ) < k ){
				tr <- tr+1
				if( i > 0 ){
					th <- th_previous[ sample( 1:k, 1 ), ]
				} else {
					th <- th_prior() # initial prior
				}
				for( j in seq_along(th) ){
					th[j] <- th[j] + rnorm( 1, 0, th_mut[j] )
				}
				if( all(th>=th_lower & th<= th_upper) && (dev(c(th)) < tol) ){
					th_current <- rbind( th_current, th )
					if( nrow(th_current) %% 10 == 0 ){
						cat("*")
					}
				} else {
					fl <- fl+1
				}
			}
			cat(" ",signif(fl/tr,2),"\n")
			th_all <- rbind( th_all, cbind(i,th_current) ) 
			i <- i+1
			if( fl/tr < target_rejection_rate ){
				tol <- tol/2; stuck <- 0
			} else {
				stuck <- stuck + 1
			}
			if( do_kde_estimate ){
				dest <- ks::kde(th_current)
				ii <- which( dest$estimate==max(dest$estimate), arr.ind=TRUE )
				if( ndim > 1 ){
					best_point <- sapply( seq_along(ii), 
						function(x) dest$eval.points[[x]][ii[x]] )
				} else {
					best_point <- dest$eval.points[ii]
				}
				print( best_point )
			}
		}, interrupt = function(e){
		 	return(
				list( th_all = th_all, best_point = best_point )
			)
		}
	)
	return( list( th_all = th_all, best_point = best_point ) ) 
}


get_survival_M1 <- function( R=5, raise_killing=1, lower_growth=1, 
	diagnosis_threshold=65*1e8, death_threshold=1e12, treatment_duration=Inf, chemo_duration=Inf ){
	get_survival_cpp_M1( R, raise_killing, lower_growth, diagnosis_threshold, death_threshold, treatment_duration, chemo_duration )
}

get_survival_M2 <- function( R=0.04995, raise_killing=1, lower_growth=1, 
	diagnosis_threshold=65*1e8, death_threshold=1e12, treatment_duration=Inf, chemo_duration=Inf ){
	get_survival_cpp_M2( R, raise_killing, lower_growth, diagnosis_threshold, death_threshold )
}

get_survival_M3 <- function( R=0.04495, raise_killing=1, lower_growth=1, 
	diagnosis_threshold=65*1e8, death_threshold=1e12, treatment_duration=Inf, chemo_duration=Inf ){
	get_survival_cpp_M3( R, raise_killing, lower_growth, diagnosis_threshold, death_threshold )
}

get_s_M1 <- get_s( get_survival_cpp_M1 )
get_s_M2 <- get_s( get_survival_cpp_M2 )
get_s_M3 <- get_s( get_survival_cpp_M3 )



t_col <- function(color, alpha = .33) {
	## Get RGB values for named color
	rgb.val <- col2rgb(color)

	## Make new color using input color as base and alpha set by transparency
	t.col <- rgb(rgb.val[1], rgb.val[2], rgb.val[3],
             max = 255,
             alpha = alpha*255)
	## Save the color
	t.col
}


truncate_survival <- function(d, time=24){
	d$status[d$time > time] <- 0
	d$time[d$time > time] <- time
	d
}

## Generate survival estimates from a specific model with given parameters, 
## based on N simulations. Evaluate survival estimate at given timepoints.
simulate_survival <- function( model="M1", N=100, timepoints=1:24, model.pars=pars_m1_ipi_baseline ){
	fargs <- model.pars
	fargs[['N']] <- N
	survival_times <- do.call( paste0("get_s_",model), fargs )
	survest <- ecdf( survival_times )
	data.frame( time=timepoints, surv=1-survest(timepoints) )
}


## Make a function that computes differences between real and simulated survival 
## curve. The function will be stateful and trace the minimum in its environment; 
## optionally, it can be plotted.
mk_dev_1arm <- function( ref_data, simulator, plot=FALSE ){
	d_min <- Inf
	x_min <- NULL
	seed_min <- NULL

	function( x ){
		s <- .Random.seed
		sim_data <- simulator( x )
		d <- sqrt( mean((ref_data$surv - sim_data$surv)^2) )
		if( d < d_min ){
			d_min <<- d
			x_min <<- x 
			seed_min <<- s
			if( plot ){
				plot( surv ~ time, ref_data, xlim=c(0,max(time)), 
					ylim=c(0,1), type='b', bty='l', cex=.5, pch=19,
					main=paste(c(signif(d_min,3),signif(x_min,3)),collapse=",") )
				lines( surv ~ time, sim_data, col=2, type='b', cex=.5, pch=19 )
			}
		}
		d
	}
}


## initialize RNG
if(!exists(".Random.seed")) set.seed(NULL)
