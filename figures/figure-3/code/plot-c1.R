library( survminer )

source("../settings.R")
source("../theme.R")
load("data/c1.Rdata")

pdf_out( file="plots/c1.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
survminer:::print.ggsurvplot( plot_1arm( fit, df ), newpage=FALSE )
dev.off()

