\name{calc_elimination_rate}
\alias{calc_elimination_rate}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Calculate the elimination rate for a one compartment model.
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
This function calculates an elimination rate from the three compartment steady state model where 
elimination is entirely due to metablism by the liver and glomerular filtration in the kidneys.
}
\usage{
calc_elimination_rate(chem.cas=NULL,chem.name=NULL,parameters=NULL,
                      species="Human",suppress.messages=F,default.to.human=F,
                      restrictive.clearance=T,adjusted.Funbound.plasma=T,
                      regression=T,well.stirred.correction=T, 
                      clint.pvalue.threshold = 0.05)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{chem.name}{
  Either the chemical name or the cas number must be specified.
%%     ~~Describe \code{obs} here~~
}
  \item{chem.cas}{
  Either the cas number or the chemical name must be specified.
%%     ~~Describe \code{pred} here~~
}
\item{parameters}{Chemical parameters from parameterize_steadystate or 1compartment function, overrides chem.name and chem.cas.}
  \item{species}{
 Species desired (either "Rat", "Rabbit", "Dog", "Mouse", or default "Human").}
 
 \item{suppress.messages}{Whether or not the output message is suppressed.} 
 
   \item{default.to.human}{
  Substitutes missing animal values with human values if true.
  }
 \item{adjusted.Funbound.plasma}{Uses adjusted Funbound.plasma when set to TRUE along with partition coefficients calculated with this value.}
  \item{regression}{Whether or not to use the regressions in calculating partition coefficients.}
 \item{restrictive.clearance}{In calculating elimination rate, protein binding is not taken into account (set to 1) in liver clearance if FALSE.}
  \item{well.stirred.correction}{Uses correction in calculation of hepatic clearance for well-stirred model if TRUE.  
                                  This assumes clearance relative to amount unbound in whole blood instead of plasma, but converted to use with plasma concentration.}
  \item{clint.pvalue.threshold}{Hepatic clearance for chemicals where the in vitro clearance assay result has a p-values greater than the threshold are set to zero.}


}
\details{
Elimination rate calculated by dividing the total clearance (using the default well-stirred hepatic model) by the volume of distribution.
%%When species is specified as rabbit, dog, or mouse, the function uses the appropriate physiological data(volumes and flows) but substitues human fraction unbound, partition coefficients, and intrinsic hepatic clearance. 

%%  ~~ If necessary, more details than the description above ~~
}
\value{
\item{Elimination rate}{Units of 1/h.}
}

\author{
John Wambaugh
}


%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
calc_elimination_rate(chem.name="Bisphenol A")
calc_elimination_rate(chem.name="Bisphenol A",species="Rat")
calc_elimination_rate(chem.cas="80-05-7")
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{Parameter}