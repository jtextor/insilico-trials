
### Figure 3 panel B3 data ###

library( survival )
source("../tools.R")

r <- readRDS("../model-fits/data/M1-nivo-xmin.Rds")
.Random.seed <- attr(r,"seed")


df1 <- data.frame( randomization="a_dtic", time=get_s_M1(N=210,mean=r[1], sd=r[2], lower_growth=r[3], 
	raise_killing=1), status=1 )
df2 <- data.frame( randomization="b_nivo", time=get_s_M1(N=210,mean=r[1], sd=r[2], lower_growth=1, 
	raise_killing=r[4]), status=1 )

df <- rbind(df1,df2)
df$status[!is.finite(df$time)] <- 0
df$time[!is.finite(df$time)] <- 5*12

fit <- survfit( Surv(time, status)~randomization, data = df)

save(df, fit, file = "data/b3.Rdata")
