CAS.checksum <- function(CAS.string)
{
  test.num <- 0
  multiplier <- 1
  if(is.factor(CAS.string)) CAS.string <- as.character(CAS.string)
  for (i in (nchar(CAS.string)-2):1)
    if (!is.na(as.numeric(substr(CAS.string,i,i))))
    {
      test.num <- test.num + as.numeric(substr(CAS.string,i,i))*multiplier
      multiplier <- multiplier + 1
    }
  if (is.na(test.num%%10 == as.numeric(substr(CAS.string,nchar(CAS.string),nchar(CAS.string))))) return(F)
  return (test.num%%10 == as.numeric(substr(CAS.string,nchar(CAS.string),nchar(CAS.string))))
}


augment.table <- function(this.table,this.CAS,compound.name=NULL,this.property,value,species=NULL,reference,overwrite=F)
{
  # Columns stored in chem.phys_and_invitro.table:
  CHEM.ID.COLS<-c("Compound","CAS","CAS.Checksum","DTXSID","Formula","SMILES.desalt")
  CHEM.PHYS.COLS<-c("MW","logP","logPwa","pKa_Donor","pKa_Accept","logMA")
  # The colmuns have "[SPECIES]." prepended to their name:
  CHEM.INVITRO.COLS <- c("Clint","Clint.pValue","Funbound.plasma","Fgutabs","Rblood2plasma")
  # In the table we create each word in most column names is capitalized:
  COLUMN.CAPITALIZATION.EXCEPTIONS <- c("Clint.pValue","logP","logMA","logPwa","MW","CAS","CAS.Checksum","pKa_Donor","pKa_Accept","SMILES.desalt","DTXSID","Formula")
  # Many data are converted to numeric,but sometimes we want to preserve strings:
  AS.NUMERIC.EXCEPTIONS <- c("pKa_Donor","pKa_Accept","SMILES.desalt","Funbound.plasma","Clint","DTXSID","SMILES.desalt","Formula")
  if (!is.na(value))
  {
    if (tolower(this.property) %in% tolower(COLUMN.CAPITALIZATION.EXCEPTIONS)) this.property <- COLUMN.CAPITALIZATION.EXCEPTIONS[tolower(COLUMN.CAPITALIZATION.EXCEPTIONS)==tolower(this.property)]
    else {
      this.property <- tolower(this.property)
      substring(this.property,1,1) <- toupper(substring(this.property,1,1))
    }
  
                                       
    data.cols <- c("Reference","Species",CHEM.ID.COLS,CHEM.PHYS.COLS,CHEM.INVITRO.COLS)
    if (!(tolower(this.property) %in% tolower(data.cols)))
      stop(paste("Parameter", this.property,
        "not matched by columns in our data table."))
    
  # If one of the species-specific parameters is being set (that is, anything in
  # chem.invitro.cols) then species must either be set for the whole table or read
  # in from a column in that table:
    if ((this.property %in% CHEM.INVITRO.COLS) & is.null(species)) stop("Either \
  argument \"species\" must be set for whole table or \"Species\" must be \
  matched to a \"new.table\" column in argument \"data.list\".")
  
    if (!is.null(compound.name))
    {
      compound.name <- tolower(compound.name)
      substring(compound.name,1,1) <- toupper(substring(compound.name,1,1))
      compound.name <- iconv(compound.name, from="UTF-8", to='ASCII//TRANSLIT')
    } else {
  
    }
  
    if (this.property %in% CHEM.INVITRO.COLS)
    {
      if (!is.null(species))
      {
        species <- tolower(species)
        substring(species,1,1) <- toupper(substring(species,1,1))
      }
      this.property<-paste(species,this.property,sep=".")
    }
    if (is.na(this.CAS)) return(this.table)
    if (!(this.CAS %in% this.table[,"CAS"]))
    {
      if (is.null(compound.name)) compound.name <- this.CAS
      if (!is.null(this.table))
      {
        this.row <- this.table[1,]
        this.row[] <- NA
      } else {
        this.row <- as.data.frame(compound.name,stringsAsFactors=F)
        colnames(this.row) <- "Compound"
      }
      this.row[,"Compound"] <- compound.name
      this.row[,"All.Compound.Names"] <- compound.name
      this.row[,"CAS"] <- this.CAS
      this.row[,"CAS.Checksum"] <- CAS.checksum(this.CAS)
      if (!is.null(species)) this.row[,"All.Species"] <- species
      else this.row[,"All.Species"] <- "None"
  #    if (!is.null(this.table))
  #    {
  #      this.row <- cbind(this.row,t(as.data.frame(rep(NA,dim(this.table)[2]-5))))
  #      colnames(this.row) <- colnames(this.table)
  #    } else colnames(this.row) <- c("Compound","All.Compound.Names","CAS","CAS.Checksum","All.Species")
      rownames(this.row) <- this.CAS
      this.table <- rbind(this.table,this.row)
    }
  #  if (!(this.property %in% chem.prop.cols)) stop(paste(this.property,"not a valid property"))
    index <- which(this.table[,"CAS"]==this.CAS)
    if (!is.null(compound.name))
    {
      if (!(compound.name %in% strsplit(this.table[index,"All.Compound.Names"],"[|]")[[1]]))
      {
        this.table[index,"All.Compound.Names"] <- paste(this.table[index,"All.Compound.Names"],compound.name,sep="|")
      }
    }
    if (!is.null(species))
    {
      if (this.property %in% paste(species,CHEM.INVITRO.COLS,sep="."))
      {
        if (!(species %in% strsplit(this.table[index,"All.Species"],"[|]")[[1]]))
        {
          if (this.table[index,"All.Species"]=="None") this.table[index,"All.Species"] <- species
          else this.table[index,"All.Species"] <- paste(this.table[index,"All.Species"],species,sep="|")
        }
      }
    }
    if (!(this.property %in% colnames(this.table)))
    {
      this.table[,this.property] <- NA
      ref.name <- paste(this.property,"Reference",sep=".")
      this.table[,ref.name] <- NA
    }
    if (is.na(this.table[index,this.property]) | overwrite | (this.property == paste(species,'Funbound.plasma',sep=".") & this.table[index,this.property] == 0))
    {
      if (!(this.property %in% AS.NUMERIC.EXCEPTIONS)) this.table[index,this.property] <- as.numeric(value)
      else this.table[index,this.property] <- as.character(value)
# There is a difference between no pKa prediction available, a prediciton of no pKa:
      if(!is.na(this.table[index,this.property]) & this.table[index,this.property] == "" & this.property %in% c("pKa_Donor","pKa_Accept")) this.table[index,this.property] <- NA
      ref.name <- paste(this.property,"Reference",sep=".")
      this.table[index,ref.name] <- reference
    }
    CHEM.PHYS.COLS <- sort(c(CHEM.PHYS.COLS,paste(CHEM.PHYS.COLS,"Reference",sep=".")))
    col.order <- c(CHEM.ID.COLS[CHEM.ID.COLS %in% colnames(this.table)],"All.Compound.Names",CHEM.PHYS.COLS[CHEM.PHYS.COLS %in% colnames(this.table)],"All.Species")
    col.order <- c(col.order,sort(colnames(this.table)[!(colnames(this.table) %in% col.order)]))
    
    if (any(is.na(this.table[,"All.Species"]))) browser()
    return(this.table[,col.order])
  } else {
    return(this.table)
  }
}


