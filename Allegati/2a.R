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


# ritorniamo a RAA, calcoliamo i fattori di sviluppo
n <- 10
f <- sapply(1:(n-1),
               function(i){
                 sum(RAA[c(1:(n-i)),i+1])/sum(RAA[c(1:(n-i)),i])
               }
)
f

# estraiamo il fattore coda mediante un modello log-lineare
dev.period <- 1:(n-1)
plot(log(f-1) ~ dev.period, main="Log-linear extrapolation of age-to-age factors")
tail.model <- lm(log(f-1) ~ dev.period)
abline(tail.model)
co <- coef(tail.model)
## extrapolate another 100 dev. period
tail <- exp(co[1] + c(n:(n + 100)) * co[2]) + 1
f.tail <- prod(tail)
f.tail

# osserviamo l'andamento globale dei fattori
plot(100*(rev(1/cumprod(rev(c(f, tail[tail>1.0001]))))), t="b",
     main="Andamento atteso dei pagati",
     xlab="Periodo di sviluppo", ylab="Sviluppo del sinistro in % dell'ultimate loss")


# otteniamo adesso il triangolo completo 
f <- c(f, f.tail)
fullRAA <- cbind(RAA, Ult = rep(0, 10))
for(k in 1:n){
  fullRAA[(n-k+1):n, k+1] <- fullRAA[(n-k+1):n,k]*f[k]
}
round(fullRAA)


# otterremmo con un solo comando lo stesso risultato applicando la stima MACK
mack <- MackChainLadder(RAA, est.sigma="Mack")
mack$FullTriangle

# otteniamo il totale della riserva ultimate
sum(fullRAA[ ,11] - getLatestCumulative(RAA))



## MACK e BOOTCHAINLADDER
# osserviamo quanto ottenuto con il metodo di Mack 
MackChainLadder(Triangle = RAA, est.sigma = "Mack")
plot(mack)

# otteniamo invece risultati diversi con il BootCl
res=BootChainLadder(RAA,1000,process.distr = 'od.pois')
plot(res)

# nell'oggetto lista sono presenti le 1000 simulazioni di triangolare del residuo del Pearson
# che hanno dato luogo alla stima della volatilità 
res$simClaims

