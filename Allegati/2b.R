## esercitazione PRICING Health 


## ATTENZIONE: per poter usare RODBC dovrai usare la versione 32bit di R. Da 
# RStudio vai su Tools>Global Options> General > R Version > Change/Browse
# da qui rimanda il "Seleziona cartella" alla cartella C:\Program Files\R\R-3.5.3\bin\i386
# Chiudi RStudio e Riapri.

# installo il pacchetto se necessario
install.packages('RODBC',dep=T)

# richiamo il pacchetto
library(RODBC)
setwd(readClipboard())
myChannell<- odbcConnectAccess2007("Database.accdb")
claimsDb<-sqlQuery(myChannell, "select * from Claims")
policiesDb<-sqlQuery(myChannell, "select * from Policies")
