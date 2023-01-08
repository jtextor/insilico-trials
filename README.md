# Simulation model for cancer immunotherapy and chemotherapy trials 

This repository contains code and data related to the following manuscript: 

_In silico_ cancer immunotherapy trials uncover the consequences of therapy-specific response patterns for clinical trial design and outcome
Jeroen H.A. Creemers, Kit C.B. Roes, Niven Mehra, Carl G. Figdor, I. Jolanda M. de Vries, Johannes Textor
medRxiv 2021.09.09.21263319; doi: https://doi.org/10.1101/2021.09.09.21263319

The manuscript (the revised version of which can be found in this repository) describes three simulation models for cancer patient survival data with different immunotherapy treatments. This repository contains the source code of the simulation models, which are written in C++, as well as an R wrappers using the Rcpp package. These can be found in the directory models/TumorImmuneModels/. 

There is also a web-based implementation, written in JavaScript, available at https://computational-immunology.org/models/immunotherapy-trials/.

## System requirements

The web-based implementation should run on any computer that has a modern web browser. We have tried this on Chrome, Safari, and Firefox. 

The R package needs R (version 4.1.0 or higher) and various R packages, including Rcpp, installed (see list of R packages below). Your R platform needs to be able to compile C++ code. This should always be possible on Linux or Mac, but perhaps not in Windows. We have successfully installed and compiled the R package on Mac OS X Monterey and Ubuntu Linux 20.04.5 LTS.  

## Installation

No installation is required to run the web-based software.

For the R package, you can install this as any other R package. A simple way to do so would be to install the "remotes" R package first and then run

```
remotes::install_github("jtextor/insilico-trials/models/TumorImmuneModels")
```

## Demo and instructions

For the web-based version, visit the page https://computational-immunology.org/models/immunotherapy-trials/ and a demo simulation will immediately start running. To generate a study that shows a very clear immunotherapy effect, use the sliders to set the parameter "Growth Rate Mean" to 2.5 and "Immunotherapy effect" to 10 or higher. Note that these are stochastic simulations: re-running the simulations with the same parameters will generate different survival curves each time, due to the random variation in parameters. 

For the R package, see the example below.

```
library( TumorImmuneModels )
# Get survival when partial response to immune therapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M1(RAISE_KILLING=10)

# Get survival when complete response to immune therapy is achieved  
# using the default model parameters
survival <- get_survival_cpp_M1(RAISE_KILLING=15)

# Get survival when partial response to chemotherapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M1(LOWER_GROWTH=0.8)

# Get survival when complete response to chemotherapy is achieved  
# using the default model parameters
survival <- get_survival_cpp_M1(LOWER_GROWTH=0.19)

# Get survival when chemotherapy is followed by immune therapy  
# using the default model parameters
get_survival_cpp_M1(LOWER_GROWTH=0.5, CHEMO_DURATION=10, RAISE_KILLING=15, TREATMENT_DELAY=10, TREATMENT_DURATION=30)

# Model M2
# Get survival when no treatment is implemented using the default model parameters
survival <- get_survival_cpp_M2()

# Get survival when partial response to immune therapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M2(RAISE_KILLING=14000)

# Get survival when complete response to immune therapy is achieved  
# using the default model parameters
survival <- get_survival_cpp_M2(RAISE_KILLING=14500)

# Get survival when partial response to chemotherapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M2(LOWER_GROWTH_=0.5)

# Get survival when complete response to chemotherapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M2(LOWER_GROWTH_=0.01)

# Model M3
# Get survival when no treatment is implemented using the default model parameters
survival <- get_survival_cpp_M3()

# Get survival when partial response to immune therapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M3(RAISE_KILLING=10)

# Get survival when complete response to immune therapy is achieved  
# using the default model parameters
survival <- get_survival_cpp_M3(RAISE_KILLING=17)

# Get survival when partial response to chemotherapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M3(LOWER_GROWTH=0.8)

# Get survival when complete response to chemotherapy is achieved 
# using the default model parameters
survival <- get_survival_cpp_M3(LOWER_GROWTH=0.3)

# Simulates the disease trajectory when no treatment is implemented
t_max <- 365 * 5 # five years
y <- simulate_M1(t_max, 1, 1)
y <- matrix(y, ncol=3, byrow=TRUE) # transform to extract time scale, tumor size and intramural T cells number
# Visualize the disease course in a period shortly before treatment and until death
tumor_size_start <- 1e8
t_start <- which.max(y[,2] >= 1e8) - 1
y <- y[-(1:t_start),]
tumor_size_death <- 1e12
y <- y[y[,2] <= tumor_size_death,] 
day_in_month <- 30.4
y[,1] <- (y[,1] - min(y[,1])) / 30.4
# Plot the millions of tumor cells by months 
plot( y[,1], y[,2]/1e6, log="y", type="l", col="orange", xlab="", ylab="tumor burden (million cells)")

```


## List of R packages

 - bshazard (version 1.1)
 - dplyr (version 1.0.10)
 - ggplot2 (version 3.3.6)
 - ggsankey (version 0.0.99999 from https://github.com/davidsjoberg/ggsankey)
 - grid (version 4.2.0)
 - IPDfromKM (version 0.1.10)
 - ks (version 1.13.5)
 - ldbounds (version 2.0.0)
 - Rcpp (version 1.0.9)
 - survival (version 3.3-1)
 - survminer (version 0.4.9)
