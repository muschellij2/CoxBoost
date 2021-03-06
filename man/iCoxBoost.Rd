\name{iCoxBoost}
\alias{iCoxBoost}
\title{Interface for cross-validation and model fitting using a formula description}
\description{
Formula interface for fitting a Cox proportional hazards model by componentwise likelihood based boosting (via a call to \code{\link{CoxBoost}}), where cross-validation can be performed automatically for determining the number of boosting steps (via a call to \code{\link{cv.CoxBoost}}).  
}
\usage{
iCoxBoost(formula,data=NULL,weights=NULL,subset=NULL,mandatory=NULL,
		  cause=1,standardize=TRUE,stepno=200,
		  criterion=c("pscore","score","hpscore","hscore"),
		  nu=0.1,stepsize.factor=1,varlink=NULL,
		  cv=cvcb.control(),trace=FALSE,...) 
}
\arguments{
\item{formula}{A formula describing the model to be fitted, similar to a call to \code{coxph}. The response must be a survival object, either as returned by \code{Surv} or \code{Hist} (in a competing risks application).}
\item{data}{data frame containing the variables described in the formula.}
\item{weights}{optional vector, for specifying weights for the individual observations.}
\item{subset}{a vector specifying a subset of observations to be used in the fitting process.}
\item{mandatory}{vector containing the names of the covariates whose effect is to be estimated un-regularized.}
\item{cause}{cause of interest in a competing risks setting, when the response is specified by \code{Hist} (see e.g. Fine and Gray, 1999; Binder et al. 2009a).}
\item{standardize}{logical value indicating whether covariates should be standardized for estimation. This does not apply for mandatory covariates, i.e., these are not standardized.}
\item{stepno}{maximum number of boosting steps to be evaluated when determining the number of boosting steps by cross-validation, otherwise the number of boosting seps itself.}
\item{criterion}{indicates the criterion to be used for selection in each boosting step. \code{"pscore"} corresponds to the penalized score statistics, \code{"score"} to the un-penalized score statistics. Different results will only be seen for un-standardized covariates (\code{"pscore"} will result in preferential selection of covariates with larger covariance), or if different penalties are used for different covariates. \code{"hpscore"} and \code{"hscore"} correspond to \code{"pscore"} and \code{"score"}. However, a heuristic is used for evaluating only a subset of covariates in each boosting step, as described in Binder et al. (2011). This can considerably speed up computation, but may lead to different results.}
\item{nu}{(roughly) the fraction of the partial maximum likelihood estimate used for the update in each boosting step. This is converted into a penalty for the call to \code{CoxBoost}. Use smaller values, e.g., 0.01 when there is little information in the data, and larger values, such as 0.1, with much information or when the number of events is larger than the number of covariates. Note that the default for direct calls to \code{CoxBoost} corresponds to \code{nu=0.1}.}
\item{stepsize.factor}{determines the step-size modification factor by which the natural step size of boosting steps should be changed after a covariate has been selected in a boosting step. The default (value \code{1}) implies constant \code{nu}, for a value < 1 the value \code{nu} for a covariate is decreased after it has been selected in a boosting step, and for a value > 1 the value \code{nu} is increased. If \code{pendistmat} is given, updates of \code{nu} are only performed for covariates that have at least one connection to another covariate.}
\item{varlink}{list for specifying links between covariates, used to re-distribute step sizes when \code{stepsize.factor != 1}. The list needs to contain at least two vectors, the first containing the name of the source covariates, the second containing the names of the corresponding target covariates, and a third (optional) vector containing weights between 0 and 1 (defaulting to 1). If \code{nu} is increased/descreased for one of the source covariates according to \code{stepsize.factor}, the \code{nu} for the corresponding target covariate is descreased/increased accordingly (multiplied by the weight). If \code{formula} contains interaction terms, als rules for these can be set up, using variable names such as \code{V1:V2} for the interaction term between covariates \code{V1} and \code{V2}.}
\item{cv}{\code{TRUE}, for performing cross-validation, with default parameters, \code{FALSE} for not performing cross-validation, or list containing the parameters for cross-validation, as obtained from a call to \code{\link{cvcb.control}}.}
\item{trace}{logical value indicating whether progress in estimation should be indicated by printing the name of the covariate updated.}
\item{...}{miscellaneous arguments, passed to the call to \code{\link{cv.CoxBoost}}.}
}

