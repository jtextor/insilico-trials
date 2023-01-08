
source("../parameters.R")
source("../settings.R")
source("../tools.R")
source("code/helper-simulated-trial.R")

pdf_out( file="plots/chemo-placebo-m2.pdf", width=5.667*0.3937, height=3.45*0.3937, pointsize=8 )

plt( model="M2", lg_t=chemo_effect_m2, xlab="", get_s=get_s_M2, baseline_pars=baseline_m2, treatment_schedule = {
	segments( 0, -.05, 6, -.05, lwd=1.5, lend=1 )
}, mfrow=c(1,1) )

dev.off()


pdf_out( file="plots/insilico-trials-m2.pdf", width=17*0.3937, height=3.45*0.3937, pointsize=8 )

plt_series( "M2", baseline_m2, chemo_effect_m2, immuno_effect_m2 )

dev.off()

