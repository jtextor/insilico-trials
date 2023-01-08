library(survival)

DAYS_IN_MONTH <- 30.44

df <- lung[,c("time","status")]
df$time <- df$time / DAYS_IN_MONTH
df$treat <- 1

fit <- survfit( Surv(time, status)~1, data=df )

# Save dataframe + fit
save(df, fit, file = "data/a1.Rdata")


