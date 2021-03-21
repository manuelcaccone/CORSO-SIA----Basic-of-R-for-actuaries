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
# installo il pacchetto se ne ho bisogno 
install.packages('R.matlab',dep=T)
# carico pacchetto e setting della working directory 
library(R.matlab)
# carico i dati
dati=readMat('https://github.com/manuelcaccone/CORSO-SIA----Basic-of-R-for-actuaries/blob/main/Allegati/Dati/acetylene.mat?raw=true')
# osservo natura dei dati
str(dati)
x1=dati$x1
x2=dati$x2
plot(x1,x2)
# scrivo in formato .mat
writeMat('Prova.mat',x1=x1,x2=x2)


## Python 
# installo il pacchetto se ne ho bisogno 
install.packages('reticulate',dep=T)
# carico pacchetto e setting della working directory 
library(reticulate)

# installare un pacchetto Python da R
py_install('matplotlib')


# load del codice 1a.py
td = tempdir()
tf = tempfile(tmpdir=td, fileext=".py")
download.file("https://raw.githubusercontent.com/manuelcaccone/CORSO-SIA----Basic-of-R-for-actuaries/main/Allegati/1a.py", tf)
source_python(tf)


## EXCEL 
# installo il pacchetto se ne ho bisogno 
install.packages('readxl',dep=T)
# carico pacchetto e setting della working directory 
library(readxl)
# leggo i dati 
#dati=read_excel('Prova.xlsx')
# installo il pacchetto se ne ho bisogno 
install.packages('openxlsx',dep=T)
# carico pacchetto e setting della working directory 
library(openxlsx)
setwd("C:\\Users\\UGA05153\\Desktop\\CORSO SIA - Basics of R for Actuaries")
# creo un foglio Excel 
wb <- createWorkbook()
## aggiungo attributi 
wb <- createWorkbook(creator = "Me"
                     , title = "title here"
                     , subject = "this & that"
                     , category = "something")

# creo un modello di regressione
mod=lm(mtcars)

# aggiungo cartella di lavoro 
addWorksheet(wb,'Modello di regressione')

# creo un template 
headerStyle <- createStyle(fontSize = 8, fontColour = "#FFFFFF", halign = "left",
                           fgFill = "#4F81BD", border="TopBottom", borderColour = "#4F81BD",numFmt = 'TEXT',
                           wrapText = T)
# applico il template ad una area del mio foglio
addStyle(wb, sheet = 'Modello di regressione', 
         headerStyle, rows = 1:100, cols = 1:100, gridExpand = TRUE)

# attacco i risultati dei coffienti al mio foglio di lavoro
writeData(wb, sheet = 'Modello di regressione', x = data.frame(Coefficienti=names(coefficients(mod)),
                                                               Valori=coefficients(mod)), startRow =1 , startCol = 1)

# stampo un grafico delle relazioni lineare
png(file.path(getwd(),'Prova.png'), height = 800, width = 1600, res = 250, 
    pointsize = 8)
pairs(mtcars)
dev.off()

# inserisco il grafico dalla terza colonna
insertImage(wb,sheet = 'Modello di regressione',
            file =file.path(getwd(),'Prova.png'),
              startRow = 3,startCol = 3)
saveWorkbook(wb,'Prova.xlsx')





