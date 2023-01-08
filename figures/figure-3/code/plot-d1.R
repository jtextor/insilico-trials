library( survminer )

source("../theme.R")
load("data/d1.Rdata")

quartz( type="pdf", file="plots/d1.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
par( family="sans" )
survminer:::print.ggsurvplot( plot_1arm( fit, df ), newpage=FALSE )
dev.off()

