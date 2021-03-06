% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/armitage.R
\name{armitage_eval}
\alias{armitage_eval}
\title{Evaluate the updated Armitage model}
\usage{
armitage_eval(tcdata = NA, this.casrn, this.ac50 = 10, this.MP = NA,
  this.gkow = NA, this.gkaw = NA, this.gswat = NA, this.sarea = NA,
  this.v_total = NA, this.v_working = NA, this.cell_yield = NA,
  this.Tsys = 37, this.Tref = 298.15, this.option.kbsa2 = F,
  this.option.swat2 = F, this.FBSf = 0, this.pseudooct = 0.01,
  this.memblip = 0.04, this.nlom = 0.2, this.P_nlom = 0.035,
  this.P_dom = 0.05, this.P_cells = 1, this.csalt = 0.15,
  this.celldensity = 1, this.cellmass = 3, this.f_oc = 1)
}
\arguments{
\item{tcdata}{A data.table with casrn, ac50, MP, gkow, gkaw, gswat, sarea, v_total, v_working. Otherwise supply single values to this.params.}

\item{this.casrn}{For single value, CAS number}

\item{this.ac50}{For single value, AC50 (micromolar) nominal concentration}

\item{this.MP}{For single value, melting point (oC)}

\item{this.gkow}{For single value, Log10 Kow, octanol-water partitioning coefficient}

\item{this.gkaw}{For single value, Log10 Kaw, air-water partitioning coefficient}

\item{this.gswat}{For single value, Log10 water solubility (mol/L)}

\item{this.sarea}{For single value, surface area per well (m^2)}

\item{this.v_total}{For single value, Total volume per well (m^3)}

\item{this.v_working}{For single value, Working volume per well (m^3)}

\item{this.cell_yield}{For single value, Number of cells per well}

\item{this.Tsys}{System temperature (oC)}

\item{this.Tref}{Reference temperature (K)}

\item{this.option.kbsa2}{Use alternative bovine-serum-albumin partitioning model}

\item{this.option.swat2}{Use alternative water solubility correction}

\item{this.FBSf}{Fraction fetal bovine serum}

\item{this.pseudooct}{Pseudo-octanol cell storage lipid content}

\item{this.memblip}{Membrane lipid content of cells}

\item{this.nlom}{Structural protein conent of cells}

\item{this.P_nlom}{Proportionality constant to octanol structural protein}

\item{this.P_dom}{Proportionality constant to octnaol dom}

\item{this.P_cells}{Proportionality constant to octanol storage lipid}

\item{this.csalt}{Ionic strength of buffer, mol/L}

\item{this.celldensity}{Cell density kg/L, g/mL}

\item{this.cellmass}{Mass per cell, ng/cell}

\item{this.f_oc}{1, everything assumed to be like proteins}
}
\value{
tcdata
}
\description{
Evaluate the Armitage model for chemical distributon in vitro.
Takes input as data table or single set of values. Outputs a data table.
Updates over the model published in Armitage et al. 2014 include binding to plastic walls and lipid and protein compartments in cells.
}
\references{
Armitage, J. M.; Wania, F.; Arnot, J. A. Environ. Sci. Technol. 2014, 48, 9770-9779. dx.doi.org/10.1021/es501955g

Honda et al. (submitted) "Using the Concordance of In Vitro and 
In Vivo Data to Evaluate Extrapolation Assumptions"
}
\author{
Greg Honda
}
