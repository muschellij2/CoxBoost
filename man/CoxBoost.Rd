\name{CoxBoost}
\alias{CoxBoost}
\title{Fit a Cox model by likelihood based boosting}
\description{
\code{CoxBoost} is used to fit a Cox proportional hazards model by componentwise likelihood based boosting.  
It is especially suited for models with a large number of predictors and allows for mandatory covariates with unpenalized parameter estimates.
}
\usage{
CoxBoost(time,status,x,unpen.index=NULL,standardize=TRUE,subset=1:length(time),
         weights=NULL,stepno=100,penalty=9*sum(status[subset]==1),
         criterion = c("pscore", "score","hpscore","hscore"),
         stepsize.factor=1,sf.scheme=c("sigmoid","linear"),pendistmat=NULL,
         connected.index=NULL,x.is.01=FALSE,return.score=TRUE,trace=FALSE) 
}
\arguments{
\item{time}{vector of length \code{n} specifying the observed times.}
\item{status}{censoring indicator, i.e., vector of length \code{n} with entries \code{0} for censored observations and \code{1} for uncensored observations. If this vector contains elements not equal to \code{0} or \code{1}, these are taken to indicate events from a competing risk and a model for the subdistribution hazard with respect to event \code{1} is fitted (see e.g. Fine and Gray, 1999; Binder et al. 2009a).}
\item{x}{\code{n * p} matrix of covariates.}
\item{unpen.index}{vector of length \code{p.unpen} with indices of mandatory covariates, where parameter estimation should be performed unpenalized.}
\item{standardize}{logical value indicating whether covariates should be standardized for estimation. This does not apply for mandatory covariates, i.e., these are not standardized.}
\item{subset}{a vector specifying a subset of observations to be used in the fitting process.}
\item{weights}{optional vector of length \code{n}, for specifying weights for the individual observations.}
\item{penalty}{penalty value for the update of an individual element of the parameter vector in each boosting step.}
\item{criterion}{indicates the criterion to be used for selection in each boosting step. \code{"pscore"} corresponds to the penalized score statistics, \code{"score"} to the un-penalized score statistics. Different results will only be seen for un-standardized covariates (\code{"pscore"} will result in preferential selection of covariates with larger covariance), or if different penalties are used for different covariates. \code{"hpscore"} and \code{"hscore"} correspond to \code{"pscore"} and \code{"score"}. However, a heuristic is used for evaluating only a subset of covariates in each boosting step, as described in Binder et al. (2011). This can considerably speed up computation, but may lead to different results.}
\item{stepsize.factor}{determines the step-size modification factor by which the natural step size of boosting steps should be changed after a covariate has been selected in a boosting step. The default (value \code{1}) implies constant penalties, for a value < 1 the penalty for a covariate is increased after it has been selected in a boosting step, and for a value > 1 the penalty it is decreased. If \code{pendistmat} is given, penalty updates are only performed for covariates that have at least one connection to another covariate.}
\item{sf.scheme}{scheme for changing step sizes (via \code{stepsize.factor}). \code{"linear"} corresponds to the scheme described in Binder and Schumacher (2009b), \code{"sigmoid"} employs a sigmoid shape.}
\item{pendistmat}{connection matrix with entries ranging between 0 and 1, with entry \code{(i,j)} indicating the certainty of the connection between covariates \code{i} and \code{j}. According to this information penalty changes due to \code{stepsize.factor} < 1 are propagated, i.e., if entry \code{(i,j)} is non-zero, the penalty for covariate \code{j} is decreased after it has been increased for covariate \code{i}, after it has been selected in a boosting step. This matrix either has to have dimension \code{(p - p.unpen) * (p - p.unpen)} or the indicices of the \code{p.connected} connected covariates have to be given in \code{connected.index}, in which case the matrix has to have dimension \code{p.connected * p.connected}. Generally, sparse matices from package \code{Matrix} can be used to save memory.}
\item{connected.index}{indices of the \code{p.connected} connected covariates, for which \code{pendistmat} provides the connection information for distributing changes in penalties. No overlap with \code{unpen.index} is allowed. If \code{NULL}, and a connection matrix is given, all covariates are assumed to be connected.}
\item{stepno}{number of boosting steps (\code{m}).}
\item{x.is.01}{logical value indicating whether (the non-mandatory part of) \code{x} contains just values 0 and 1, i.e., binary covariates. If this is the case and indicated by this argument, computations are much faster.}
\item{return.score}{logical value indicating whether the value of the score statistic (or penalized score statistic, depending on \code{criterion}), as evaluated in each boosting step for every covariate, should be returned. The corresponding element \code{scoremat} can become very large (and needs much memory) when the number of covariates and boosting steps is large.}
\item{trace}{logical value indicating whether progress in estimation should be indicated by printing the name of the covariate updated.}
}
\details{
In contrast to gradient boosting (implemented e.g. in the \code{glmboost} routine in the R package \code{mboost}, using the \code{CoxPH} loss function), \code{CoxBoost} is not based on gradients of loss functions, but adapts the offset-based boosting approach from Tutz and Binder (2007) for estimating Cox proportional hazards models. In each boosting step the previous boosting steps are incorporated as an offset in penalized partial likelihood estimation, which is employed for obtain an update for one single parameter, i.e., one covariate, in every boosting step. This results in sparse fits similar to Lasso-like approaches, with many estimated coefficients being zero. The main model complexity parameter, which has to be selected (e.g. by cross-validation using \code{\link{cv.CoxBoost}}), is the number of boosting steps \code{stepno}. The penalty parameter \code{penalty} can be chosen rather coarsely, either by hand or using \code{\link{optimCoxBoostPenalty}}.

The advantage of the offset-based approach compared to gradient boosting is that the penalty structure is very flexible. In the present implementation this is used for allowing for unpenalized mandatory covariates, which receive a very fast coefficient build-up in the course of the boosting steps, while the other (optional) covariates are subjected to penalization.
For example in a microarray setting, the (many) microarray features would be taken to be optional covariates, and the (few) potential clinical covariates would be taken to be mandatory, by including their indices in \code{unpen.index}.  

If a group of correlated covariates has influence on the response, e.g. genes from the same pathway, componentwise boosting will often result in a non-zero estimate for only one member of this group. To avoid this, information on the connection between covariates can be provided in \code{pendistmat}. If then, in addition, a penalty updating scheme with \code{stepsize.factor} < 1 is chosen, connected covariates are more likely to be chosen in future boosting steps, if a directly connected covariate has been chosen in an earlier boosting step (see Binder and Schumacher, 2009b).
}
\value{
\code{CoxBoost} returns an object of class \code{CoxBoost}.  

\item{n, p}{number of observations and number of covariates.}
\item{stepno}{number of boosting steps.}
\item{xnames}{vector of length \code{p} containing the names of the covariates. This information is extracted from \code{x} or names following the scheme \code{V1, V2, ...}} are used.
\item{coefficients}{\code{(stepno+1) * p} matrix containing the coefficient estimates for the (standardized) optional covariates for boosting steps \code{0} to \code{stepno}. This will typically be a sparse matrix, built using package \code{\link{Matrix}}}.
\item{scoremat}{\code{stepno * p} matrix containing the value of the score statistic for each of the optional covariates before each boosting step.}
\item{meanx, sdx}{vector of mean values and standard deviations used for standardizing the covariates.}
\item{unpen.index}{indices of the mandatory covariates in the original covariate matrix \code{x}.}
\item{penalty}{If \code{stepsize.factor != 1}, \code{stepno * (p - p.unpen)} matrix containing the penalties used for every boosting step and every penalized covariate, otherwise a vector containing the unchanged values of the penalty employed in each boosting step.}
\item{time}{observed times given in the \code{CoxBoost} call.}
\item{status}{censoring indicator given in the \code{CoxBoost} call.}
\item{event.times}{vector with event times from the data given in the \code{CoxBoost} call.}
\item{linear.predictors}{\code{(stepno+1) * n} matrix giving the linear predictor for boosting steps \code{0} to \code{stepno} and every observation.}
\item{Lambda}{matrix with the Breslow estimate for the cumulative baseline hazard for boosting steps \code{0} to \code{stepno} for every event time.}
\item{logplik}{partial log-likelihood of the fitted model in the final boosting step.}
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
\code{\link{predict.CoxBoost}}, \code{\link{cv.CoxBoost}}.
}
\examples{
#   Generate some survival data with 10 informative covariates 
n <- 200; p <- 100
beta <- c(rep(1,10),rep(0,p-10))
x <- matrix(rnorm(n*p),n,p)
real.time <- -(log(runif(n)))/(10*exp(drop(x \%*\% beta)))
cens.time <- rexp(n,rate=1/10)
status <- ifelse(real.time <= cens.time,1,0)
obs.time <- ifelse(real.time <= cens.time,real.time,cens.time)

#   Fit a Cox proportional hazards model by CoxBoost

cbfit <- CoxBoost(time=obs.time,status=status,x=x,stepno=100,penalty=100) 
summary(cbfit)

#   ... with covariates 1 and 2 being mandatory

cbfit.mand <- CoxBoost(time=obs.time,status=status,x=x,unpen.index=c(1,2),
                       stepno=100,penalty=100) 
summary(cbfit.mand)


}
\keyword{models} \keyword{regression} \keyword{survial}
