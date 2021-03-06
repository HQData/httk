\name{calc_mc_oral_equiv}
\alias{calc_mc_oral_equiv}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Calculate Monte Carlo Oral Equivalent Dose
}
\description{
This functions converts a chemical plasma concetration to an oral equivalent dose using a concentration obtained from calc_mc_css. 
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
calc_mc_oral_equiv(conc,chem.name=NULL,
                   chem.cas=NULL,
                   which.quantile=0.95,
                   species="Human",
                   input.units='uM',
                   output.units='mg',
                   suppress.messages=F,
                   return.samples=F,
                   restrictive.clearance=T,
                   plasma.binding = F, 
                   tk.statistic.used="mean", 
                   tissue=NULL,
                   IVIVE = NULL,
                   ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{conc}{
  Bioactive in vitro concentration in units of uM.
%%     ~~Describe \code{ssparams.i} here~~
}
  \item{chem.name}{
  Either the chemical name or the CAS number must be specified.
%%     ~~Describe \code{obs} here~~
}
  \item{chem.cas}{
  Either the CAS number or the chemical name must be specified.
%%     ~~Describe \code{pred} here~~
}
  \item{suppress.messages}{
  Suppress text messages.
%%     ~~Describe \code{sds} here~~
}
  \item{input.units}{Units of given concentration, default of uM but can also be mg/L.}
  \item{output.units}{Units of dose, default of 'mg' for mg/kg BW/ day or 'mol' for mol/ kg BW/ day.}
  \item{which.quantile}{
  Which quantile from Monte Carlo steady-state simulation (calc_mc_css) is requested. Can be a vector. Note that 95th concentration quantile is the same population as the 5th dose quantile.
%%     ~~Describe \code{ssparams.mean} here~~
}
 \item{species}{
   Species desired (either "Rat", "Rabbit", "Dog", "Mouse", or default "Human"). 
%%     ~~Describe \code{ssparams.var.inv} here~~
}
 \item{return.samples}{Whether or not to return the vector containing the samples from the simulation instead of the selected quantile.}
 \item{restrictive.clearance}{Protein binding not taken into account (set to 1) in liver clearance if FALSE.}
 \item{plasma.binding}{If TRUE, then only the free (unbound) fraction of chemical is considered to be bioactive. If FALSE, the total chemical concentration is used for IVIVE. (Default TRUE)}
 \item{tk.statistic.used}{Theoreticially either the "mean" or "max"imum (peak) concetrations might be used for IVIVE with some models. Defaults to "mean". Meaningless for the steady-state model (Argument is currently ignored because analytic steady-state solutions are used by this function.).}
 \item{tissue}{Desired steady state tissue conentration.}
 \item{IVIVE}{Honda et al. (submitted) identified six plausible sets of assumptions for \emph{in vitro-in vivo} extrapolation (IVIVE) assumptions. Argument may be set to "Honda1" through "Honda6". If used, this function overwrites the tissue, restrictive.clearance, and plasma.binding arguments. See Details below for more information.}

  \item{...}{Additional parameters passed to calc_mc_css for httkpop and variance of parameters.}
}

\value{

Equivalent dose in specified units, default of mg/kg BW/day.
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}

\details{
All arguments after httkpop only apply if httkpop is set to TRUE and species to "Human".

When species is specified as rabbit, dog, or mouse, the function uses the appropriate physiological data(volumes and flows) but substitues human fraction unbound, partition coefficients, and intrinsic hepatic clearance. 

Tissue concentrations are calculated for the pbtk model with oral infusion dosing.  All tissues other than gut, liver, and lung are the product of the steady state plasma concentration and the tissue to plasma partition coefficient.

The six sets of plausible \emph{in vitro-in vivo} extrpolation (IVIVE) assumptions identified by Honda et al. (submitted) are:
\tabular{lrrrr}{
 \tab \emph{in vivo} Conc. \tab Metabolic Clearance \tab Bioactive Chemical Conc. \tab TK Statistic Used* \cr
Honda1 \tab Veinous (Plasma) \tab Restrictive \tab Free \tab Mean Conc. \cr
Honda2 \tab Veinous \tab Restrictive \tab Free \tab Max Conc. \cr
Honda3 \tab Veinous \tab Non-restrictive \tab Total \tab Mean Conc. \cr
Honda4 \tab Veinous \tab Non-restrictive \tab Total \tab Max Conc. \cr
Honda5 \tab Target Tissue \tab Non-restrictive \tab Total \tab Mean Conc. \cr
Honda6 \tab Target Tissue \tab Non-restrictive \tab Total \tab Max Conc. \cr
}
*Assumption is currently ignored because analytical steady-state solutions are currently used by this function.
}

\author{
John Wambaugh
}

\examples{

\dontrun{
calc_mc_oral_equiv(0.1,chem.cas="34256-82-1",which.quantile=c(0.05,0.5,0.95),
                   method='vi',samples=100,tissue='brain')
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{Steady State}
\keyword{Monte Carlo}% __ONLY ONE__ keyword per line
