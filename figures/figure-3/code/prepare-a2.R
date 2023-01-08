library(IPDfromKM)
library(survival)
library(dplyr)

# Read digitized data from Excel file and filter form first 25 months
df <- read.csv2("../data/ipi_placebo_digitized.csv", header = T) %>% 
  filter(time<25)

# Split in two seperate datasets: placebo & treatment (=ipilimumab)
curve_placebo <- df %>% 
  filter(drug == "placebo") %>% 
  select(time, survival)

curve_ipilimumab <- df %>% 
  filter(drug == "ipi") %>% 
  select(time, survival)

# 1) Preprocess the coordinates into a format to reconstruct IPD, and 
# 2) reconstruct individual patient data (IPD) from Kaplan-Meier curves
preprocess_placebo <- preprocess(dat = curve_placebo, trisk = seq(0,24,4), 
                                 nrisk = c(252, 192, 136, 90, 73, 56, 44), 
                                 totalpts = 252, maxy = 1)
ipd_placebo <- getIPD(prep=preprocess_placebo,armID=0,tot.events=219)

preprocess_ipilimumab <- preprocess(dat = curve_ipilimumab, trisk = seq(0,24,4), 
                                    nrisk = c(250, 200, 159, 116, 92, 80, 69), 
                                    totalpts = 250, maxy = 1)
ipd_ipi <- getIPD(prep=preprocess_ipilimumab,armID=1,tot.events=193)

# Combine IPD from both study arms in single dataframe
df <- bind_rows(list(placebo = ipd_placebo$IPD, ipi = ipd_ipi$IPD), 
                .id = "id") %>% 
  select(-treat)

# Create survival curve
fit <- survfit( Surv(time, status)~id, data = df )

# Save data frame and fit
save(df, fit, file = "data/a2.Rdata")
