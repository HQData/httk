#' @import data.table
#' @import magrittr
#' @title Estimate well surface area
#' @description Estimate geometry surface area of plastic in well plate based on well plate format suggested values from Corning. 
#' option.plastic == T (default) give nonzero surface area (sarea, m^2)
#' option.bottom == T (default) includes surface area of the bottom of the well in determining sarea. 
#' Optionally include user values for working volume (v_working, m^3) and surface area. 
#' @param tcdata A data table with well_number corresponding to plate format, optionally include v_working, sarea, option.bottom, and option.plastic
#' @param this.well_number For single value, plate format default is 384, used if is.na(tcdata)==T
#' @param this.cell_yield For single value, optionally supply cell_yield, otherwise estimated based on well number
#' @param this.v_working For single value, optionally supply working volume, otherwise estimated based on well number (m^3)
#'
#' @return tcdata, A data table with well_number, sarea (surface area, m^2), cell_yield (# cells), v_working (m^3), v_total (m^3) per well
#'
#' @export
#'
#' @author Greg Honda
armitage_estimate_sarea <- function(tcdata = NA, # optionally supply columns v_working,sarea, option.bottom, and option.plastic
                                    this.well_number = 384,
                                    this.cell_yield = NA,
                                    this.v_working = NA){
  #R CMD CHECK throws notes about "no visible binding for global variable", for
  #each time a data.table column name is used without quotes. To appease R CMD
  #CHECK, a variable has to be created for each of these column names and set to
  #NULL. Note that within the data.table, these variables will not be NULL! Yes,
  #this is pointless and annoying.
  well_number<-well_desc<-radius<-diam<-v_working<-NULL
  v_working_est<-sysID<-height<-option.bottom<-sarea_c<-option.plastic<-NULL
  sarea<-cell_yield<-cell_yield_est<-NULL
  #End R CMD CHECK appeasement.
  
  if(is.na(tcdata)){
    tcdata <- data.table(well_number = this.well_number, cell_yield = this.cell_yield, v_working = this.v_working)
  }
  
  if(!(all(c("option.bottom","option.plastic") %in% names(tcdata)))){
      tcdata[,c("option.bottom","option.plastic")[!(c("option.bottom","option.plastic")%in%names(tcdata))]] <- as.logical(NA)
  }

  if(!(all(c("sarea","cell_yield","v_working")%in%names(tcdata)))){
      tcdata[,c("sarea","cell_yield","v_working")[!(c("sarea","cell_yield","v_working")%in%names(tcdata))]] <- as.double(NA)
  }

  well.desc.list <- c("flat_bottom","standard","clear_flat_bottom")
  well.number.list <- c(6,12,24,48)
  well.param <- copy(well_param)[well_number %in% well.number.list |
                             well_desc %in% well.desc.list]

  setnames(well.param,c("cell_yield","v_working"),c("cell_yield_est","v_working_est"))


  tcdata <- well.param[tcdata,on=.(well_number)]

  tcdata[,radius:=diam/2] %>%  # mm
    .[is.na(v_working), v_working:=as.numeric(v_working_est)] %>%
    .[sysID %in% c(7,9), height:= v_working/(diam^2)] %>%  #mm for square wells
    .[is.na(option.bottom),option.bottom:=T] %>%
    .[option.bottom==T & (sysID %in% c(7,9)),sarea_c := 4*diam*height+diam^2] %>% #mm2
    .[option.bottom==F & (sysID %in% c(7,9)),sarea_c := 4*diam*height] %>%
    .[!(sysID %in% c(7,9)),height:=v_working/(pi*radius^2)] %>% # for cylindrical wells
    .[option.bottom==T & !(sysID %in% c(7,9)), sarea_c := 2*pi*radius*height+pi*radius^2] %>%  #mm2
    .[option.bottom==F & !(sysID %in% c(7,9)), sarea_c := 2*pi*radius*height] %>%
    .[is.na(option.plastic),option.plastic:=T] %>%
    .[,sarea_c:=sarea_c/1e6] %>% #mm2 to m2
    .[option.plastic==F, sarea_c:=0] %>%
    .[is.na(sarea),sarea:=sarea_c] %>%
    .[is.na(cell_yield),cell_yield:=as.double(cell_yield_est)]

  return(tcdata)
}

