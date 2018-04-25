rm(list=ls())
library(data.table)
library(dplyr)
setwd('/Users/wenrurumon/Documents/xmdata/lianchang/dsn')
options(digits=20)

###########

map <- fread('grid_map.csv')
map <- filter(map,name=='上海市')

###########

x <- readLines('dsn')
x <- do.call(rbind,strsplit(x,'\t'))[-1,]

i <- 1
xk <- gsub(')))','',gsub('MULTIPOLYGON','',x[i,4]))
xk <- substr(xk,4,nchar(xk))
xk <- do.call(rbind,strsplit(strsplit(xk,',')[[1]],' '))
xk <- as.data.frame(apply(xk,2,as.numeric,digit=10))
colnames(xk) <- c('lon','lat') 

xk <- mutate(xk,loni=floor((lon-map$slon)/map$mlon),lati=floor((lat-map$slat)/map$mlat))
xk <- arrange(unique(xk[,3:4]),loni,lati)

f1 <- xk %>% group_by(loni) %>% summarise(latin=min(lati),latax=max(lati))
f1 <- do.call(rbind,lapply(1:nrow(f1),function(i){
  cbind(f1$loni[i],f1$latin[i]:f1$latax[i]  )
}))

f2 <- xk %>% group_by(lati) %>% summarise(lonin=min(loni),lonax=max(loni))
f2 <- do.call(rbind,lapply(1:nrow(f2),function(i){
  cbind(f2$lonin[i]:f2$lonax[i],f2$lati[i])
}))

# arrange(as.data.frame(f1),V1,V2)
# arrange(as.data.frame(f2),V1,V2)
f <- unique(rbind(f1,f2))

#######

setwd('shanghai_2018Nov_20180423')
x <- fread(dir()[1])
f
