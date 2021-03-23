## esercitazione PRICING Health 


## ATTENZIONE: per poter usare RODBC dovrai usare la versione 32bit di R. Da 
# RStudio vai su Tools>Global Options> General > R Version > Change/Browse
# da qui rimanda il "Seleziona cartella" alla cartella C:\Program Files\R\R-3.5.3\bin\i386
# Chiudi RStudio e Riapri.

# installo il pacchetto se necessario
#install.packages('RODBC',dep=T)

# richiamo pacchetti necessari
library(RODBC)
library(downloader)

# creo il mio canale ODBC 
temp_directory=tempdir()

# scarico il database esempio
tmp_dir=tempdir()
url="https://github.com/manuelcaccone/CORSO-SIA----Basic-of-R-for-actuaries/raw/main/Allegati/Dati/Database.zip"
download(url, dest=file.path(tmp_dir,"DB.zip"), mode="wb") 
unzip(file.path(tmp_dir,"DB.zip"), exdir = tmp_dir)

# designo il path del file Access che ho scaricato
db_path=file.path(tmp_dir, "Database.accdb")
ODBC_str <- local({
  s <- list()
  s$path <- paste0("DBQ=", gsub("(/|\\\\)+", "/", path.expand(db_path)))
  s$driver <- "Driver={Microsoft Access Driver (*.mdb, *.accdb)}"
  s$threads <- paste0("Threads=", 8)
  s$buffer <- "MaxBufferSize=4096"
  s$timeout <- "PageTimeout=5"
  paste(s, collapse = ";")
})
t1=paste0("myChannell <- odbcDriverConnect(\"", ODBC_str, "\");")
eval(parse(text = t1))

# richiamo con SQL i database delle polizze e dei sinistri
claimsDb<-sqlQuery(myChannell, "select * from Claims")
policiesDb<-sqlQuery(myChannell, "select * from Policies")


#carico data table per efficienza
library(data.table)
# qui di seguito il link per esercitarsi in data.table  - CheatSheet
#https://s3.amazonaws.com/assets.datacamp.com/img/blog/data+table+cheat+sheet.pdf
# carico sqldf per query SQL
library(sqldf)

#######LAVORO SUI SINISTRI############
claimsDT<-as.data.table(claimsDb)
setkey(claimsDT,ID)
setnames(x = claimsDT, "CodAnagrafica","patientId")

#creo la tabella di numero sx e ammontate totale
aggregatedClaims<-claimsDT[,.(amount = sum(ImportoLiquidato), num=.N),by=.(patientId, Descrizione)] 
setnames(aggregatedClaims, "Descrizione", "category")

#metto in Inglese per comodità e riduco più parole in 1
aggregatedClaims[category=="Odontoiatria", category:="Dentistry"]
aggregatedClaims[category=="Endoscopia", category:="Endoscopy"]
aggregatedClaims[category=="Visite specialistiche", category:="Visits"]
aggregatedClaims[category=="Mammografia e ecografia", category:="Mammography"]
aggregatedClaims[category=="Analisi laboratorio", category:="Analysis"]
aggregatedClaims[category=="Diagnostica per immagini", category:="Diagnostics"]
aggregatedClaims[category=="Ricoveri ospedalieri in regime ordinario e D.S.", category:="Hospitalizations"]
aggregatedClaims[category=="Grandi interventi chirurgici", category:="Operations"]

#creo le aggregazioni dei ammontari di sinistri per assicurato e sistemo i nomi
ciaoAmt<-dcast.data.table(data=aggregatedClaims, value.var="amount", formula=as.formula(paste("patientId",rawToChar(as.raw(126)),'category')),fill=0)

# rinomino gli ammontari
setnames(ciaoAmt, "Dentistry","amtDentistry")
setnames(ciaoAmt, "Visits","amtVisits")
setnames(ciaoAmt, "Mammography","amtMammography")
setnames(ciaoAmt, "Analysis","amtAnalysis")
setnames(ciaoAmt, "Diagnostics","amtDiagnostics")
setnames(ciaoAmt, "Hospitalizations","amtHospitalizations")

#creo le aggregazioni del numeri dei sinistri per assicurato e sistemo i nomi

ciaoNum<-dcast.data.table(data=aggregatedClaims, value.var="num",formula=as.formula(paste("patientId",rawToChar(as.raw(126)),'category')),fill=0)


# rinomino gli ammontari
setnames(ciaoNum, "Dentistry","numDentistry")
setnames(ciaoNum, "Visits","numVisits")
setnames(ciaoNum, "Mammography","numMammography")
setnames(ciaoNum, "Analysis","numAnalysis")
setnames(ciaoNum, "Diagnostics","numDiagnostics")
setnames(ciaoNum, "Hospitalizations","numHospitalizations")

#questo db contiene i dati dei numeri e degli ammontari per paziente, dato che 
# l'assicurato ha avuto almento 1 sx
claimsDataFin<-merge(ciaoNum,ciaoAmt)

setkey(claimsDataFin, patientId)

#######LAVORO SULLE EXPOSURES############