\details{
In contrast to gradient boosting (implemented e.g. in the \code{glmboost} routine in the R package \code{mboost}, using the \code{CoxPH} loss function), \code{CoxBoost} is not based on gradients of loss functions, but adapts the offset-based boosting approach from Tutz and Binder (2007) for estimating Cox proportional hazards models. In each boosting step the previous boosting steps are incorporated as an offset in penalized partial likelihood estimation, which is employed for obtain an update for one single parameter, i.e., one covariate, in every boosting step. This results in sparse fits similar to Lasso-like approaches, with many estimated coefficients being zero. The main model complexity parameter, the number of boosting steps, is automatically selected by cross-validation using a call to \code{\link{cv.CoxBoost}}). Note that this will introduce random variation when repeatedly calling \code{iCoxBoost}, i.e. it is advised to set/save the random number generator state for reproducible results.

The advantage of the offset-based approach compared to gradient boosting is that the penalty structure is very flexible. In the present implementation this is used for allowing for unpenalized mandatory covariates, which receive a very fast coefficient build-up in the course of the boosting steps, while the other (optional) covariates are subjected to penalization.
For example in a microarray setting, the (many) microarray features would be taken to be optional covariates, and the (few) potential clinical covariates would be taken to be mandatory, by including their names in \code{mandatory}.  

If a group of correlated covariates has influence on the response, e.g. genes from the same pathway, componentwise boosting will often result in a non-zero estimate for only one member of this group. To avoid this, information on the connection between covariates can be provided in \code{varlink}. If then, in addition, a penalty updating scheme with \code{stepsize.factor} < 1 is chosen, connected covariates are more likely to be chosen in future boosting steps, if a directly connected covariate has been chosen in an earlier boosting step (see Binder and Schumacher, 2009b).
}
\value{
\code{iCoxBoost} returns an object of class \code{iCoxBoost}, which also has class \code{CoxBoost}. In addition to the elements from \code{\link{CoxBoost}} it has the following elements:
\item{call, formula, terms}{call, formula and terms from the formula interface.}
\item{cause}{cause of interest.}
\item{cv.res}{result from \code{\link{cv.CoxBoost}}, if cross-validation has been performed.}
}
\author{
Written by Harald Binder \email{binderh@uni-mainz.de}. 
}
\references{
Binder, H., Benner, A., Bullinger, L., and Schumacher, M. (2013). Tailoring sparse multivariable regression techniques for prognostic single-nucleotide polymorphism signatures. Statistics in Medicine, doi: 10.1002/sim.5490.

Binder, H., Allignol, A., Schumacher, M., and Beyersmann, J. (2009). Boosting for high-dimensional time-to-event data with competing risks. Bioinformatics, 25:890-896.

Binder, H. and Schumacher, M. (2009). Incorporating pathway information into boosting estimation of high-dimensional risk prediction models. BMC Bioinformatics. 10:18.

Binder, H. and Schumacher, M. (2008). Allowing for mandatory covariates in boosting estimation of sparse high-dimensional survival models. BMC Bioinformatics. 9:14.

Tutz, G. and Binder, H. (2007) Boosting ridge regression. Computational Statistics \& Data Analysis, 51(12):6044-6059.

Fine, J. P. and Gray, R. J. (1999). A proportional hazards model for the subdistribution of a competing risk. Journal of the American Statistical Association. 94:496-509.
}
\seealso{
\code{\link{predict.iCoxBoost}}, \code{\link{CoxBoost}}, \code{\link{cv.CoxBoost}}.
}
\examples{
#   Generate some survival data with 10 informative covariates 
n <- 200; p <- 100
beta <- c(rep(1,2),rep(0,p-2))
x <- matrix(rnorm(n*p),n,p)
actual.data <- as.data.frame(x)
real.time <- -(log(runif(n)))/(10*exp(drop(x \%*\% beta)))
cens.time <- rexp(n,rate=1/10)
actual.data$status <- ifelse(real.time <= cens.time,1,0)
actual.data$time <- ifelse(real.time <= cens.time,real.time,cens.time)

#   Fit a Cox proportional hazards model by iCoxBoost

\donttest{cbfit <- iCoxBoost(Surv(time,status) ~ .,data=actual.data)
summary(cbfit)
plot(cbfit)}

#   ... with covariates 1 and 2 being mandatory

\donttest{cbfit.mand <- iCoxBoost(Surv(time,status) ~ .,data=actual.data,mandatory=c("V1"))
summary(cbfit.mand)
plot(cbfit.mand)}


}
\keyword{models} \keyword{regression} \keyword{survial}
