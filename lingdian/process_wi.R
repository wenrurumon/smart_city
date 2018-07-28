
rm(list=ls())
library(data.table)
library(dplyr)
setwd('e:/xmandata/lingdian')
x <- fread('heatmap.csv')

w <- x %>% group_by(prov_id,lon,lat,blon,blat) %>% summarise(w=sum(w))

wi <- filter(w,prov_id=='JIANGSU')
dim(wi)
out <- t(sapply(1:nrow(wi),function(i){
  print(i)
  wii <- wi[i]
  wii <- filter(wi,(lon%in%(wii$lon + c(-2:2)))&(lat%in%(wii$lat + c(-2:2))))
  c(n=nrow(wii),w=sum(wii$w))
}))
wi <- data.table(wi,out)
write.csv(wi,'jiangsu_wi.csv')

# mutate(w1[order(-w1$w)],d=paste0(blat,',',blon)) %>% select(-prov_id,-lon,-lat)

