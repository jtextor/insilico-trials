library(survminer)

source("../theme.R")
load("data/d3.Rdata")

res <- plot_2arm_nivo( fit, df )

quartz( type="pdf", file="plots/d3.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
par( family="sans" )
survminer:::print.ggsurvplot( res, newpage=FALSE )
dev.off()


