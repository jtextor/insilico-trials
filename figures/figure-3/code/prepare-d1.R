### Figure 2 panel B1 data ###

library( survival )

source("../tools.R")
source("../parameters.R")

r <- readRDS("../model-fits/data/M3-lung-xmin.Rds")
.Random.seed <- attr(r,"seed")

df <- data.frame( time=get_s_M3(N=228, mean=r[1], sd=r[2], lower_growth=r[3]), status=1 )

df$status[!is.finite(df$time)] <- 0
df$time[!is.finite(df$time)] <- 48 # max(df$time[is.finite(df$time)])

fit<- survfit( Surv(time, status)~1, data = df)

# Save simulated survival data
save(df, fit, file = "data/d1.Rdata")


