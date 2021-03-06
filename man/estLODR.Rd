% Generated by roxygen2 (4.0.1): do not edit by hand
\name{estLODR}
\alias{estLODR}
\title{Estimate Limit of Detection of Ratios (LODR)}
\usage{
estLODR(exDat, kind = "ERCC", prob = 0.9)
}
\arguments{
\item{exDat}{list, contains input data and stores analysis results}

\item{kind}{"ERCC" or "Sim"}

\item{prob}{probability, ranging from 0 - 1, default is 0.9}
}
\description{
Estimate Limit of Detection of Ratios (LODR)
}
\details{
This is the function to estimate a limit of detection of ratios (LODR) for a
a chosen probability and threshold p-value for the fold changes in the ERCC
control ratio mixtures.
}
\examples{
data(SEQC.Example)

exDat <- initDat(datType="count", isNorm = FALSE, exTable=MET.CTL.countDat,
                 filenameRoot = "testRun",sample1Name = "MET",
                 sample2Name = "CTL", erccmix = "RatioPair",
                 erccdilution = 1/100, spikeVol = 1, totalRNAmass = 0.500,
                 choseFDR = 0.1)

exDat <- est_r_m(exDat)

exDat <- dynRangePlot(exDat)
\dontrun{
exDat <- geneExprTest(exDat)

exDat <- estLODR(exDat, kind = "ERCC", prob = 0.9)

exDat$Figures$lodrERCCPlot
}
}

