library(survminer)
library(dplyr)

source("../theme.R")

load("data/a3.Rdata")

res <- ggsurvplot(fit = fit, data = df, palette = c("black", "red"), font.family="sans", 
                  conf.int = FALSE, risk.table = TRUE, size = 0.5, 
                  censor.shape = 124, censor.size = 2,  legend = "none", xlim = c(0,24.1), 
                  break.x.by = 4, fontsize = 8/.pt, surv.median.line = "hv") 

res$table <- res$table + 
  theme_survminer(font.tickslab = 8) +
  theme(axis.line = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text.x = element_blank(), 
        plot.title = element_blank(), 
        axis.title.x = element_blank(), 
        axis.text.y = element_text( colour = c("black","red"), family="sans" ),
        axis.title.y = element_blank()) +
  scale_y_discrete(labels = c("DTIC", "Nivo"), limits = rev) +
  coord_cartesian( xlim=c(0,24.1), clip = "off" )


res$plot <- res$plot + 
  scale_x_continuous(name = "Time (months)",  breaks = seq(0, 24, 4)) +
  scale_y_continuous(breaks = seq(0,1,0.2)) + 
  mytheme +
  theme(axis.title.y = element_blank()) +
  coord_cartesian(xlim = c(0, 24))

quartz( type="pdf", file="plots/a3.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
par( family="sans" )
print( res, newpage=FALSE )
dev.off()

