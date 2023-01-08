library( survminer )

source("../theme.R")
load("data/a1.Rdata")

res <- ggsurvplot(fit, data = df, break.x.by = 4, palette = "black",
                  xlim = c(0, 24.1), font.family="sans", risk.table.fontsize = 8 / .pt,
                  conf.int = FALSE, risk.table = TRUE, size = 0.5,
                  censor.shape = 124, censor.size = 2,
                  legend = "none", 
                  surv.median.line = "hv") 

res$table <- res$table + 
  theme(axis.line = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text.x = element_blank(), 
        plot.title = element_text(size = 8, hjust = -0.2, family="sans"),
	text = element_text(size=8, family="sans"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  scale_y_discrete(labels = c("      ")) +
  ggtitle("No. at risk") +
  coord_cartesian(  xlim=c(0,24), clip = "off" )

res$plot <- res$plot + 
  scale_x_continuous(name = "Time (months)",  breaks = seq(0, 24, 4), labels = seq(0,24, 4)) +
  scale_y_continuous(name = "Proportion Alive", breaks = seq(0,1,0.2)) + 
  mytheme +
  coord_cartesian(xlim = c(0, 24))

quartz( type="pdf", file="plots/a1.pdf", width=5.5*0.3937, height=5*0.3937, pointsize=8 )
par( family="sans" )
survminer:::print.ggsurvplot( res, newpage=FALSE )
dev.off()

