# ESERCITAZIONE RESERVING 

# installo il pacchetto se necessario 
install.packages('ChainLadder',dependencies = TRUE)

# richiamo il pacchetto
library(ChainLadder)

# osservo i vari dataset presenti nel pacchetto stesso per potermi esercitare
data(package="ChainLadder")

# utilizzerò il triangolo di RunOff RAA
RAA

# una prima possibilità sta nell'osservare gli sviluppi dei sinistri 
# per poter osservare la "longevità" di alcune generazioni oppure l'onerosità 
plot(RAA)

# una rappresentazione più ordinata, tenendo conto anche dell'anno di origine
# potrebbe essere la seguente
plot(RAA,lattice=TRUE)


# passiamo dalla triangolare dei pagati alla triangolare dei cumulati 
raa.inc <- cum2incr(RAA)


# può capitare che io abbia a disposizione dati da Excel 
# scarichiamo questo file di esempio 
# https://github.com/manuelcaccone/CORSO-SIA----Basic-of-R-for-actuaries/blob/main/Allegati/2a.xlsx
# ora copiamo ed incolliamo da Excel 
tri <- read.table(file="clipboard", sep="\t", na.strings="NA")

