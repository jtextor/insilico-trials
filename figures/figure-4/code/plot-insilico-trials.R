
source("../parameters.R")
source("../settings.R")
source("../tools.R")

source("code/helper-simulated-trial.R")


pdf_out( file="plots/chemo-placebo.pdf", width=5.667*0.3937, height=3.45*0.3937, pointsize=8 )

plt( model="M1", lg_t=chemo_effect_m1, xlab="", get_s=get_s_M1, baseline_pars=baseline_m1, treatment_schedule = {
	segments( 0, -.05, 6, -.05, lwd=1.5, lend=1 )
}, mfrow=c(1,1) )

dev.off()

pdf_out( file="plots/insilico-trials.pdf", width=17*0.3937, height=3.45*0.3937, pointsize=8 )

plt_series( "M1", baseline_m1, chemo_effect_m1, immuno_effect_m1 )

## Longer chemotherapy for comparison
plt( lg_t=chemo_effect_m1, xlab="", main="Long chemotherapy vs. placebo", chemo_duration_t=24, treatment_schedule = {
	segments( 0, -.05, 24, -.05, lwd=1.5, lend=1 )
	} )

dev.off()

