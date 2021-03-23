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