#' @title Evaluate the updated Armitage model
#' @description Evaluate the Armitage model for chemical distributon in vitro.
#' Takes input as data table or single set of values. Outputs a data table.
#' Updates over the model published in Armitage et al. 2014 include binding to plastic walls and lipid and protein compartments in cells.
#' @references Armitage, J. M.; Wania, F.; Arnot, J. A. Environ. Sci. Technol. 2014, 48, 9770-9779. dx.doi.org/10.1021/es501955g
#' @param tcdata A data.table with casrn, ac50, MP, gkow, gkaw, gswat, sarea, v_total, v_working. Otherwise supply single values to this.params.
#' @param this.casrn For single value, CAS number
#' @param this.ac50 For single value, AC50 (micromolar) nominal concentration
#' @param this.MP For single value, melting point (oC)
#' @param this.gkow For single value, Log10 Kow, octanol-water partitioning coefficient
#' @param this.gkaw For single value, Log10 Kaw, air-water partitioning coefficient
#' @param this.gswat For single value, Log10 water solubility (mol/L)
#' @param this.sarea For single value, surface area per well (m^2)
#' @param this.v_total For single value, Total volume per well (m^3)
#' @param this.v_working For single value, Working volume per well (m^3)
#' @param this.cell_yield For single value, Number of cells per well
#' @param this.Tsys System temperature (oC)
#' @param this.Tref Reference temperature (K)
#' @param this.option.kbsa2 Use alternative bovine-serum-albumin partitioning model
#' @param this.option.swat2 Use alternative water solubility correction
#' @param this.FBSf Fraction fetal bovine serum
#' @param this.pseudooct Pseudo-octanol cell storage lipid content
#' @param this.memblip Membrane lipid content of cells
#' @param this.nlom Structural protein conent of cells
#' @param this.P_nlom Proportionality constant to octanol structural protein
#' @param this.P_dom Proportionality constant to octnaol dom
#' @param this.P_cells Proportionality constant to octanol storage lipid
#' @param this.csalt Ionic strength of buffer, mol/L
#' @param this.celldensity Cell density kg/L, g/mL
#' @param this.cellmass Mass per cell, ng/cell
#' @param this.f_oc 1, everything assumed to be like proteins
#'
#' @return tcdata
#'
#' @export
#'
#' @author Greg Honda
#'
#' @references Honda et al. (submitted) "Using the Concordance of In Vitro and 
#' In Vivo Data to Evaluate Extrapolation Assumptions"
armitage_eval <- function(tcdata = NA, # A data.table with casrn, ac50, MP, gkow, gkaw, gswat, sarea, v_total, v_working
                            this.casrn,
                            this.ac50 = 10, # micromolar
                            this.MP = NA,
                            this.gkow = NA,
                            this.gkaw = NA,
                            this.gswat = NA,
                            this.sarea = NA,
                            this.v_total = NA,
                            this.v_working = NA,
                            this.cell_yield = NA,
                            this.Tsys = 37,
                            this.Tref = 298.15,
                            this.option.kbsa2 = F,
                            this.option.swat2 = F,
                            this.FBSf = 0, #
                            this.pseudooct = 0.01, # storage lipid content of cells
                            this.memblip = 0.04, # membrane lipid content of cells
                            this.nlom = 0.20, # structural protein content of cells
                            this.P_nlom = 0.035, # proportionality constant to octanol structural protein
                            this.P_dom = 0.05,# proportionality constant to octanol dom
                            this.P_cells = 1,# proportionality constant to octanol storage-liqid
                            this.csalt = 0.15, # ionic strength of buffer, mol/L
                            this.celldensity=1, # kg/L g/mL  mg/uL
                            this.cellmass = 3, #ng/cell
                            this.f_oc = 1 # everything assumed to be like proteins
){
  # this.Tsys <- 37
  # this.Tref <- 298.15
  # this.option.kbsa2 <- F
  # this.option.swat2 <- F
  # this.FBSf <- 0.1
  # this.pseudooct <- 0.01 # storage lipid content of cells
  # this.memblip <- 0.04 # membrane lipid content of cells
  # this.nlom <- 0.20 # structural protein content of cells
  # this.P_nlom <- 0.035 # proportionality constant to octanol structural protein
  # this.P_dom <- 0.05 # proportionality constant to octanol dom
  # this.P_cells <- 1 # proportionality constant to octanol storage-liqid
  # this.csalt <- 0.15 # ionic strength of buffer, mol/L
  # this.celldensity<-1 # kg/L g/mL  mg/uL
  # this.cellmass <- 3 #ng/cell
  # this.f_oc <- 1 # everything assumed to be like proteins

  #R CMD CHECK throws notes about "no visible binding for global variable", for
  #each time a data.table column name is used without quotes. To appease R CMD
  #CHECK, a variable has to be created for each of these column names and set to
  #NULL. Note that within the data.table, these variables will not be NULL! Yes,
  #this is pointless and annoying.
  casrn<-ac50<-MP<-gkow<-gkaw<-gswat<-sarea<-v_total<-v_working<-NULL
  cell_yield<-cellwat<-pseudooct<-memblip<-nlom<-Tsys<-Tcor<-Tref<-Vm<-NULL
  Vwell<-Vair<-Vcells<-cellmass<-celldensity<-Valb<-FBSf<-Vslip<-Vdom<-dsm<-NULL
  duow<-duaw<-dumw<-F_ratio<-gs1.GSE<-s1.GSE<-gss.GSE<-ss.GSE<-gkmw<-kmw<-NULL
  kow<-kaw<-swat<-gkpl<-kpl<-gkcw<-P_cells<-P_nlom<-kcw<-gkbsa<-kbsa<-NULL
  option.kbsa2<-ksalt<-csalt<-swat_L<-option.swat2<-soct_L<-scell_L<-cinit<-NULL
  mtot<-cwat<-P_dom<-f_oc<-cwat_s<-csat<-activity<-cair<-calb<-cslip<-cdom<-NULL
  ccell<-cplastic<-mwat_s<-mair<-mbsa<-mslip<-mdom<-mcells<-mplastic<-NULL
  mprecip<-xwat_s<-xair<-xbsa<-xslip<-xdom<-xcells<-xplastic<-xprecip<-NULL
  ccells<-NULL
  #End R CMD CHECK appeasement.

  if(all(is.na(tcdata))){
    tcdata <- data.table(casrn=this.casrn,
                         ac50=this.ac50,
                         MP=this.MP,
                         gkow=this.gkow,
                         gkaw=this.gkaw,
                         gswat=this.gswat,
                         sarea=this.sarea,
                         v_total=this.v_total,
                         v_working=this.v_working,
                         cell_yield=this.cell_yield)
  }

  if(any(is.na(tcdata[,.(casrn,ac50,MP,gkow,gkaw,gswat,
                         sarea,v_total,v_working,cell_yield)]))){
    print("casrn, ac50, MP, gkow, gkaw, gswat, sarea, v_total, v_working, or cell_yield undefined")
  }


  manual.input.list <- list(Tsys=this.Tsys, Tref=this.Tref,
                                option.kbsa2=this.option.kbsa2, option.swat2=this.option.swat2,
                                FBSf=this.FBSf, pseudooct=this.pseudooct, memblip=this.memblip,
                                nlom=this.nlom, P_nlom=this.P_nlom, P_dom=this.P_dom, P_cells=this.P_cells,
                                csalt=this.csalt, celldensity=this.celldensity, cellmass=this.cellmass, f_oc=this.f_oc)

  check.list <- c("dsm","duow","duaw","dumw",
                  "gkmw","gkcw","gkbsa","gkpl","ksalt")

  req.list <- c("Tsys","Tref","option.kbsa2","option.swat2",
                 "FBSf","pseudooct","memblip","nlom","P_nlom","P_dom","P_cells",
                 "csalt","celldensity","cellmass","f_oc")
  if(!all(check.list%in%names(tcdata))){
  tcdata[,check.list[!(check.list %in% names(tcdata))]] <- as.double(NA)}

  if(!all(req.list%in%names(tcdata))){
  tcdata[,req.list[!(req.list %in% names(tcdata))]] <- manual.input.list[!(names(manual.input.list) %in% names(tcdata))]}

  R <- 8.3144

  tcdata[,cellwat := 1-(pseudooct+memblip+nlom)] %>%
    .[,Tsys:=Tsys+273.15] %>%
    .[,Tcor:=((1/Tsys)-(1/Tref))/(2.303*R)]


  tcdata[,Vm:=v_working/1e6] %>% # uL to L
      .[,Vwell:=v_total/1e6] %>% # uL to L
      .[,Vair:=Vwell-Vm] %>%
      .[,Vcells:=cell_yield*(cellmass/1e6)/celldensity/1e6] %>% # cell*(ng/cell)*(1mg/1e6ng)/(mg/uL)*(1uL/L)
      .[,Valb:=Vm*FBSf*0.733*24/1000] %>%
      .[,Vslip:=Vm*FBSf*1.9/1000] %>%
      .[,Vdom:=0]

  tcdata[is.na(dsm),dsm:=56.5] %>%
    .[is.na(duow),duow:=-20000] %>%
    .[is.na(duaw),duaw:=60000] %>%
    .[is.na(dumw),dumw:=duow] %>%
    .[,MP:= MP+273.15] %>%
    .[,F_ratio:=exp(-(dsm/R)*(MP/Tsys))] %>% #Walden's rule
    .[MP<=Tsys,F_ratio:=1]

  tcdata[,gs1.GSE:=0.5-gkow] %>%
    .[,gs1.GSE:=gs1.GSE-(-1*duow)*Tcor] %>%
    .[,s1.GSE:=10^gs1.GSE] %>%
    .[MP>298.15,gss.GSE:=0.5-0.01*((MP-273.15)-25)-gkow] %>%
    .[MP>298.15,gss.GSE:=gss.GSE-(-1*duow)*Tcor] %>%
    .[MP>298.15,ss.GSE:=10^gss.GSE] %>%
    .[is.na(gkmw),gkmw:=1.01*gkow + 0.12] %>%
    .[,gkmw:=gkmw-dumw*Tcor] %>%
    .[,kmw:=10^gkmw] %>%
    .[,gkow:=gkow-duow*Tcor] %>% # check this
    .[,kow:=10^gkow] %>%
    .[,gkaw:=gkaw-duaw*Tcor] %>%
    .[,kaw := 10^gkaw] %>%
    .[,gswat:=gswat-(-1*duow)*Tcor] %>%
    .[,swat:=10^gswat]

  tcdata[is.na(gkpl),gkpl:=0.97*gkow-6.94] %>%
    .[,kpl:=10^gkpl] %>%
    .[!(is.na(gkcw)),gkcw:=gkcw-duow*Tcor] %>%
    .[is.na(gkcw),gkcw:=log10(P_cells*pseudooct*kow + memblip*kmw +
                                P_nlom*nlom*kow + cellwat)] %>%
    .[,kcw:=10^gkcw]

  tcdata[!(is.na(gkbsa)),gkbsa:=gkbsa-duow*Tcor] %>%
    .[!(is.na(gkbsa)),kbsa:=10^gkbsa]

  tcdata[option.kbsa2==T & is.na(gkbsa) & gkaw<4.5, kbsa:=10^(1.08*gkow-0.7)] %>%
    .[option.kbsa2==T & is.na(gkbsa) & gkaw>=4.5, kbsa:=10^(0.37*gkow+2.56)]

  tcdata[option.kbsa2==F & is.na(gkbsa),kbsa:=10^(0.71*gkow+0.42)]

  tcdata[is.na(ksalt),ksalt:=0.04*gkow+0.114] %>%
    .[,swat:=swat*10^(-1*ksalt*csalt)] %>%
    .[,s1.GSE:=s1.GSE*10^(-1*ksalt*csalt)] %>%
    .[MP>298.15,ss.GSE:=ss.GSE*10^(-1*ksalt*csalt)] %>%
    .[,swat_L:=swat/F_ratio] %>%
    .[,kow:=kow/(10^(-1*ksalt*csalt))] %>%
    .[,kaw:=kaw/(10^(-1*ksalt*csalt))] %>%
    .[,kcw:=kcw/(10^(-1*ksalt*csalt))] %>%
    .[,kbsa:=kbsa/(10^(-1*ksalt*csalt))]

  tcdata[option.swat2==T & MP>298.15,swat:=ss.GSE] %>%
    .[option.swat2==T & MP>298.15,swat_L:=s1.GSE] %>%  # double check this
    .[option.swat2==T & MP<=298.15,swat:=s1.GSE] %>%
    .[option.swat2==T & MP<=298.15,swat_L:=s1.GSE]

  tcdata[,soct_L:=kow*swat_L] %>%
    .[,scell_L:=kcw*swat_L]

  tcdata[,ac50:=ac50/1e6] %>% # umol/L to mol/L
    .[,cinit:=ac50] %>%
    .[,mtot:=ac50*Vm] %>% # total moles
    .[,cwat:=mtot/(kaw*Vair + Vm + kbsa*Valb +
                     P_cells*kow*Vslip + P_dom*f_oc*Vdom + kcw*Vcells +
                     1000*kpl*sarea)] %>%
    .[cwat>swat,cwat_s:=swat] %>%
    .[cwat>swat,csat:=1] %>%
    .[cwat<=swat,cwat_s:=cwat] %>%
    .[cwat<=swat,csat:=0] %>%
    .[,activity:=cwat_s/swat_L]

  tcdata[,c("cair","calb","cslip","cdom","ccells")] <- 0

  tcdata[Vair>0,cair:=kaw*cwat_s] %>%
    .[Valb>0,calb:=kbsa*cwat_s] %>%
    .[Vslip>0,cslip:=kow*cwat_s*P_cells] %>%
    .[Vdom>0,cdom:=kow*cwat_s*P_dom*f_oc] %>%
    .[Vcells>0,ccells:=kcw*cwat_s] %>%
    .[,cplastic:=kpl*cwat_s*1000] %>%
    .[,mwat_s:=cwat_s*Vm] %>%
    .[,mair:=cair*Vair] %>%
    .[,mbsa:=calb*Valb] %>%
    .[,mslip:=cslip*Vslip] %>%
    .[,mdom:=cdom*Vdom] %>%
    .[,mcells:=ccells*Vcells] %>%
    .[,mplastic:=cplastic*sarea] %>%
    .[,mprecip:=0] %>%
    .[cwat>swat,mprecip:=mtot-(mwat_s+mair+mbsa+mslip+mdom+mcells+mplastic)] %>%
    .[,xwat_s:=mwat_s/mtot] %>%
    .[,xair:=mair/mtot] %>%
    .[,xbsa:=mbsa/mtot] %>%
    .[,xslip:=mslip/mtot] %>%
    .[,xdom:=mdom/mtot] %>%
    .[,xcells:=mcells/mtot] %>%
    .[,xplastic:=mplastic/mtot] %>%
    .[,xprecip:=mprecip/mtot]

  return(tcdata)
  #output concentrations in mol/L
  #output mass (mwat_s etc.) in mols
  #output mol fraction xbsa etc.
}

