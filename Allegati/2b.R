## esercitazione PRICING Health 


## ATTENZIONE: per poter usare RODBC dovrai usare la versione 32bit di R. Da 
# RStudio vai su Tools>Global Options> General > R Version > Change/Browse
# da qui rimanda il "Seleziona cartella" alla cartella C:\Program Files\R\R-3.5.3\bin\i386
# Chiudi RStudio e Riapri.

# installo il pacchetto se necessario
install.packages('RODBC',dep=T)

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
