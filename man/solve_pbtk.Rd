\name{solve_pbtk}
\alias{solve_pbtk}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
   Solve_PBTK
}
\description{
This function solves for the amounts or concentrations in uM of a chemical in different tissues as functions of time based on the dose and dosing frequency.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
solve_pbtk(chem.name = NULL, chem.cas = NULL, times=NULL, parameters=NULL,
           days=10, tsteps = 4, daily.dose=1,dose = NULL,doses.per.day=NULL,
           initial.values=NULL,plots=F,suppress.messages=F,species="Human", 
           iv.dose=F,output.units='uM',method="lsoda",rtol=1e-8,atol=1e-12,
           default.to.human=F,recalc.blood2plasma=F,recalc.clearance=F,
           dosing.matrix=NULL,adjusted.Funbound.plasma=T,regression=T, 
           restrictive.clearance = T,...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{chem.name}{Either the chemical name, CAS number, or the parameters must be specified.}
  \item{chem.cas}{Either the chemical name, CAS number, or the parameters must be specified.}
  \item{times}{Optional time sequence for specified number of days.  Dosing sequence begins at the beginning of times.}
  \item{parameters}{Chemical parameters from parameterize_pbtk function, overrides chem.name and chem.cas.}
  \item{days}{Length of the simulation.}
   \item{tsteps}{The number time steps per hour.}
  \item{daily.dose}{Total daily dose, mg/kg BW.}
  \item{dose}{Amount of a single dose, mg/kg BW.  Overwrites daily.dose.}
  \item{doses.per.day}{Number of doses per day.}
  \item{initial.values}{Vector containing the initial concentrations or amounts of the chemical in specified tissues with units corresponding to output.units.  Defaults are zero.}
  \item{plots}{Plots all outputs if true.}
  \item{suppress.messages}{Whether or not the output message is suppressed.} 
  \item{species}{Species desired (either "Rat", "Rabbit", "Dog", "Mouse", or default "Human"). }
  \item{iv.dose}{Simulates a single i.v. dose if true.}
  \item{output.units}{Desired units (either "mg/L", "mg", "umol", or default "uM").}
  \item{method}{Method used by integrator (deSolve).}
  \item{rtol}{Argument passed to integrator (deSolve).}
  \item{atol}{Argument passed to integrator (deSolve).}
  \item{default.to.human}{
  Substitutes missing animal values with human values if true (hepatic intrinsic clearance or fraction of unbound plasma).
  }
  \item{recalc.blood2plasma}{Recalculates the ratio of the amount of chemical in the blood to plasma using the input parameters, calculated with hematocrit, Funbound.plasma, and Krbc2pu.} 
   \item{recalc.clearance}{Recalculates the the hepatic clearance (Clmetabolism) with new million.cells.per.gliver parameter.}
  \item{dosing.matrix}{Vector of dosing times or a matrix consisting of two columns or rows named "dose" and "time" containing the time and amount, in mg/kg BW, of each dose.}
 \item{adjusted.Funbound.plasma}{Uses adjusted Funbound.plasma when set to TRUE along with partition coefficients calculated with this value.}
  \item{regression}{Whether or not to use the regressions in calculating partition coefficients.}
 \item{restrictive.clearance}{Protein binding not taken into account (set to 1) in liver clearance if FALSE.}
  \item{...}{Additional arguments passed to the integrator.}
}

\details{
Note that the model parameters have units of hours while the model output is in days.

Default NULL value for doses.per.day solves for a single dose.

The compartments used in this model are the gutlumen, gut, liver, kidneys, veins, arteries, lungs, and the rest of the body.  

The extra compartments include the amounts or concentrations metabolized by the liver and excreted by the kidneys through the tubules.  

AUC is the area under the curve of the plasma concentration.

Model Figure
\if{html}{\figure{pbtk.png}{options: width="60\%" alt="Figure: PBTK Model Schematic"}}
 \if{latex}{\figure{pbtk.pdf}{options: width=12cm alt="Figure: PBTK Model Schematic"}}

%%When species is specified as rabbit, dog, or mouse, the function uses the appropriate physiological data(volumes and flows) but substitues human fraction unbound, partition coefficients, and intrinsic hepatic clearance. 

%%  ~~ If necessary, more details than the description above ~~
}
\value{
A matrix of class deSolve with a column for time(in days), each compartment, the area under the curve, and plasma concentration and a row for each time point.
     
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}

\author{
John Wambaugh and Robert Pearce
}

\references{
Pearce, Robert G., et al. "Httk: R package for high-throughput toxicokinetics." Journal of statistical software 79.4 (2017): 1.
}

\examples{

solve_pbtk(chem.name='Bisphenol-A',dose=.5,days=1,doses.per.day=2,tsteps=2)
out <- solve_pbtk(chem.name='bisphenola',dose=0,output.units='mg', 
                  plots=TRUE,initial.values=c(Agut=200))
params <- parameterize_pbtk(chem.cas="80-05-7")
solve_pbtk(parameters=params)
                  
\dontrun{
parameters <- parameterize_pbtk(chem.name = "triclosan", species = "rat")
parameters["Funbound.plasma"] <- 0.1
out <- solve_pbtk(parameters=parameters)

library("ggplot2")
out <- solve_pbtk(chem.name = "Bisphenol A", days = 50, doses.per.day = 3)
plot.data <- as.data.frame(out)
css <- calc_analytic_css(chem.name = "Bisphenol A")
c.vs.t <- ggplot(plot.data,aes(time, Cplasma)) + geom_line() +
geom_hline(yintercept = css) + ylab("Plasma Concentration (uM)") +
xlab("Day") + theme(axis.text = element_text(size = 16), axis.title =
element_text(size = 16), plot.title = element_text(size = 17)) +
ggtitle("Bisphenol A")
print(c.vs.t)
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{Solve}

