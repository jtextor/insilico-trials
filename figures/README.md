# Reproducing Analyses

This folder contains all R code to reproduce the analyses reported in our paper. You need to have the TumorImmuneModels R package, also contained in this repository, already installed. Further, you need to have the R packages listed in Supplementary Table 1 in the paper installed.

For each Figure, there is a separate folder (except for Figure 1, which is a pure illustration without real data). To just re-do the plot, go to the folder and use the `Makefile` (or follow the commands therein). If you also want to re-do the simulations, you need to either delete the intermediate files found in "data/" in each folder, or you can use `make -B` to force everything to be re-generated.

For Figures 5-7, the Makefiles are by default in "draft mode" setting, which will generate smaller/less simulations to save time. To use the same number of simulations as shown in the paper, remove the line saying `export DRAFT_MODE=1` from the Makefile.

If you are using this, we would be very curious to hear from you!




