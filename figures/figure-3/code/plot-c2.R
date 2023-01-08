library(survminer)

source("../theme.R")
load("data/c2.Rdata")


res <- plot_2arm_ipi( fit, df )

quartz( type="pdf", file="plots/c2.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
par( family="sans" )
survminer:::print.ggsurvplot( res, newpage=FALSE )
dev.off()


