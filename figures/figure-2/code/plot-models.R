library( TumorImmuneModels )

source("../settings.R")

pdf_out( file="models.pdf", width=6, height=2 )
par( mfcol=c(1,3), mar=c(4.2,1,1.5,.2), font.main=1, cex.main=1, oma=c(0,2.5,0,0), family="sans" )
par(cex=1)

pl <- function( f, teff, main, after.first=function(){} ){
	tmax <- 12 * 5.1
	y <- f( tmax, 1, 1 )
	y <- matrix( y, ncol=3, byrow=TRUE )
	y.t <- f( tmax, teff[1], 1 )
	y.t <- matrix( y.t, ncol=3, byrow=TRUE )
	y.t2 <- f( tmax, teff[2], 1 )
	y.t2 <- matrix( y.t2, ncol=3, byrow=TRUE )

	t.vis <- which.max( y[,2] >= 1e8 )-1
	#print ( t.vis )
	y <- y[-(1:t.vis),]
	y.t <- y.t[-(1:t.vis),]
	y.t2 <- y.t2[-(1:t.vis),]

	y <- y[y[,2] <=1e12,] 
	y.t <- y.t[y.t[,2] <=1e12,]
	y.t2 <- y.t2[y.t2[,2] <=1e12,]

	min.t <- min(min(y[,1]),min(y.t[,1]))
	y[,1] <- (y[,1]-min.t) / 30.4
	y.t[,1] <- (y.t[,1]-min.t) / 30.4
	y.t2[,1] <- (y.t2[,1]-min.t) / 30.4

	plot( y.t[,1], y.t[,2]/1e6, log="y", type="l", bty="l",
		xlim=c(0,26),
		col="orange",
		ylab="",
		xlab="", ylim=c(1e8/1e6,1.1e12/1e6),
		yaxt="n",
		#ylab="tumor burden (million cells)",
		main=main )

	abline( h=65*1e8/1e6, col="gray" )
	abline( h=1e12/1e6, col="gray" )

	start.tx <- which.max( y[,2] >= 65*1e8 )
	print( y[start.tx,1] )

	arrows( y[start.tx,1]-3, 1e5, y[start.tx,1]-.1, 65*1e8/1e6*1.2, length=.1 );

	lines( y.t2[,1], y.t2[,2]/1e6, col="red" )
	lines( y[,1], y[,2]/1e6, col="black" )

	after.first()

	#plot( y.t[,1], y.t[,3]/1e6, type='l', col="orange", bty="l", xlim=c(0,26), log="y",
	#	yaxt="n" )
	#lines( y.t2[,1], y.t2[,3]/1e6, col="red" )
	#lines( y[,1], y[,3]/1e6, col="black" )

	#plot( y.t[,1], y.t[,3], log="y", type="l", pch=19, cex=.1, bty="l",
	#	xlab="time (months)", ylab="immune cells", col="red" )
	#lines( y[,1], y[,3], )
}

pl( simulate_M1, c(10,19), "Model M1", function(){
	axis(2)
	mtext( "tumor burden (million cells)", 2, line=2.2 )
	text( 26, 65*1e8/1e6, "treatment", adj=c(1,-.2), xpd=TRUE )
	text( 26, 1e12/1e6, "death", adj=c(1,-.2), xpd=TRUE )
})
pl( simulate_M2, c(14000,14500), "Model M2", function(){
	legend( "bottomright", c("untreated", "weak effect", "strong effect"), 
	lty=1, col=c("black", "orange", "red"), title="", bty="n" )
	mtext( "time (months)", 1, line=2.2 )
})

pl( simulate_M3, c(10,17), "Model M3" )

dev.off()


