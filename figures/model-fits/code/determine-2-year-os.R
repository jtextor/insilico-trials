## Determine the 2-year (untreated) OS implied by a set of baseline model parameters.

source("../tools.R")

parameters <- readRDS("treated-ipi-baseline-M1.rds")$best_point

ci_width <- Inf

N <- 0
x <- 0

N_per_step <- 2000

while( ci_width > 0.05 ){
	x <- x + sum( get_s_M1( mean=parameters[1], sd=parameters[2], N=N_per_step ) >= 24 )
	N <- N + N_per_step
	ci_width <- diff( binom.test( x, N )$conf.int )
	print( ci_width )
}

os <- 100*binom.test( x, N )$estimate

cat("2y-OS without treatment: ", round(os,1), "%\n")

cat("Required immunotherapy effect to raise this to ", round(os+10,1), "%:\n")


dec <- function(target) function( raise_killing ){
	(mean(get_s_M1( mean=parameters[1], sd=parameters[2], raise_killing=raise_killing)>=24)-target)^2
}

r <- abc( 1, 0.1, 100, dev(0.24), function() runif( 1, 1, 10 ) )


## Survival without treatment comes down to 12.3 %

