# Script to create the "Source Data" Excel file as required by Nature Communications.

library( xlsx )

wb <- createWorkbook( type="xlsx" )

mkS <- function( sheet, x, y, s, makebold=FALSE ){
	rows <- createRow( sheet, y )
	cells <- createCell( rows, colIndex = x )
	if( length(x) > 1 ){
		invisible( mapply(setCellValue,  cells[1,], s ) )
	} else if( length(y) > 1 ){
		invisible( mapply(setCellValue,  cells[,1], s ) )
	} else {
		setCellValue( cells[[1,1]], s )
		if( makebold ){
			invisible( setCellStyle( cells[[1,1]], CellStyle(wb) +
        			Font(wb, isBold=TRUE) ) )
		}
	}
}

newSheet <- function( title ){
	s <- createSheet(wb, sheetName = title)
	mkS( s, 1, 1, title, makebold=TRUE )
	s
}


reportsurv <- function( sheet, results, title=NULL, x=1, y=1 ){
	if( "treatment" %in% colnames(results) ){
		df <- results[order(results$treatment,results$time),]
	} else {
		df <- results[order(results$time),]
	}
	if( !is.null(title) ){
		mkS( sheet, x+2-1, y+2-1, paste0(title,"; time in months; status: 0=alive, 1=dead") )
	}
	invisible( addDataFrame( df, sheet, startRow=y+3-1, startColumn=x+3-1, row.names=FALSE ) )
}


## Figure 3

load("figure-3/data/a1.Rdata")
sheet_3a <- newSheet("Figure 3A,S1A")
df$status <- df$status-1
df <- df[,c("time","status")]
reportsurv( sheet_3a, df, x=1 )

