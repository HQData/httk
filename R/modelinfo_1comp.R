#Define the parameter names for each model in one place so that all functions can use them:
param.names.1comp <- c("BW",
                     "Clint",
                     "Fgutabs",
                     "Fhep.assay.correction",
                     "Funbound.plasma",
                     "Funbound.plasma.adjustment",
                     "hepatic.bioavailability",
                     "hematocrit",
                     "kelim",
                     "kgutabs",
                     "liver.density",
                     "million.cells.per.gliver",
                     "MA",
                     "MW",
                     "Rblood2plasma",
                     "Pow",
                     "pKa_Donor",
                     "pKa_Accept",
                     "Vdist")

param.names.1comp.solver <- c("vdist",
                     "ke",
                     "kgutabs")

initparms1comp <- function(newParms = NULL){
  parms <- c(
    vdist = 0,
    ke = 0,
    kgutabs = 1
  )
  if (!is.null(newParms)) {
    if (!all(names(newParms) %in% c(names(parms)))) {
      stop("illegal parameter name")
    }
  }
  if (!is.null(newParms)) parms[names(newParms)] <- newParms
  out <- .C("getParms_1comp",
   as.double(parms),
  out=double(length(parms)),
  as.integer(length(parms)))$out
  names(out) <- names(parms)
  out
}

Outputs1comp <- c(
    "Ccompartment"
)


initState1comp <- function(parms, newState = NULL) {
  Y <- c(
    Agutlumen = 0.0,
    Acompartment = 0.0,
    Ametabolized = 0.0,
    AUC = 0.0
  )
  Y <- with(as.list(parms), {  Y
  })

  if (!is.null(newState)) {
    if (!all(names(newState) %in% c(names(Y)))) {
      stop("illegal state variable name in newState")
    }
    Y[names(newState)] <- newState
  }
  Y
}
