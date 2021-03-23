# installo il pacchetto principale e relative dipendenze
install.packages('lifecontingencies',dep='T')


# carico pacchetto 
library(lifecontingencies)


# carico tavole di mortalità
data(demoIta)

head(demoIta)
Tavole=demoIta

# si vuole effettuare il Profit Testing deterministico di una polizza 
# Mista, di durata 'n' anni, che assicura un capitale 'A? ad una testa
# di età 'x. Setto i parametri di input-->
A=10000
tavola='SIM92'
x=40
sesso='M'
n=10
m=10
i=0.03
N=1

# creazione tavola demografica 
LifeTable<- Tavole[,c("X",tavola)]
names(LifeTable) <- c("x","lx")
LifeTable <- as(LifeTable,"lifetable")
qx=rep(NA,n)
for(j in 1:(n)) qx[j]=qxt(LifeTable,x=x+j-1,1) 

# calcolo del premio unico puro mediante funzione 
U=A*AExn(LifeTable,x=x,n=n,i=i)

# calcolo del premio periodico
P=U/axn(LifeTable,x=x,n=m,i=i)

# Profilo della riserva secondo l'equazione--> A*(n-k)A(x+k)-P*(n-k)ä(x+k)
v=function(i,n) return(((1+i)^(-1))^(0:n))
vk=v(i,n)
Axk=c(rep(NA,n))
for(j in 0:n)  Axk[j]=AExn(LifeTable,x=x+j,n=n-j,i=i)
axk=c(rep(NA,n))
for(j in 0:n)  axk[j]=axn(LifeTable,x=x+j,n=n-j,i=i)
P=rep(P,n+1)
A=rep(A,n+1)
Axk=c(AExn(LifeTable,x=x,n=n,i=i),Axk)
axk=c(axn(LifeTable,x=x,n=m,i=i),axk)
Vt=A*Axk-P*axk


# Impostazione BT II ordine 
i2=0.04
sconto=0.25
penalty=0.20
tassolapse=0.03
lapse=c(rep(tassolapse,n-1),0)
qx2=rep(NA,n)
for(j in 1:(n)) qx2[j]=qxt(LifeTable,x=x+j-1,1)*(1-sconto) 
lam=c(1,(1-qx2))
lambda=c(1,rep(NA,n))
for(j in 2:(n+1)) lambda[j]=lam[j]*lambda[j-1]*(1-lapse[j-1])



# Consistenza in PTF
NContr=N*lambda


# Creazione Flussi Cassa secondo il modello 
# VNt - Riserve PTF, Pt - Flusso Premi, Xt - Sinistri, Et  - riscatti, CV - Cap. Caso Vita
VNtIn= Vt[-1]*NContr[-1]
VNtIn=c(0,VNtIn[-length(VNtIn)])
VNtFin=Vt[-1]*NContr[-1]

Pt=P[-length(P)]*NContr[-length(P)]
Xt=A[-1]*qx2*lambda[1:length(qx)]
Rt=Vt[-1]*lapse*(1-qx2)*NContr*(1-penalty)
Rt=c(Rt[1:(n-1)],0)
CV=c(rep(0,n-1),A[1])

# Utile
Ut=c(0,(VNtIn+Pt)*(1+i2)-CV-Xt-Rt-VNtFin)

# Scomposizione Utile 
# Utile Finanziario - UF

UF=(VNtIn+Pt)*(i2-i)

# Utile Demografico - UD

UD=(A[-1]-Vt[-1])*(qx-qx2)*lambda[-length(lambda)]

# Utile riscatti

UR=Vt[-1]*penalty*lapse*(1-qx2)*NContr[-length(NContr)]

# Check Utile
Ut[length(Ut)]=UF[length(UF)]
round(UR+UF+UD-Ut[-1],10)


# check Utile - Excel
write.excel <- function(x,row.names=FALSE,col.names=TRUE,...) {
  write.table(x,"clipboard",sep="\t",dec=',')
}
write.excel(data.frame(VNtIn,Pt,CV,Xt,Rt,VNtFin))

# Utile totale atteso 
E_Ut=presentValue(cashFlows=Ut[-1], timeIds=1:n, interestRates=i2)
E_UD=presentValue(cashFlows=UD, timeIds=1:n, interestRates=i2)
E_UR=presentValue(cashFlows=UR, timeIds=1:n, interestRates=i2)
E_UF=presentValue(cashFlows=UF, timeIds=1:n, interestRates=i2)

# check utile totale atteso
round(E_UR+E_UF+E_UD-E_Ut[-1],10)