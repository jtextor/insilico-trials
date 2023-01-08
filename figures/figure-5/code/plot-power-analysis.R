load("data/power-analysis.Rdata" )

source("../settings.R")

y_mean <- function(y){
	100*y[1] / sum(y)
}

y_ci <- function(y){
	100*binom.test( y[1], sum(y) )$conf.int
}

plt <- function(x,y,main=""){
	y_0 <- y[1:2,]
	#y_lr <- y[3:4,]

	par( bty="l" )
	plot( x, apply( y_0, 2, y_mean ), type="b", 
		ylim=c(0,100), xlim=c(0,max(x)), pch=19, yaxt="n", 
		xlab="Patients per arm", ylab="", main=main,
		panel.first=abline( h=80, lty=2, col="gray" )
	)
	#lines( x, apply( y_lr, 2, y_mean ), type="b", pch=19 )
	mtext( "Power (%)", 2, line=2.3 )
	axis( 2, las=2 )
	cis <- apply( y_0, 2, y_ci )
	segments( x, cis[1,], x, cis[2,], lend=1 )
	segments( x-max(x)/50, cis[1,], x+max(x)/50, cis[1,] )
	segments( x-max(x)/50, cis[2,], x+max(x)/50, cis[2,] )

	if( nrow(y) > 2 ) {
		for( i in seq(3,nrow(y),2) ){
			y_i <- y[c(i,i+1),]
			coll <- (i+1)/2
			lines( x, apply( y_i, 2, y_mean ), type="b", pch=19, col=coll )
			cis <- apply( y_i, 2, y_ci )
			segments( x, cis[1,], x, cis[2,], lend=1, col=coll )
			segments( x-max(x)/50, cis[1,], x+max(x)/50, cis[1,], col=coll )
			segments( x-max(x)/50, cis[2,], x+max(x)/50, cis[2,], col=coll )
		}
	}

	#cis <- apply( y_lr, 2, y_ci )
	#segments( x, cis[1,], x, cis[2,], lend=1 )
	#segments( x-10, cis[1,], x+10, cis[1,] )
	#segments( x-10, cis[2,], x+10, cis[2,] )

}

pdf_out( file="plots/power-analysis.pdf", width=5.337*0.3937, height=5*0.3937, pointsize=8 )

par( family="sans", bty="n", mar=c(3,3.5,2,0.4), mgp=c(1.8,.7,0), cex.main=1, font.main=1 )

plt( y_chemo_placebo_m1[1,], y_chemo_placebo_m1[-1,] , main="Chemotherapy \n vs. placebo (M1)" )
plt( y_chemo_placebo_m1[1,], y_chemo_placebo_m1[-1,] , main="Chemotherapy \n vs. placebo (M2)" )
plt( y_chemo_placebo_m3[1,], y_chemo_placebo_m3[-1,] , main="Chemotherapy \n vs. placebo (M3)" )
plt( y_immunochemo_chemo_m1[1,], y_immunochemo_chemo_m1[-1,] , main="Chemoimmunotherapy \n vs. chemotherapy (M1)" )
plt( y_immunochemo_chemo_m2[1,], y_immunochemo_chemo_m2[-1,] , main="Chemoimmunotherapy \n vs. chemotherapy (M2)" )
plt( y_immunochemo_chemo_m3[1,], y_immunochemo_chemo_m3[-1,] , main="Chemoimmunotherapy \n vs. chemotherapy (M3)" )

dev.off()


