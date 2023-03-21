library(survminer)

source("../settings.R")
source("../theme.R")
load("data/b3.Rdata")

## Do this to prevent median survival of treatment group, which is outside the plotted region,
## to be shown
df$status[df$time>24] <- 0
df$time[df$time>24] <- 24

res <- plot_2arm_nivo( fit, df )

pdf_out( file="plots/b3.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
print( res, newpage=FALSE )
dev.off()


