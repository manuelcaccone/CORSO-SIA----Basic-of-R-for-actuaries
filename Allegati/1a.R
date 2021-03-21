# ESEMPIO 1A

## SAS
# installo il pacchetto haven se ne ho bisogno 
install.packages('haven',dep=T)

# leggere file, modificarli e tradurli in formato .sas7bdat
# carico pacchetto e setting della working directory 
library(haven)
setwd("C:\\Users\\UGA05153\\Desktop\\CORSO SIA - Basics of R for Actuaries")
# carico i dati
dati=read_sas('https://github.com/manuelcaccone/CORSO-SIA----Basic-of-R-for-actuaries/blob/3a8543f2b255db31f087c4cc5165052435e8aef5/Allegati/Dati/cps.sas7bdat?raw=true')
# faccio una summary 
summary(dati)
# estraggo solo delle variabili
dati2=subset(dati,select = c('WAGE','EDUC','AGE','FEMALE'))
# salvo il file in formato .sas7bdat
write_sas(dati2,'prova.sas7bdat')

## MATLAB
