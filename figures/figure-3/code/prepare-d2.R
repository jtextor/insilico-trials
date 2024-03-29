
library( survival )
source("../tools.R")

r <- readRDS("data/M3-ipi-xmin.Rds")
.Random.seed <- attr(r,"seed")

df1 <- data.frame( randomization="b_placebo", time=get_s_M3(N=250,mean=r[1], sd=r[2], lower_growth=r[3], 
	raise_killing=1), status=1 )
df2 <- data.frame( randomization="a_ipi", time=get_s_M3(N=250,mean=r[1], sd=r[2], lower_growth=r[3], 
	raise_killing=r[4]), status=1 )

df <- rbind(df1,df2)
df$status[!is.finite(df$time)] <- 0
df$time[!is.finite(df$time)] <- 5*12

fit <- survfit( Surv(time, status)~randomization, data = df)

save(df, fit, file = "data/d2.Rdata")

