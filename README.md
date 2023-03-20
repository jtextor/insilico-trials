# Simulation models for cancer immunotherapy and chemotherapy trials 

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

For the R package, see the example below, which re-creates (a simplified version of) 
Figure 3A in the paper.

```
library( TumorImmuneModels )

# Utility function to run simulation and get result in matrix format
# with desired units
getResultMatrix <- function( ... ){
	# Simulate model M1 with given paramters and store result
	r <- matrix(simulate_M1( ... ),byrow=TRUE,ncol=3,
		dimnames=list(NULL,c("time","tumor cells","T cells")))
	# Convert return time from days to months
	r[,"time"] <- r[,"time"] / 30.44
	# Express tumor burden in millions of cells
	r[,"tumor cells"] <- r[,"tumor cells"] / 1e6
	r
}

r <- getResultMatrix()
# Plot tumor cells over time for period of 2 years
plot(`tumor cells` ~ `time`, r, 
	xlab="time (months)", ylab="tumor burden (million cells)",
	log="y", xlim=c(0,24), type="l", ylim=c(1e2, 1e6) )

# Now simulate with weak immunotherapy effect
r <- getResultMatrix(RAISE_KILLING=10) 
# Add line to graph
lines( `tumor cells` ~ `time`, r, col="orange" )

# Now simulate strong immunotherapy effect
r <- getResultMatrix(RAISE_KILLING=19) 
# Add line to graph
lines( `tumor cells` ~ `time`, r, col="red" )


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
