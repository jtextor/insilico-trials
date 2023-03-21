
library( ggsankey ) # installed using remotes::install_github("davidsjoberg/ggsankey")
library( ggplot2 )
library( dplyr )

source("../tools.R")
source("../settings.R")

pdf_out( file="plots/alluvial.pdf", width=4.5*0.3937, 
	height=4.5*0.3937, pointsize=8 )

stages_to_flow <- function( stages, months=12 ){
	r <- tibble( x=list(), next_x=list(), node=list(), next_node=list() )
	for( i in 1:(nrow(stages)-1) ){
		from <- stages[i,]
		to <- stages[i+1,]
		r <- rbind( 
				r, 
				slice( tibble(
					n=from[1],
					x=paste0("",(i-1)*months), next_x=paste0("",i*months),
					node=paste0("running",i), next_node=paste0("running",i+1) ),
				rep(1,to[1]) )
			 )


		r <- rbind( 
				r, 
				slice( tibble(
					n=from[1],
					x=paste0("",(i-1)*months), next_x=paste0("",i*months),
					node=paste0("running",i), next_node=paste0("pos",i+1) ),
				rep(1,to[2]) )
			)

		r <- rbind( 
				r, 
				slice( tibble(
					n=to[2],
					x=paste0("",i*months), next_x=NA,
					node=paste0("pos",i+1), next_node=NA ),
				rep(1,to[2]) )
			)

		if( to[3] > 0 ){
			r <- rbind( r,
				slice( tibble(
				n=from[1],
				x=paste0("",(i-1)*months), next_x=paste0("",i*months),
				node=paste0("running",i), next_node=paste0("neg",i+1) ),
				rep(1,to[3]) )
			)

			r <- rbind( r,
				slice( tibble(
				n=to[3],
				x=paste0("",i*months), next_x=NA,
				node=paste0("neg",i+1), next_node=NA ),
				rep(1,to[3]) )
			)
		}


		if( to[4] > 0 ){
			r <- rbind( r,
				slice( tibble(
				n=from[1],
				x=paste0("",(i-1)*months), next_x=paste0("",i*months),
				node=paste0("running",i), next_node=paste0("harm",i+1) ),
				rep(1,to[4]) )
			)
			r <- rbind( 
				r, 
				slice( tibble(
					n=to[4],
					x=paste0("",i*months), next_x=NA,
					node=paste0("harm",i+1), next_node=NA ),
				rep(1,to[4]) )
			)
		}
	}

	r$x <- ordered( r$x, levels=seq(0,nrow(stages))*months )
	r$next_x <- ordered( r$next_x, levels=seq(0,nrow(stages))*months )

	return( as_tibble( r[,c("x","node","next_x","next_node","n")] ) )
}

make_colors <- function(df){
	r <- list()
	for( nn in df$node ){
		r[nn] <- "gray"
		if( grepl("^neg", nn) ){
			r[nn] <- "black"
		}
		if( grepl("^harm", nn) ){
			r[nn] <- "firebrick"
		}
		if( grepl("^pos", nn) ){
			r[nn] <- "seagreen4"
		}
		#if( grepl("^running", nn) ){
		#}
	}
	return(unlist(r))
}

plt <- function(df, ylab="Strong effect"){
	p <- ggplot(df, aes(x = x, 
               next_x = next_x, 
               node = node,
			   label = n,
               next_node = next_node,
               fill = factor(node))) +
 	geom_sankey( flow_alpha=.4 ) + 
	geom_sankey_label( size = 3, color = "white") + 
	scale_fill_manual(values = make_colors(df)) +
	theme_minimal() + xlab(NULL) + ylab(ylab) +
	theme( 	
		axis.text=element_text(size=8,family="sans"),
		axis.title=element_text(size=8,family="sans"),
		legend.position="none", 
		panel.grid.minor = element_blank(), 
		panel.grid.major = element_blank(), 
		axis.text.y=element_blank(),
		axis.ticks.y=element_blank() )

	print(p)

}


load("data/alluvial.Rdata" )

ylab <- c(
	strong="Strong effect",
	weak="Weak effect",
	none="No effect")

for( eff in c("strong","weak","none") ){
	cat(eff,"\n")
	for( i in seq(0,3) ){
		plt( stages_to_flow( get(paste0("stages_",eff,"_",i) ), 24/(i+1) ),
			ylab=if(i==0){ylab[eff]}else{NULL} )
	}
}

dev.off()

