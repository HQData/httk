\name{parameterize_pbtk}
\alias{parameterize_pbtk}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
   Parameterize_PBTK
}
\description{
This function initializes the parameters needed in the functions solve_pbtk, calc_css, and others using the multiple compartment model.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
 parameterize_pbtk(chem.cas=NULL,chem.name=NULL,species="Human",default.to.human=F,
 tissuelist=list(liver=c("liver"),kidney=c("kidney"),lung=c("lung"),gut=c("gut")),
 force.human.clint.fub = F,clint.pvalue.threshold=0.05,fu.hep.correct=TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{chem.name}{
   Either the chemical name or the CAS number must be specified.
%%     ~~Describe \code{obs} here~~
}
  \item{chem.cas}{
   Either the chemical name or the CAS number must be specified.
%%     ~~Describe \code{pred} here~~
}
  \item{species}{
    Species desired (either "Rat", "Rabbit", "Dog", "Mouse", or default "Human"). 
}
  \item{default.to.human}{
  Substitutes missing animal values with human values if true (hepatic intrinsic clearance or fraction of unbound plasma).
  }
  \item{tissuelist}{
    Specifies which tissues will be used in the model and groups any others in the rest of the body.  However, solve_pbtk only works with the default parameters.
  }
  \item{force.human.clint.fub}{
  Forces use of human values for hepatic intrinsic clearance and fraction of unbound plasma if true.
 }
 \item{clint.pvalue.threshold}{Hepatic clearances with clearance assays having p-values greater than the threshold are set to zero.}
 \item{fu.hep.correct}{Whether or not to correct the in vitro measured hepatic clearance for the fraction of chemical predicted to bind to hepatocytes using the method of Kilford et al. (2008) (defaults to TRUE).}
}

\details{
When species is specified as rabbit, dog, or mouse, the function uses the appropriate physiological data(volumes and flows) but substitues human fraction unbound, partition coefficients, and intrinsic hepatic clearance. 
%%  ~~ If necessary, more details than the description above ~~
}
\value{

  \item{BW}{Body Weight, kg.}
    \item{CLmetabolismc}{Hepatic Clearance, L/h/kg BW.}
    \item{Fraction_unbound_plasma}{Fraction of plasma that is not bound.}
    \item{hematocrit}{Percent volume of red blood cells in the blood.}
    \item{kdermabs}{Rate that chemical is transferred from the skin to the blood, 1/h.}
    \item{Kgut2plasma}{Ratio of concentration of chemical in gut tissue to unbound concentration in plasma.}
    \item{kgutabs}{Rate that chemical enters the gut from gutlumen, 1/h.}
     \item{kinhabs}{Rate that the chemical is transferred from the lungs to the blood, 1/h.}
     \item{Kkidney2plasma}{Ratio of concentration of chemical in kidney tissue to unbound concentration in plasma.}
     \item{Kliver2plasma}{Ratio of concentration of chemical in liver tissue to unbound concentration in plasma.}
      \item{Klung2plasma}{Ratio of concentration of chemical in lung tissue to unbound concentration in plasma.}
       \item{Krbc2plasma}{Ratio of concentration of chemical in red blood cells to unbound concentration in plasma.}
     \item{Krest2plasma}{Ratio of concentration of chemical in rest of body tissue to unbound concentration in plasma.}
    \item{MW}{Molecular Weight, g/mol.}
    \item{Qcardiacc}{Cardiac Output, L/h/kg BW^3/4.}
     \item{Qgfrc}{Glomerular Filtration Rate, L/h/kg BW^3/4, volume of fluid filtered from kidney and excreted.}
     \item{Qgutf}{Fraction of cardiac output flowing to the gut.}
     \item{Qkidneyf}{Fraction of cardiac output flowing to the kidneys.}
     \item{Qliverf}{Fraction of cardiac output flowing to the liver.}
      \item{Qlungf}{Fraction of cardiac output flowing to the lungs, not used in current model.  Entire cardiac output actually flows through the lung compartment.}
      \item{Ratioblood2plasma}{The ratio of the concentration of the chemical in the blood to the concentration in the plasma.}
     \item{Vartc}{Volume of the arteries per kg body weight, L/kg BW.}
      \item{Vgutc}{Volume of the gut per kg body weight, L/kg BW.}
      \item{Vkidneyc}{Volume of the kidneys per kg body weight, L/kg BW.}
      \item{Vliverc}{Volume of the liver per kg body weight, L/kg BW.}   
      \item{Vlungc}{Volume of the lungs per kg body weight, L/kg BW.}   
      \item{Vrestc}{ Volume of the rest of the body per kg body weight, L/kg BW.}
       \item{Vvenc}{Volume of the veins per kg body weight, L/kg BW.}
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
Kilford, P. J., Gertz, M., Houston, J. B. and Galetin, A. (2008). Hepatocellular binding of drugs: correction for unbound fraction in hepatocyte incubations using microsomal binding or drug lipophilicity data. Drug Metabolism and Disposition 36(7), 1194-7, 10.1124/dmd.108.020834.
}


\examples{

 parameters <- parameterize_pbtk(chem.cas='80-05-7')

 parameters <- parameterize_pbtk(chem.name='Bisphenol-A',species='Rat')

 # Change the tissue lumping (note, these model parameters will not work with our current solver):
 compartments <- list(liver=c("liver"),fast=c("heart","brain","muscle","kidney"),
                      lung=c("lung"),gut=c("gut"),slow=c("bone"))
 parameterize_pbtk(chem.name="Bisphenol a",species="Rat",default.to.human=TRUE,
                   tissuelist=compartments) 
 
 
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line