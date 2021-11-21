

#if (!require('devtools')) install.packages('devtools')
#install.packages("raster")
#install.packages("rgdal")
#install.packages("dplyr")
#install.packages("occ")


library(ntbox)
library(raster)
library(rgdal)
library(dplyr)
library(occ)
library(rgbif)

#Identificar la clave de mi categoria taxonomica
name_backbone(name = "Porthidium yucatanicum", rank = "Species", kingdom = "animalia")

#Obtener los registros con base en mi clave taxonomica
my_query <- pred_and(pred("taxonKey", 2444298),pred("hasCoordinate","TRUE"))

my_dl <- occ_download(my_query,user="",pwd="",email="")
#
dl<-occ_download_get(my_dl, overwrite=TRUE)
records <-occ_download_import(dl)

setwd("C:/Users/IGNITER/Desktop/prueba")
write.csv(records,file="P_yuc.csv", row.names = FALSE)

## Cargo los archivos ##
setwd("C:/Users/IGNITER/Desktop/prueba/var")
comp <-list.files(pattern=".asc")
stack <- raster::stack(comp)
## indico el directorio de trabajo ##
setwd("C:/Users/IGNITER/Desktop/prueba")
press<-list.files(pattern=".csv")
#
## Creo el bucle para depurar los archivos ##

for(i in 1:length(press)){
gbif <-read.delim(press[[1]],header=T,sep=",")
## selecciono las columnas de mi interés ##
gbif_d <- select(gbif, decimalLatitude, decimalLongitude, species)
## selecciono los registros con coordenadas ##
#gbif_d1<-subset(gbif_d, !is.na(decimalLatitude) & !is.na(decimalLongitude))
gbif_d1 <- na.omit(gbif_d)
## Cambiar el nombre de las columnas ##
colnames(gbif_d1) <- c("Long", "Lat", "Especie")
## si es necesario invertir las columnas (saltar si están correctas) ##
gbif_d2 <- gbif_d1[c("Especie", "Long", "Lat")]
## agregar nueva columna con valores NA ##
gbif_d2["unique_id"]<-NA
## multiplicar la longitud y la lat en la nueva columna ##
gbif_d2$unique_id <- gbif_d2$Long * gbif_d2$Lat
## eliminar registros duplicados con base en la nueva columna ##
gbif_d3 <- gbif_d2[!duplicated(gbif_d2[,4]),]
## elimino la columna ID ##
gbif_d4 <- select(gbif_d3, Especie, Long, Lat)
## Extraigo los valores de mis registros a los rasters ##
#env <- raster::extract(stack, gbif_d4[,c("Long","Lat")])
#f_occ_env <- data.frame(gbif_d4, env)
## elimino todos los que tengan valores 0, es decir los que caen fuera de mi raster ##
# occ_env <- na.omit(f_occ_env)
#data_clean <- (occ_env[,c("Especie","Long","Lat")])
setwd("C:/Users/IGNITER/Desktop/prueba/clean")
#write.csv(data_clean,paste(press[[i]]),row.names = F)
write.csv(gbif_d4,paste(press[[1]]),row.names = F)
setwd("C:/Users/IGNITER/Desktop/prueba")
next
}


## separo mis especies en dataframe individuales ##

specieslist <- split(gbif_d4, gbif_d4$Especie)
setwd("C:/Users/IGNITER/Desktop/prueba")
allNames <- names(specieslist)

## creo un bucle para guardarlo ##
for(i in 1:length(allNames)){
write.csv(specieslist[i],paste(allNames[[i]],".csv"),row.names = F)
}

#