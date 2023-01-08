
pdf_out <- function( file, pointsize=8, ... ){
        if( capabilities()['aqua'] ){
                # preferred device type with configurable fonts
                quartz( type="pdf", file=file, pointsize=pointsize, ...)
                par( family="sans" )

        } else {
                # fallback device type with default Helvetica font
                pdf( file, pointsize=pointsize, ...)
        }
}

quartzFonts(sans = quartzFont(c("Helvetica Light","Helvetica",
        "Helvetica Light Oblique","Helvetica Oblique")))


