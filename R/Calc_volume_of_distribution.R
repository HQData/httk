# This function predicts partition coefficients for all tissues, then lumps them into a single compartment. The effective volume of distribution is calculated by summing each tissues volume times it's partition coefficient relative to plasma. Plasma, and the paritioning into RBCs are also added to get the total volume of distribution in L/KG BW.
calc_vdist<- function(chem.cas=NULL,
                      chem.name=NULL,
                      parameters=NULL,
                      default.to.human=F,
                      species="Human",
                      suppress.messages=F,
                      adjusted.Funbound.plasma=T,
                      regression=T)
{
  physiology.data <- physiology.data
  Parameter <- NULL

  if (is.null(parameters))
  {
    schmitt.parameters <- parameterize_schmitt(chem.cas=chem.cas,chem.name=chem.name,default.to.human=default.to.human,species=species)
    parameters <- suppressWarnings(predict_partitioning_schmitt(parameters=schmitt.parameters,species=species,regression=regression,adjusted.Funbound.plasma=adjusted.Funbound.plasma))
    if (adjusted.Funbound.plasma) parameters <- c(parameters,schmitt.parameters['Funbound.plasma'])
    else parameters <- c(parameters,Funbound.plasma=schmitt.parameters[['unadjusted.Funbound.plasma']])
  }

  if(any(names(parameters) %in% schmitt.specific.names) & !all(c(schmitt.names) %in% names(parameters))) stop("All predict_partitioning_schmitt coefficients must be included if not using pbtk or 3compartment parameters.")              
  else if(all(schmitt.names %in% names(parameters))) schmitt.params  <- T
  else schmitt.params <- F                                                                                           

  if(schmitt.params & !('funbound.plasma' %in% tolower(names(parameters))))
  {
    if(is.null(chem.cas) & is.null(chem.name))stop("Specify chem.name or chem.cas with correct species if not including Funbound.plasma with predict_partitioning_schmitt coefficients.")
    else if(is.null(chem.cas))
    {
      out <- get_chem_id(chem.cas=chem.cas,chem.name=chem.name)
      chem.cas <- out$chem.cas
    }
    fub <- try(get_invitroPK_param("Funbound.plasma",species,chem.CAS=chem.cas),silent=T)
    if (class(fub) == "try-error" & default.to.human) 
    {
      fub <- try(get_invitroPK_param("Funbound.plasma","Human",chem.CAS=chem.cas),silent=T)
      warning(paste(species,"coerced to Human for protein binding data."))
    }
    if (class(fub) == "try-error") stop("Missing protein binding data for given species. Set default.to.human to true to substitute human value.")
    if (fub == 0)
    {
      fub <- 0.005
      warning("Fraction unbound = 0, changed to 0.005.")
    }
    if(adjusted.Funbound.plasma){
      Flipid <- subset(physiology.data,Parameter=='Plasma Effective Neutral Lipid Volume Fraction')[,which(tolower(colnames(physiology.data)) == tolower(species))]
      pKa_Donor <- suppressWarnings(get_physchem_param("pKa_Donor",chem.CAS=chem.cas))
      pKa_Accept <- suppressWarnings(get_physchem_param("pKa_Accept",chem.CAS=chem.cas))
      Pow <- 10^get_physchem_param("logP",chem.CAS=chem.cas)
      ion <- calc_ionization(pH=7.4,pKa_Donor=pKa_Donor,pKa_Accept=pKa_Accept)
      dow <- Pow * (ion$fraction_neutral + 0.001 * ion$fraction_charged + ion$fraction_zwitter)
      fub <- 1 / ((dow) * Flipid + 1 / fub)
    }
    parameters <- c(parameters,Funbound.plasma=fub)  
  }
  
  
# Check the species argument for capitilization problems and whether or not it is in the table:  
  if (!(species %in% colnames(physiology.data)))
  {
    if (toupper(species) %in% toupper(colnames(physiology.data)))
    {
      phys.species <- colnames(physiology.data)[toupper(colnames(physiology.data))==toupper(species)]
    } else stop(paste("Physiological PK data for",species,"not found."))
  } else phys.species <- species

# Load the physiological parameters for this species
  this.phys.data <- physiology.data[,phys.species]
  names(this.phys.data) <- physiology.data[,1]

  if ("hematocrit" %in% names(parameters))
  {
    hematocrit <- parameters[["hematocrit"]]
  } else hematocrit <- this.phys.data["Hematocrit"]
  plasma.vol <- this.phys.data["Plasma Volume"]/1000 # L/kg BW
  if(schmitt.params)
  {  
     if (is.data.table(parameters))
     {
       PCs <- parameters[,schmitt.names,with=F]
     } else {
       PCs <- subset(parameters,names(parameters) %in% schmitt.names)
     }
   # Get_lumped_tissues returns a list with the lumped PCs, vols, and flows:
    lumped_params <- lump_tissues(PCs,tissuelist=NULL,species=species)

    RBC.vol <- plasma.vol/(1 - hematocrit)*hematocrit
    vol.dist <- plasma.vol + RBC.vol*lumped_params$Krbc2pu*parameters$Funbound.plasma+lumped_params$Krest2pu*lumped_params$Vrestc*parameters$Funbound.plasma   
  } else {
    if(!all(param.names.schmitt %in% names(parameters)) & 
       !all(param.names.3comp %in% names(parameters)) & 
       !all(param.names.pbtk %in% names(parameters))) 
       stop("Use parameter lists from parameterize_pbtk, parameterize_3compartment, or predict_partitioning_schmitt only.")

    RBC.vol <- plasma.vol/(1 - parameters$hematocrit)*parameters$hematocrit 
    vol.dist <- plasma.vol + RBC.vol*parameters[["Krbc2pu"]]*parameters$Funbound.plasma
    lastchar <- function(x){substr(x, nchar(x), nchar(x))}
    firstchar <- function(x){substr(x, 1,1)}
    scaled.volumes <- names(parameters)[firstchar(names(parameters))=="V"&lastchar(names(parameters))=="c"]
    PCs <- names(parameters)[firstchar(names(parameters))=="K"]
    comps <- intersect(substr(scaled.volumes,2,nchar(scaled.volumes)-1),substr(PCs,2,nchar(PCs)-3)) 
    comps <-  comps[!(comps %in% c('art','ven'))]        
    for(this.comp in comps){
      eval(parse(text=paste('vol.dist <- vol.dist + ', parameters[[scaled.volumes[grep(this.comp,scaled.volumes)]]],'*', parameters[[PCs[grep(this.comp,PCs)]]],'*',parameters$Funbound.plasma))) # L 
    }
  }
    
  if(!suppress.messages){
    if(is.null(chem.name) & is.null(chem.cas)) cat("Volume of distribution returned in units of L/kg BW.\n")
    else cat(paste(toupper(substr(species,1,1)),substr(species,2,nchar(species)),sep=''),"volume of distribution returned in units of L/kg BW.\n")
  }
  return(as.numeric(vol.dist))
}