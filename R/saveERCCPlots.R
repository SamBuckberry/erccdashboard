#' Save erccdashboard plots to a pdf file
#'
#' @param exDat     list, contains input data and stores analysis results
#' @param plotsPerPg string, if "manuscript" then the 4 main plots are printed  
#'                   to one page, if "single" then each plot is printed to page 
#'                   in the pdf file                     
#' @param plotlist   list, contains plots to print
#' 
#' @description
#' The function savePlots will save selected figures to a pdf file. The default 
#' is the 4 manuscript figures to a single page (plotsPerPg = "manuscript"). 
#' If plotsPerPg = "single" then each plot is placed on an 
#' individual page in one pdf file. If plotlist is not defined (plotlist = NULL)
#'  then all plots in exDat$Figures are printed to the file.
#' 
#' #to print 4 plots from manuscript to a single page pdf file
#' saveERCCPlots(exDat, plotsPerPg = "manuscript")
#' 
#' #to create a multiple page pdf of all plots produced
#' saveERCCPlots(exDat, plotsPerPg = "single", plotlist = exDat$Figures)
#' @export

saveERCCPlots<-function(exDat,plotsPerPg = "manuscript", plotlist = NULL){
    # Options are either the default of printing the plots as shown in 
    ## publication (plotsPerPg = "manuscript" and plotlist is NULL) or 
    # to print plots one per page choose (plotsPerPg = "single" and provide any
    # list of plots as the plotlist arguement
    
    
    # Open PDF file to write results
    filenameUse <- exDat$sampleInfo$filenameRoot 
    #   if (plotsPerPg == "manuscript"){
    #     cols = 2
    #     pwidth = 7*cols
    #     pheight = 7*6/cols
    #     pdf(file = paste(filenameUse,"pdf",sep="."),title=filenameUse, 
    #         width=pwidth,height = pheight)
    #     
    #     multiplot(exDat$Figures$rocPlot,exDat$Figures$dynRangePlot, 
    #               exDat$Figures$lodrERCCPlot,exDat$Figures$rangeResidPlot, 
    #               exDat$Figures$dispPlot,exDat$Figures$maPlot,cols=2)
    #     dev.off()
    #   } 
    
    cat("\nSaving main dashboard plots to pdf file...")
    if (plotsPerPg == "manuscript"){
        cols = 2
        nFigs = 4
        pwidth = 7*cols
        pheight = 7*nFigs/cols
        pdf(file = paste(filenameUse,"pdf",sep="."),title=filenameUse,
            width=pwidth,height = pheight)
        #pdf(file =  paste(filenameUse,"pdf",sep="."),title=filenameUse,
        #    paper = "letter")
        multiplot(exDat$Figures$dynRangePlot, exDat$Figures$rocPlot,
                  exDat$Figures$maPlot, exDat$Figures$lodrERCCPlot, cols=cols)
        dev.off()
    }
    if (plotsPerPg == "single"){
        if (is.null(plotlist)){
            plotlist = exDat$Figures
        } 
        pdf(file = paste(filenameUse,"pdf",sep="."),onefile=TRUE,width=7,
            height = 7)
        print(plotlist)
        dev.off()
    }
    
}
