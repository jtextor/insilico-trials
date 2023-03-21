
library(survminer)

source("../settings.R")
source("../theme.R")
load("data/d2.Rdata")


res <- plot_2arm_ipi( fit, df )

pdf_out( file="plots/d2.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
survminer:::print.ggsurvplot( res, newpage=FALSE )
dev.off()

