# Fit of ODE models to data

This folder contains various scripts showing how we fitted our ODE models to the (digitized) survival data from the three cohort shown in Figure 3A. Not all of the scripts were eventually used, see Makefile for the scripts that were used. The Makefile has a "DRAFT_MODE" variable that we recommend to use at first to see if the fit is working with small population. Then when you want to use the same population size that we used in the paper, comment out or remove the line with the DRAFT_MODE variable.

As an example, here's some code to perform ABC with a small population using model M1 on the CA184-024 data, and plot the posterior distribution, where we fix the chemotherapy effect to a value of 0.6 as done in the paper:

```
Sys.setenv(DRAFT_MODE=1)
source("code/fit-treated-ipi-fix-ch.R")
```

This code will write the final the ABC trace in and update current best point in the file `M1-ipi-fix-ch-xmin-draft.Rds` while it is iterating. After the code is done (at most 10 generations, or when the rejection rate is higher than 90% for two subsequent generations), it will write out the ABC trace to the file`M1-ipi-fix-ch-abc-result-draft.Rds`. This can now be vizualized as follows:

```
p <- readRDS("data/M1-ipi-fix-ch-abc-result-draft.Rds")
source("../tools.R")
par( mfcol=c(1,4) )
plot_posteriors(p) # note that the 3rd posterior is not really a distribution, as this value was fixed
```


