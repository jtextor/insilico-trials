### Figure 2 panel B1 data ###

library( survival )

source("../tools.R")

r <- readRDS("data/M2-lung-xmin.Rds")
.Random.seed <- attr(r,"seed")

df <- data.frame( time=get_s_M2(N=228, mean=r[1], sd=r[2], lower_growth=r[3]), status=1 )

df$status[!is.finite(df$time)] <- 0
df$time[!is.finite(df$time)] <- max(df$time[is.finite(df$time)])

fit<- survfit( Surv(time, status)~1, data = df)

# Save simulated survival data
save(df, fit, file = "data/c1.Rdata")


