library(IPDfromKM)
library(survival)
library(dplyr)

# Read digitized data from Excel file and filter form first 25 months
df <- read.csv2("../data/nivo_dacarb_digitized.csv", header = T) %>% 
  filter(time < 25)

# Split in two seperate datasets: placebo & treatment (=ipilimumab)
curve_dtic <- df %>% 
  filter(drug == "dacarbazine") %>% 
  select(time, survival)

curve_nivolumab <- df %>% 
  filter(drug == "nivolumab") %>% 
  select(time, survival)

# 1) Preprocess the coordinates into a format to reconstruct IPD, and 
# 2) reconstruct individual patient data (IPD) from Kaplan-Meier curves
preprocess_dtic <- preprocess(dat = curve_dtic, trisk = seq(0,24,3), 
                              nrisk = c(208, 179, 146, 122, 92, 76, 71, 62, 51), 
                              totalpts = 208, maxy = 1)
ipd_dtic <- getIPD(prep=preprocess_dtic,armID=0,tot.events=148)

preprocess_nivolumab <- preprocess(dat = curve_nivolumab, trisk = seq(0,24,3), 
                                   nrisk = c(210, 186, 171, 154, 143, 135, 128, 122, 116), 
                                   totalpts = 210, maxy = 1)
ipd_nivolumab <- getIPD(prep=preprocess_nivolumab,armID=1,tot.events=86)

# Combine IPD from both study arms in single dataframe
df <- bind_rows(list(dtic = ipd_dtic$IPD, nivo = ipd_nivolumab$IPD), 
                .id = "id") %>% 
  select(-treat)

# Create survival curve
fit <- survfit( Surv(time, status)~id, data = df )

# Save dataframe and fit
save(df, fit, file = "data/a3.Rdata")
