# Writen by Robert Pearce and John Wambaugh
# Adds the predicted data from Sipes et al. (2017) for the Tox21 library
load_sipes2017 <- function(load.image=T,overwrite=F,target.env=.GlobalEnv)
{
  if (load.image)
  {
#    assignInMyNamespace("chem.physical_and_invitro.data", sipes2017.table)
    assign("chem.physical_and_invitro.data", sipes2017.table,envir=target.env)
#    chem.physical_and_invitro.data <<- sipes2017.table
  } else {
    assign("chem.physical_and_invitro.data", add_chemtable(sipes2017,
                                                  current.table=chem.physical_and_invitro.data,
                                                  data.list=list(Compound='Compound', 
                                                    CAS='CAS', 
                                                    MW = 'MW', 
                                                    logP = 'logP',
                                                    pKa_Donor = 'pKa_Donor', 
                                                    pKa_Accept = 'pKa_Accept',
                                                    Funbound.plasma = 'Human.Funbound.plasma', 
                                                    Clint = 'Human.Clint', 
                                                    SMILES.desalt = 'SMILES.desalt'),
                                                  reference = 'Sipes 2017', 
                                                  species= 'Human', 
                                                  overwrite=overwrite),
                                                  envir=target.env)
  }
}