library(ggplot2)
library(grid)

#General plotting theme
mytheme <-  theme_classic() +
  theme(
    line=element_line(size=2),
    axis.line.x=element_line(size=0.3, color = "black"),
    axis.line.y=element_line(size=0.3, color = "black"),
    axis.ticks=element_line(size=0.3, color = "black"),
    
    legend.position = "None", 
    plot.title = element_text(hjust = 0.5, size = 9, face = "bold"), 
    axis.text = element_text(size = 8, color = "black"),
    axis.title = element_text(size = 8),
    axis.text.y = element_text(hjust = 0),
    legend.text = element_text(size = 8), 
    #legend.title = element_text(size = 10),
    legend.title=element_blank(),
    #plot.margin = margin(1,1,1,1, "cm"),
    plot.margin = unit(c(0.3,0.5,0.3,0.3), "lines"),
    text=element_text(size=8, color = "black", family="sans")
  )

quartzFonts(sans = quartzFont(c("Helvetica Light","Helvetica",
        "Helvetica Light Oblique","Helvetica Oblique")))


## function to plot 1 arm survival

plot_1arm <- function( fit, df ){
	df$treat <- 1

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
	  coord_cartesian( xlim=c(0,24), clip = "off" )

	res$plot <- res$plot + 
	  scale_x_continuous(name = "Time (months)",  breaks = seq(0, 24, 4), labels = seq(0,24, 4)) +
	  scale_y_continuous(name = "Proportion Alive", breaks = seq(0,1,0.2)) + 
	  mytheme +
	  coord_cartesian(xlim = c(0, 24))
	res 
}

## CAUTION : the survminer package appears to be buggy, and does
## not consistently orient the labels of the treatment in this plot.
## Therefore, the colors of the lines are swapped. I was unable to 
## determine the reason for this behaviour. The plotted survival curves
## and the risk tables to appear correct, except for the messed up
## ordering.
plot_2arm_ipi <- function( fit, df ){
res <- ggsurvplot(fit, data = df, palette = c("red", "black"),
                  break.x.by = 4, xlim = c(0, 24.1), font.family="sans", risk.table.fontsize = 8 / .pt,
                  conf.int = FALSE, risk.table = TRUE, size = 0.5,
                  censor.shape = 124, censor.size = 2,
                  legend = "none", fontsize = 2.5, 
                  surv.median.line = "hv")

res$table <- res$table + 
  theme_survminer(font.tickslab = 8) +
  theme(axis.line = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text.x = element_blank(), 
        plot.title = element_blank(), 
        axis.title.x = element_blank(), 
        axis.text.y = element_text( colour = c("black","red"), family="sans" ),
        axis.title.y = element_blank()) +
  scale_y_discrete(labels = c("DTIC", "Ipi+DTIC"))+
  coord_cartesian( xlim=c(0,24.1), clip = "off" )

#, limits = rev)

	res$plot <- res$plot + 
	  scale_x_continuous(name = "Time (months)",  breaks = seq(0, 24, 4), labels = seq(0,24, 4)) +
	  scale_y_continuous(name = "Proportion Alive", breaks = seq(0,1,0.2)) + 
	  mytheme +
	  theme(axis.title.y = element_blank()) +
	  coord_cartesian(xlim = c(0, 24))
	res
}

plot_2arm_nivo <- function( fit, df ){
res <- ggsurvplot(fit, data = df, palette = c("black", "red"), 
                  break.x.by = 4, xlim = c(0, 24.1), font.family="sans", risk.table.fontsize = 8 / .pt,
                  conf.int = FALSE, risk.table = TRUE, size = 0.5,
                  censor.shape = 124, censor.size = 2,
                  legend = "none", fontsize = 2.5, 
                  surv.median.line = "hv")

res$table <- res$table + 
  theme_survminer(font.tickslab = 8) +
  theme(axis.line = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text.x = element_blank(), 
        plot.title = element_blank(), 
        axis.title.x = element_blank(), 
        axis.text.y = element_text( colour = c("black","red"), family="sans" ),
        axis.title.y = element_blank()) +
  scale_y_discrete(labels = c("DTIC", "Nivo"), limits = rev)+
  coord_cartesian( xlim=c(0,24.1), clip = "off" )

res$plot <- res$plot + 
  scale_x_continuous(name = "Time (months)",  breaks = seq(0, 24, 4), labels = seq(0,24,4)) +
  scale_y_continuous(name = "Proportion Alive", breaks = seq(0,1,0.2)) + 
  mytheme +
  theme(axis.title.y = element_blank()) +
  coord_cartesian(xlim = c(0, 24))
	res
}
