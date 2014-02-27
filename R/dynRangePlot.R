#' Produce signal-abundance plot to evaluate dynamic range
#'
#' @param expDat    list, contains input data and stores analysis results
#' @param errorBars logical, if TRUE error bars will be provided for replicates
#' 
#' @export

dynRangePlot <- function(expDat, errorBars = NULL){
  if (is.null(errorBars)){
    errorBars = TRUE
  }
  sampleInfo <- expDat$sampleInfo
  plotInfo <- expDat$plotInfo
  erccInfo <- expDat$erccInfo
  
  idCols = expDat$idColsAdj
  sampleNames = expDat$sampleNames
  
  indivxlabel = plotInfo$ERCCxlabelIndiv
  avexlabel= plotInfo$ERCCxlabelAve
  
  expressDat = expDat$normERCCDat
  designMat = expDat$designMat
  FCcode = erccInfo$FCcode 
  
  myXLim = plotInfo$myXLim 
  myYLim = plotInfo$myYLim
  xlimEffects = plotInfo$xlimEffects
  filenameRoot <- sampleInfo$filenameRoot
  #theme_set(theme_bw(base_size=16))
  
  colScale <- plotInfo$colScale
  fillScale <- plotInfo$fillScale
  
  # Create dynamic range data frame for ERCC Mix 1 samples
  dynRangeDatMix1 = merge(idCols[c(1,4,5)],expressDat)
  names(dynRangeDatMix1)[3] = "Conc"
  cat(paste("\nNumber of ERCCs in Mix 1 dyn range: ",dim(dynRangeDatMix1)[1], "\n"))
  
  # Melt the data to create long data frame for ggplot
  dynRangeDatMix1_l = melt(dynRangeDatMix1, id.vars=c("Feature", "Ratio","Conc") ) 
  
  # Create data.frame of the experimental design factors
  designVar = colsplit(dynRangeDatMix1_l$variable,pattern = "_", name = names(designMat)[-1])
  designVar <- as.data.frame(lapply(designVar,as.factor))  
  
  # Bind Mix 1 data and experimental design factors
  dynRangeDatMix1_l = cbind(dynRangeDatMix1_l, designVar)
  
  #Create dynamic range data frame for ERCC Mix 2 samples
  dynRangeDatMix2 = merge(idCols[c(1,4,6)],expressDat)
  names(dynRangeDatMix2)[3] = "Conc"
  cat(paste("\nNumber of ERCCs in Mix 2 dyn range: ",dim(dynRangeDatMix2)[1], "\n"))
  
  # Melt the data to create long data frame for ggplot
  dynRangeDatMix2_l = melt(dynRangeDatMix2, id.vars=c("Feature", "Ratio","Conc") )
  
  # Create data.frame of the experimental design factors
  designVar = colsplit(dynRangeDatMix2_l$variable,pattern = "_", name = names(designMat)[-1])
  designVar <- as.data.frame(lapply(designVar,as.factor))
  
  # Bind Mix 2 data and experimental design factors
  dynRangeDatMix2_l = cbind(dynRangeDatMix2_l, designVar)
  
  # Sort the data
  dynRangeDatMix1_l = dynRangeDatMix1_l[do.call(order, dynRangeDatMix1_l[c(3)]),]  
  dynRangeDatMix2_l = dynRangeDatMix2_l[do.call(order, dynRangeDatMix2_l[c(3)]),]
  
  # Merge the dynamic range data frames
  dynRangeDatMix1_l$MixConc = "Mix1"
  dynRangeDatMix2_l$MixConc = "Mix2"
  dynRangeDatMix1 = subset(dynRangeDatMix1_l, (Sample == sampleNames[1]))
  dynRangeDatMix2 = subset(dynRangeDatMix2_l, (Sample == sampleNames[2]))
  
  dynRangeDat_l = rbind(dynRangeDatMix1, dynRangeDatMix2)
  dynRangeDat_l$Feature = as.factor(as.character(dynRangeDat_l$Feature))
  
  #browser()
  
  #####
  # Signal Abundance of Plot Sample A and B
  #####
  
  AandB = subset(dynRangeDat_l,((Sample == sampleNames[1])|(Sample == sampleNames[2])))
  Adat = subset(AandB, Sample == sampleNames[1])
  Bdat = subset(AandB, Sample == sampleNames[2])
  
  # Log the data and then filter out NA and Inf Mn and Sd values
  Adat$value = log2(Adat$value)
  Adat$Conc = log2(Adat$Conc)
  
  AdatAve <- data.frame(tapply(Adat$value,Adat[,"Feature"],mean))
  AdatSD <- as.vector(tapply(Adat$value,Adat[,"Feature"],sd))
  AdatAveSD = cbind(row.names(AdatAve),Adat$Ratio[match(row.names(AdatAve),
                                                        table=Adat$Feature)],
                    Adat$Sample[match(row.names(AdatAve),table=Adat$Feature)],
                    Adat$Conc[match(row.names(AdatAve),table=Adat$Feature)],
                    AdatAve[c(1)])
  names(AdatAveSD)[1:5] = c("Feature","Ratio","Sample","Conc","value.Ave")
  
  AdatAveSD$value.SD = AdatSD
  
  Bdat$value = log2(Bdat$value)
  Bdat$Conc = log2(Bdat$Conc)
  
  BdatAve <- data.frame(tapply(Bdat$value,Bdat[,"Feature"],mean))
  BdatSD <- as.vector(tapply(Bdat$value,Bdat[,"Feature"],sd))
  
  BdatAveSD = cbind(row.names(BdatAve),Bdat$Ratio[match(row.names(BdatAve),
                                                        table=Bdat$Feature)],
                    Bdat$Sample[match(row.names(BdatAve),table=Bdat$Feature)],
                    Bdat$Conc[match(row.names(BdatAve),table=Bdat$Feature)],
                    BdatAve[c(1)])
  names(BdatAveSD)[1:5] = c("Feature","Ratio","Sample","Conc","value.Ave")
  
  BdatAveSD$value.SD = BdatSD
  
  AandBAveSD = rbind(AdatAveSD, BdatAveSD)
  cutERCCs = unique(AandBAveSD$Feature[which(is.na(AandBAveSD$value.SD))])
  
  #print(which(AandBAveSD$Feature %in% cutERCCs))
  if(length(cutERCCs) != 0){
    cat(paste("These ERCCs were not included in the signal-abundance plot,",
                "because not enough non-zero replicate measurements of these ",
                "controls were obtained for both samples:\n","",sep = '\n'))
    cutERCCs <- as.character(cutERCCs)
    for (j in seq(from=1,to=length(cutERCCs),by=5)){
      k = j+4
      if (k > length(cutERCCs)) k = length(cutERCCs)
      cat(cutERCCs[j:k])
      cat("\n")
    } 
    AandBAveSD = AandBAveSD[-(which(AandBAveSD$Feature %in% cutERCCs)),]  
  } 
  
  AandBAveSD$Feature = as.factor(as.character(AandBAveSD$Feature))
  
  AandBAveSD$value.Ave = as.vector(AandBAveSD$value.Ave)
   
  #set limits and axis labels
  yinfo = ylab("Read Depth Normalized Log2 Transformed ERCC Counts")
  #xlabel = xlab(expression(paste("Log2 ERCC Spike Amount (attomol nt/ng total RNA",mu,"L)",sep = "")))
  xlabel = xlab(indivxlabel)
  if(is.null(myXLim)){
    xmin = min(AandBAveSD$Conc) - 1
    xmax = max(AandBAveSD$Conc) + 1
    myXLim = c(xmin,xmax)
  }
  if(is.null(myYLim)){
    ymin = min(AandBAveSD$value.Ave) - 1
    ymax = max(AandBAveSD$value.Ave) +1
    myYLim = c(ymin,ymax)
  }
  myYLim = myYLim
  myXLim = myXLim
  
  plotLim = coord_cartesian(xlim=myXLim,ylim = myYLim)
  
  ### Create a linear model for the data
  dataFit = AandBAveSD
  #write.csv(dataFit, paste(filenameRoot,"dataFit.csv"))
  # Create smoothed variance weights based on spline

  data.lo <- loess(value.SD~Conc,data = dataFit)
  (data.lo)
  loessWtEst = ggplot(dataFit, aes(x = Conc, y = value.SD)) + geom_point() + 
    geom_smooth(method = "loess")
 
  
  data.lo.pred = predict(data.lo, dataFit$Conc) 
  
  wtSet = 1/((data.lo.pred)^2)
  
  dataFit$wtSet = wtSet
  
  if(errorBars == FALSE) AandBAveSD$value.SD <- 0
  
  dynRange = ggplot() + 
    geom_pointrange(data = subset(AandBAveSD,Sample == sampleNames[1]),
                    aes(x = Conc,y = value.Ave, ymax = value.Ave+ value.SD, 
                        ymin = value.Ave - value.SD, colour = Ratio, 
                        shape = Sample),alpha = 0.6, size = 1.25) + 
    geom_pointrange(data = subset(AandBAveSD,Sample == sampleNames[2]),
                    aes(x = Conc,y = value.Ave, ymax = value.Ave + value.SD,
                        ymin = value.Ave - value.SD, colour = Ratio,
                        shape = Sample),alpha = 0.6,size =1.25) + xlabel + 
    yinfo + plotLim + colScale + 
    theme_bw() +theme( legend.justification = c(0,1), legend.position=c(0,1))
  
  showlmGeomSmooth = dynRange + geom_smooth(data = dataFit, method=lm,
                                             aes(x = Conc, y = value.Ave, 
                                                 weight = wtSet),
                                             colour = "black",se = F)
  
   ### Serial model approach

  # fit1 is linear model of value.Ave and Conc, needed for the LODR to Concentration conversion
  # fit2 adds in ERCC to the fit1 model
  # comparison of fit2 to fit1 should allow for t-test to identify outlier ERCC controls on the basis of a per ERCC slope and intercept comparison to the fit1 slope
  fit1.lm = lm(data = dataFit,formula = value.Ave~Conc,weights=wtSet)
  fit2.lm = lm(data = dataFit,formula = value.Ave~Conc+as.factor(Feature),
               weights=wtSet)
  
  perERCC<-as.data.frame(coef(summary(fit2.lm)))
  #print("perERCC data frame")
  
  perERCC<- perERCC[-(2),]
  
  # compare ERCC specific intercepts to overall fit1 intercept
  perERCC[,1]<-(perERCC[1,1]+c(0,perERCC[-1,1]))-coef(fit1.lm)[1]
  
  Conc1 = dataFit$Conc[which(dataFit$Sample == sampleNames[1])]
  Conc2 = dataFit$Conc[which(dataFit$Sample == sampleNames[2])]
  AveConc = (Conc1 + Conc2)/2
  
  # standardized ERCC effect = perERCC[,1]/perERCC[,2], consider it size of ERCC effect in standard errors (unitless)
  effects <- data.frame(Feature = levels(dataFit$Feature),AveConc = AveConc,
                        ERCC.effect = perERCC[,1]/perERCC[,2])
  
  effects$Feature <- as.factor(effects$Feature)
  effects$Ratio <- dataFit$Ratio[1:nlevels(dataFit$Feature)]
    
  minLabel = effects$ERCC.effect <= fivenum(effects$ERCC.effect)[2]- 
    1.5*IQR(effects$ERCC.effect)
  maxLabel = effects$ERCC.effect >= fivenum(effects$ERCC.effect)[4]+ 
    1.5*IQR(effects$ERCC.effect)
  xlabel = xlab(avexlabel)
  if(is.null(xlimEffects)){
    xlimEffects = c((min(effects$ERCC.effect)-0.5),
                    (max(effects$ERCC.effect)+0.5))  
  }
  
#if((any(minLabel))|(any(maxLabel))){
  if((any(minLabel))){
  effectsPlot = ggplot(effects, aes(x = AveConc, y = ERCC.effect)) + 
    geom_point(aes(colour = Ratio),size = 6, alpha = 0.8) + xlabel +
    ylab("Per ERCC Differences from Linear Fit Standardized by s.e., unitless)") +
    coord_cartesian(ylim = xlimEffects, xlim = myXLim) + colScale + 
    geom_text(data=subset(effects,(ERCC.effect <= fivenum(ERCC.effect)[2] - 
                                     (1.5)*IQR(ERCC.effect))),
              aes(x = AveConc, y = ERCC.effect, label = gsub("ERCC-00","",
                                                             Feature)),
              colour = "black",show_guide = F,angle = 45,hjust = -0.25, 
              position = position_jitter(width=0.5)) + theme_bw() + 
    theme(legend.justification=c(0,0), legend.position = c(0,0))
  }else{
  effectsPlot = ggplot(effects, aes(x = AveConc, y = ERCC.effect)) + 
    geom_point(aes(colour = Ratio),size = 6, alpha = 0.8) + xlabel + 
    ylab("Per ERCC Differences from Linear Fit Standardized by s.e., unitless)") +
    coord_cartesian(ylim= xlimEffects, xlim = myXLim) + colScale + theme_bw() + 
    theme(legend.justification = c(0,0), legend.position = c(0,0)) 
}  
  
# Get the residuals from fit1.lm

  fit.coeff = unlist(fit1.lm$coefficients)
  #expDat$fit.coeff <- fit.coeff
  
  
  if(sampleInfo$datType == "array"){
    effectsPlot <- NULL
    cat("\ndatType is array, no linear model fit for ERCC specific effects\n")
    cat("\nrangeResidPlot is empty")
  }
  cat("\n\nSaving dynRangePlot to expDat\n")
  expDat$Figures$dynRangePlot <- dynRange
  expDat$Figures$rangeResidPlot <- effectsPlot
  
  
  expDat$Results$dynRangeDat <- AandBAveSD
  expDat$Results$rangeResidDat <- effects
  return(expDat)
 
}