policiesDT<-as.data.table(policiesDb)
setnames(policiesDT, "IdAnagrafica", "patientId")
setkey(policiesDT, patientId)

#codifico le variabili descrittive
policiesDT<-transform(policiesDT, Gender=factor(Sesso, ordered=FALSE),
                      Relation=factor(DescrizioneGradoParentela, ordered=FALSE),
                      DataScadenza=as.Date(as.character(DataScadenza)),
                      DataDecorrenza=as.Date(as.character(DataDecorrenza)),
                      DataNascita=as.Date(as.character(DataNascita))
)

#calcolo Età alla Stipula
policiesDT<-policiesDT[,AgeAtInception:=as.numeric(difftime(DataDecorrenza,DataNascita,units="weeks")/52)]


#calcolo anni polizza (exposure)
policiesDT[,DataFinePeriodo:=pmin(DataScadenza,as.Date("2010/01/01"))]
policiesDT[,policyYears:=as.numeric(difftime(DataFinePeriodo,DataDecorrenza))/365.25]
policiesDT[,sum(policyYears)]

#elimino anomalie (polizze con esposizione negativa), anni negativi
policiesDT<-policiesDT[policyYears>0,]
policiesDT<-policiesDT[AgeAtInception>0,]

#similmente elimino sinistri non abbinati sia individuali che aggregati
policiesIds<-unique(policiesDT$patientId)
claimsDT<-claimsDT[patientId %in% policiesIds,]
claimsDataFin<-claimsDataFin[patientId %in% policiesIds,]


#aggiungo le polizze anno tagliate

#aggiungo i differenti cuts
library(Hmisc)
policiesDT<-policiesDT[,AgeAtInceptionRec:=cut2(AgeAtInception,cuts = c(20,30,35,40,45,50,55),levels.mean=TRUE)]
policiesDT[,.(policyYears.Sum = sum(policyYears)),by=AgeAtInceptionRec]


######################MERGE POLIZZE CON SX##################################

db4Modeling<-merge(x=policiesDT,y=claimsDataFin, by="patientId",all.x=TRUE)

#azzero tutti i campi di costo missin (no sinistri x quel paziente)
fieldsNum<-grep(pattern = "num",names(db4Modeling),value = TRUE)
fieldsAmt<-grep(pattern = "amt",names(db4Modeling),value = TRUE)

for (field in c(fieldsNum,fieldsAmt)) {
  commandText<-paste("db4Modeling<-db4Modeling[!is.finite(",field,"),",field,":=0]",sep="")
  eval(parse(text=commandText))
}

# Creiamo con una funzione il dataset pronto per il modello GLM
createDbForModeling<-function(category, db, ageVar="AgeAtInception")  {
  
  if(ageVar=="AgeAtInception")  db<-db[,AgeAtInception:=round(AgeAtInception)]
  
  numVar<-paste("num",category,sep="")
  amtVar<-paste("amt",category,sep="")
  
  commandTxt<-paste("db[,.(",amtVar," = sum(",amtVar,"), ",numVar," = sum(",numVar,")", ",policyYears= sum(policyYears)",")",",by=.(",ageVar,", Gender,Relation)]",sep="") 
  myOutDb<- eval(parse(text=commandTxt))
  myOutDb<-as.data.frame.matrix(myOutDb) 
  return(myOutDb)
}


claimsCategories=c("Visits","Mammography", "Analysis","Diagnostics","Hospitalizations")
# Creiamo con una funzione 
for (i in claimsCategories) {
  myDb<-createDbForModeling(category = i,db=db4Modeling)
  dbVar<-paste("dbModel",i,sep="")
  assign(x=dbVar,value=myDb)
}


# carico il pacchetto necessario per applicare un GLM Tweedie
library(cplm)
library(tweedie)


# applico un glm al dataset--> dbModelHospitalizations
model.Hospitalizations <- cpglm(as.formula(paste0('amtHospitalizations', rawToChar(as.raw(126)), 'AgeAtInception+factor(Gender)+factor(Relation)')),offset = log(policyYears), data = dbModelHospitalizations)
# summary del modello
summary(model.Hospitalizations)
# applico un modello con una esplicavita in meno
model.Hospitalizations2 <- cpglm(as.formula(paste0('amtHospitalizations', rawToChar(as.raw(126)), 'AgeAtInception+factor(Relation)')),offset = log(policyYears), data = dbModelHospitalizations)
# confronto i modelli con indice di Gini


dbModelHospitalizations=transform(dbModelHospitalizations, P1 = fitted(model.Hospitalizations),
     P2 = fitted(model.Hospitalizations2))
gg <- gini(loss = "amtHospitalizations", score = paste("P", 1:2, sep = ""),
           data =dbModelHospitalizations)
gg@gini
# Procedura Backward tramite Gini Index - Valuto il modello con Somma di Indici più alta 
# Procedura Backward tramite Gini Index - il primo modello è quello più idoneo in termini di profitto
library(ggplot2)
theme_set(theme_bw())
# curva di Lorenz Loss vs Premium
plot(gg)
# curva di Lorenz 
plot(gg, overlay = FALSE)