load("figure-3/data/a2.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_3a, df, x=11 )

load("figure-3/data/a3.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_3a, df, x=21 )

mkS( sheet_3a, c(2, 12, 22), 2,
	c("NCCTG lung cancer survival data; time in months; status: 0=alive, 1=dead", 
	"Digitized CA184-024 survival data; time in months; status: 0=alive, 1=dead",
	"Digitized CheckMate 066 survival data; time in months; status: 0=alive, 1=dead") )


load("figure-3/data/b1.Rdata")
sheet_3b <- newSheet("Figure 3B")
df$status <- df$status-1
df <- df[,c("time","status")]
reportsurv( sheet_3b, df, x=1 )

load("figure-3/data/b2.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_3b, df, x=11 )

load("figure-3/data/b3.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_3b, df, x=21 )

mkS( sheet_3b, c(2, 12, 22), 2,
	c("Simulated lung cancer survival data (model M1); time in months; status: 0=alive, 1=dead", 
	"Simulated CA184-024 survival data (model M1); time in months; status: 0=alive, 1=dead",
	"Simulated CheckMate 066 survival data (model M1); time in months; status: 0=alive, 1=dead") )



## Figure 4

reportsurv( newSheet("Figure 4A"), read.csv("figure-4/data/M1_chemotherapy_vs_placebo.csv.gz"),
	"Simulated trial: chemotherapy vs placebo (M1)" )

reportsurv( newSheet("Figure 4B"), read.csv("figure-4/data/M2_chemotherapy_vs_placebo.csv.gz"),
	"Simulated trial: chemotherapy vs placebo (M2)" )

reportsurv( newSheet("Figure 4C"), read.csv("figure-4/data/M3_chemotherapy_vs_placebo.csv.gz"),
	"Simulated trial: chemotherapy vs placebo (M3)" )

reportsurv( newSheet("Figure 4D"), read.csv("figure-4/data/M1_chemoimmunotherapy_vs_chemotherapy.csv.gz"),
	"Simulated trial: chemoimmunotherapy vs chemotherapy (M1)" )

reportsurv( newSheet("Figure 4E"), read.csv("figure-4/data/M1_immunotherapy_vs_chemotherapy.csv.gz"),
	"Simulated trial: immunotherapy vs chemotherapy (M1)" )

reportsurv( newSheet("Figure 4F"), read.csv("figure-4/data/M1_induction_chemotherapy_followed_by_immunotherapy_vs_immunotherapy.csv.gz"),
	"Simulated trial: induction chemotherapy, followed by immunotherapy vs. Immunotherapy (M1)" )

## Figure 5


report5 <- function( sheet, results, title, startRow=4 ){
	df <- t(results)
	rownames(df) <- df[,1]
	df <- df[,-1]
	addDataFrame( df, sheet, startRow=startRow, startColumn=3 )
	mkS( sheet, 3:7, startRow, c("patients per arm", "positive trials","negative trials","positive trials ","negative trials") )
	mkS( sheet, c(4,6), startRow-1, c("2-year OS","Hazard ratio") )
	mkS( sheet, 2, startRow-2, title  )
}

load("figure-5/data/power-analysis.Rdata")

report5( newSheet("Figure 5A"), y_chemo_placebo_m1, "Chemotherapy vs placebo trials, model M1, positive and negative simulated trials by effect size metric, 250 simulations each" )
report5( newSheet("Figure 5B"), y_immunochemo_chemo_m2, "Chemoimmunotherapy vs chemotheraphy trials, model M2, positive and negative simulated trials by effect size metric, 250 simulations each" )
report5( newSheet("Figure 5C"), y_chemo_placebo_m3, "Chemotherapy vs placebo trials, model M3, positive and negative simulated trials by effect size metric, 250 simulations each" )


## Figure 6

load("figure-6/data/insilico-trials.Rdata")

sheet_6a <- newSheet("Figure 6A")

report6 <- function( sheet, title, results, groups, x, y ){
	mkS( sheet, x+1, y, title )
	df <- do.call( cbind, lapply( results, function(x) t(do.call(rbind,x)) ) )
	rownames( df ) <- endpoint_times
	addDataFrame( df, sheet, startRow=y+2, startColumn=x+2 )
	mkS( sheet, x+(2:14), y+2, c("trial duration (months)", 
		rep( c("power (%)","95% CI lo","95% CI hi"), 4 ) ) )
	mkS( sheet, x+c(2,5,8,11)+1, y+1, groups )
}

report6( sheet_6a, 
	"Power by study size (chemotherapy vs placebo, randomization ratio 1:1, 400 simulations per estimate",
	results_chemo, c(100,200,400,800),  1, 2 )

report6( sheet_6a,
	"Power by randomization ratio, chemotherapy vs placebo, study size 300, 400 simulations per estimate",
	results_chemo_rr, c("1:1","2:1","3:1","3:2"),  1, 15 )

sheet_6b <- newSheet("Figure 6B")

report6( sheet_6b, 
	"Power by study size ,immunotherapy vs chemotherapy, randomization ratio 1:1, 400 simulations per estimate",
	results_immuno, c(200,400,800,1200),  1, 2 )

report6( sheet_6b,
	"Power by randomization ratio, immunotherapy vs chemotherapy, study size 1200, 400 simulations per estimate",
	results_immuno_rr, c("1:1","2:1","3:1","3:2"),  1, 15 )

## Figure 7

load("figure-7/data/alluvial.Rdata")

colnames( stages_none_0 ) <- colnames( stages_weak_0 ) <- colnames( stages_strong_0 ) <- 
colnames( stages_none_1 ) <- colnames( stages_weak_1 ) <- colnames( stages_strong_1 ) <- 
colnames( stages_none_2 ) <- colnames( stages_weak_2 ) <- colnames( stages_strong_2 ) <- 
colnames( stages_none_3 ) <- colnames( stages_weak_3 ) <- colnames( stages_strong_3 ) <- 
	c("Inconclusive","Positive","Negative","Harmful")

rownames( stages_none_0 ) <- rownames( stages_weak_0 ) <- rownames( stages_strong_0 ) <- 
	c("start", "24 months")
rownames( stages_none_1 ) <- rownames( stages_weak_1 ) <- rownames( stages_strong_1 ) <- 
	c("start", "12 months", "24 months")
rownames( stages_none_2 ) <- rownames( stages_weak_2 ) <- rownames( stages_strong_2 ) <- 
	c("start", "8 months", "16 months", "24 months")
rownames( stages_none_3 ) <- rownames( stages_weak_3 ) <- rownames( stages_strong_3 ) <- 
	c("start", "6 months", "12 months", "18 months", "24 months")

sheet_7 <- newSheet("Figure 7")

mkS( sheet_7, 3+c(0,6,12), 2, c("No effect","Weak effect","Strong effect") )
mkS( sheet_7, 2,3+c(0,6,12,18), c("No interim analysis","1 interim analysis",
			"2 interim analyses","3 interim analyses") )

addDataFrame( stages_none_0, sheet_7, startRow=4, startColumn=3 ) 
addDataFrame( stages_weak_0, sheet_7, startRow=4, startColumn=9 ) 
addDataFrame( stages_strong_0, sheet_7, startRow=4, startColumn=15 ) 

addDataFrame( stages_none_1, sheet_7, startRow=10, startColumn=3 ) 
addDataFrame( stages_weak_1, sheet_7, startRow=10, startColumn=9 ) 
addDataFrame( stages_strong_1, sheet_7, startRow=10, startColumn=15 ) 

addDataFrame( stages_none_2, sheet_7, startRow=16, startColumn=3 ) 
addDataFrame( stages_weak_2, sheet_7, startRow=16, startColumn=9 ) 
addDataFrame( stages_strong_2, sheet_7, startRow=16, startColumn=15 ) 

addDataFrame( stages_none_3, sheet_7, startRow=22, startColumn=3 ) 
addDataFrame( stages_weak_3, sheet_7, startRow=22, startColumn=9 ) 
addDataFrame( stages_strong_3, sheet_7, startRow=22, startColumn=15 ) 


## Supplementary Figure 1

load("figure-3/data/c1.Rdata")
sheet_s1b <- newSheet("Supplementary Figure 1B")
df$status <- df$status-1
df <- df[,c("time","status")]
reportsurv( sheet_s1b, df, x=1 )

load("figure-3/data/c2.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_s1b, df, x=11 )

load("figure-3/data/c3.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_s1b, df, x=21 )

mkS( sheet_s1b, c(2, 12, 22), 2,
	c("Simulated lung cancer survival data (model M2); time in months; status: 0=alive, 1=dead", 
	"Simulated CA184-024 survival data (model M2); time in months; status: 0=alive, 1=dead",
	"Simulated CheckMate 066 survival data (model M2); time in months; status: 0=alive, 1=dead") )



load("figure-3/data/d1.Rdata")
sheet_s1c <- newSheet("Supplementary Figure 1C")
df$status <- df$status-1
df <- df[,c("time","status")]
reportsurv( sheet_s1c, df, x=1 )

load("figure-3/data/d2.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_s1c, df, x=11 )

load("figure-3/data/d3.Rdata")
colnames(df) <- c("treatment","time","status")
reportsurv( sheet_s1c, df, x=21 )

mkS( sheet_s1c, c(2, 12, 22), 2,
	c("Simulated lung cancer survival data (model M3); time in months; status: 0=alive, 1=dead", 
	"Simulated CA184-024 survival data (model M3); time in months; status: 0=alive, 1=dead",
	"Simulated CheckMate 066 survival data (model M3); time in months; status: 0=alive, 1=dead") )

## Supplementary Figure 2

reportsurv( newSheet("Supplementary Figure 2"), read.csv("figure-4/data/M1_long_chemotherapy_vs_placebo.csv.gz"),
	"Simulated trial: long chemotherapy vs placebo (M1)" )


## Supplementary Figure 3

reportsurv( newSheet("Supplementary Figure 3A"), read.csv("figure-4/data/M2_chemoimmunotherapy_vs_chemotherapy.csv.gz"),
	"Simulated trial: chemoimmunotherapy vs chemotherapy (M2)" )

reportsurv( newSheet("Supplementary Figure 3B"), read.csv("figure-4/data/M2_immunotherapy_vs_chemotherapy.csv.gz"),
	"Simulated trial: immunotherapy vs chemotherapy (M2)" )

reportsurv( newSheet("Supplementary Figure 3C"), read.csv("figure-4/data/M2_induction_chemotherapy_followed_by_immunotherapy_vs_immunotherapy.csv.gz"),
	"Simulated trial: induction chemotherapy, followed by immunotherapy vs. Immunotherapy (M2)" )



## Supplementary Figure 4

reportsurv( newSheet("Supplementary Figure 4A"), read.csv("figure-4/data/M3_chemoimmunotherapy_vs_chemotherapy.csv.gz"),
	"Simulated trial: chemoimmunotherapy vs chemotherapy (M3)" )

reportsurv( newSheet("Supplementary Figure 4B"), read.csv("figure-4/data/M3_immunotherapy_vs_chemotherapy.csv.gz"),
	"Simulated trial: immunotherapy vs chemotherapy (M3)" )

reportsurv( newSheet("Supplementary Figure 4C"), read.csv("figure-4/data/M3_induction_chemotherapy_followed_by_immunotherapy_vs_immunotherapy.csv.gz"),
	"Simulated trial: induction chemotherapy, followed by immunotherapy vs. Immunotherapy (M3)" )





## Supplementary Figure 5

sheet_s5a <- newSheet("Supplementary Figure 5A") 
s5atitle <- function(model=1){
	paste0( "Chemotherapy vs placebo trials, model M",model,", positive and negative simulated trials by effect size metric, 250 simulations each" )
}
report5( sheet_s5a, y_chemo_placebo_m1, s5atitle(1), 4 )
report5( sheet_s5a, y_chemo_placebo_m2, s5atitle(2), 14 )
report5( sheet_s5a, y_chemo_placebo_m3, s5atitle(3), 24 )


sheet_s5b <- newSheet("Supplementary Figure 5B") 
s5btitle <- function(model=1){
	paste0( "Chemoimmunotherapy vs chemotheraphy trials, model M",model,", positive and negative simulated trials by effect size metric, 250 simulations each" )
}
report5( sheet_s5b, y_immunochemo_chemo_m1, s5atitle(1), 4 )
report5( sheet_s5b, y_immunochemo_chemo_m2, s5atitle(2), 14 )
report5( sheet_s5b, y_immunochemo_chemo_m3, s5atitle(3), 24 )




## Save final results

saveWorkbook( wb, "source-data.xlsx" )




