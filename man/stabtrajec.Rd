\name{stabtrajec}
\alias{stabtrajec}
\title{Plots stability trajectories from resCoxBoost fits}
\description{
Plots the stability trajectories, i.e. the variable selection stability is plotted in form of resampling inclusion frequencies for different weights and a selection of different stably selected genes as obtained from a resCoxBoost object fitted by \code{\link{resCoxBoost}}.
}
\usage{
stabtrajec<-function(RIF,mix.list=c(0.001,0.01, 0.05, 0.1, 0.25, 0.35, 0.5, 0.7, 0.9, 0.99),
                     plotmix=c(0.001,0.01, 0.05, 0.1, 0.25, 0.35, 0.5, 0.7, 0.9, 0.99),
                     my.colors=gray(seq(.99,0,len=10)),yupperlim=1,huge=0.6,lowerRIFlimit=0.6,legendval=4.5)
}
\arguments{
\item{RIF}{list obtained from a \code{\link{resample.CoxBoost}} call.}
\item{mix.list}{vector of weights which were also entered in the \code{\link{resample.CoxBoost}} call.}
\item{plotmix}{vector of weights which should be plotted in the stability trajectory plot.}
\item{my.colors}{vector with length(plotmix) of different colors for plotting the different weights, default are gray shades.}
\item{yupperlim}{value for the upper y coordinate.}
\item{huge}{size of the labels plottet on the x-axis.}
\item{lowerRIFlimit}{cutoff RIF value: All covariates which have an resampling inclusion frequency (RIF) greater or equal this lowerRIFlimit value at any weight are presented in the stability trajectory plot.}
\item{legendval}{space between the last plotted covariate and the legend on the right side of the plot.}
}

\details{The \code{stabtrajec} function produces a visualization tool (stability trajectory plot), which shows the RIFs as a function of weights for stably selected covariates selected via \code{resample.CoxBoost}. With this tool it can be shown that with weights between zero and one and so the additional information from the observations of the not analyzed subgroup in comparison to the standard subgroup analysis (weight near zero) can improve the variable selection stability. The number of plotted covariates in this plot depends on \code{lowerRIFlimit}. How many weights are plotted which are element of \code{mix.list} can be changed with \code{plotmix}.
}

\value{
No value is returned, but the stability trajectory plot is generated.
}
\author{
Veronika Weyer \email{weyer@uni-mainz.de} and Harald Binder \email{binderh@uni-mainz.de}
}