add_chemtable <- function(new.table, data.list, current.table=NULL, reference=NULL,
                          species=NULL, overwrite=F)
{
# Let's make the capitalization consistent in data.list:
  exceptions <- c("Clint.pValue","logP","logPwa","logMA","MW","CAS","CAS.Checksum","pKa_Donor","pKa_Accept","SMILES.desalt","DTXSID","Formula")
  for (this.name in names(data.list))
  {
    if (tolower(this.name) %in% tolower(exceptions)) this.name <- exceptions[tolower(exceptions)==tolower(this.name)]
    else {
      this.name <- tolower(this.name)
      substring(this.name,1,1) <- toupper(substring(this.name,1,1))
    }
  }
  
# We either need to have reference set for the whole table, or read in from a
#column from that table:
  if (is.null(reference) & !("Reference" %in% names(data.list))) stop("Either \
argument \"reference\" must be set for whole table or \"Reference\" must be \
matched to a \"new.table\" column in argument \"data.list\".")

  if (!is.null(reference) & ("Reference" %in% names(data.list))) stop("Reference\
 cannot be specifed by both \"reference=\" and \"data.list\".")

  if (!is.null(species) & ("Species" %in% names(data.list))) stop("Species\
 cannot be specifed by both \"species=\" and \"data.list\".")
  if (!is.null(species)) this.species <- species

  if (!any(c("CAS") %in% names(data.list))) stop("\"CAS\" must be one of the \
columns in \"data.list\".")

# Identify which entries in data.list are being added to the table:
  new.data <- names(data.list)[!(names(data.list) %in% c("CAS","Compound","Reference","Species"))]
  if (!is.null(reference)) this.reference <- reference
  for (this.row in 1:dim(new.table)[1])
  {
    this.CAS <- new.table[this.row,data.list[["CAS"]]]
    if ("Compound" %in% names(data.list))
    {
      this.compound <- tolower(new.table[this.row,data.list[["Compound"]]])
    }
    else this.compound <- NULL
    if (is.null(reference)) this.reference <- new.table[this.row,data.list[["Reference"]]]
    if (is.null(species))
    {
      if ("Species" %in% names(data.list))
      {
        this.species <- tolower(new.table[this.row,data.list[["Species"]]])
        substring(this.species,1,1) <- toupper(substring(this.species,1,1))
      } else {
        this.species <- NULL
      }
    }
    for (this.data in new.data)
    {
      if (!(data.list[[this.data]] %in% colnames(new.table))) stop(paste(data.list[[this.data]],
        "is not a column in the new table."))
      current.table <- augment.table(current.table,
                                     this.CAS,
                                     this.compound,
                                     this.property=this.data,
                                     value=new.table[this.row, data.list[[this.data]]],
                                     reference=this.reference,
                                     species=this.species,
                                     overwrite=overwrite)
    }
  }

  return(current.table)
}
