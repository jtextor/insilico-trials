

load( "data/insilico-trials.Rdata" )
source("../settings.R")

plt <- function(results, xlab="Trial duration (months)", ylab="Power (%)" ){

	M <- sapply( results, `[[`, 1 )
	matplot( endpoint_times, M, type='l', col=1:4, lty=1, bty="l", ylim=c(0,100),
		xlab=xlab, xaxt="n", ylab="", yaxt="n" )
	axis( 1, at=endpoint_times )
	axis( 2, las=2 )
	mtext( ylab, 2, line=2.3 )

	for( i in seq_along(results) ){
		cis <- results[[i]][[2]]
		segments( endpoint_times, cis[1,], endpoint_times, cis[2,], lend=1, col=i )
		segments( endpoint_times-.2, cis[1,], endpoint_times+.2, cis[1,], col=i )
		segments( endpoint_times-.2, cis[2,], endpoint_times+.2, cis[2,], col=i )	
	}
}



endpoint_times <- seq( 3, 24, 3 )


pdf_out( file="plots/insilico-trials.pdf", width=7.5*0.3937, height=4*0.3937, pointsize=8 )

par( mar=c(3,3.5,1,4.5), mgp=c(1.8,.7,0), family="sans" )

plt( results_chemo, xlab="" )
legend( x=24, y=80, lty=1, col=rev(1:4), title="Study size", as.character( rev(c(100,200,400,800)) ), bty="n", xpd=TRUE,
	 )

plt( results_chemo_rr, xlab="", ylab="" )
legend( x=22.5, y=80, lty=1, col=c(1,4,2,3), title="Randomization\nratio", c("1:1","3:2","2:1","3:1"), bty="n", xpd=TRUE)

plt( results_immuno )
legend( x=24, y=80, lty=1, col=rev(1:4), title="Study size", as.character( rev(c(200,400,800,1200)) ), bty="n", xpd=TRUE,
	 )

plt( results_immuno_rr, ylab="" )
legend( x=22.5, y=80, lty=1, col=c(1,4,2,3), title="Randomization\nratio", c("1:1","3:2","2:1","3:1"), bty="n", xpd=TRUE)

dev.off()

