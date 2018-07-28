
rm(list=ls())
library(data.table)
library(dplyr)
setwd('e:/xmandata/dikanong')

map <- fread('shanghai_dist.csv',encoding='UTF-8')
x <- fread('V0310000_20180501.csv')
colnames(x)[4:5] <- c('xlat','xlon')
map3 <- select(fread('map3.csv'),-V1); colnames(map3)[3:4] <- c('lng','lat')
map <- merge(map,map3,by=c('lng','lat'))
x.merge <- merge(x,map,by=c('xlat','xlon'))
x <- x.merge

# write.csv((x %>% group_by(ptype,dist,local,gender,age) %>% summarise(n=sum(n))),'shanghai_dist_stat.csv')


rm(list=ls())
setwd('E:\\xmandata\\zhizhi')
library(data.table)
x <- lapply(dir(),fread)
x <- do.call(rbind,x)
# write.csv(x,'beijing_poi_update',row.names=F)

head(x)
poi.base <- filter(x,grepl('便利店|超市',type))
count.poi <- function(x,base=poi.base){
  x <- unique(filter(base,grepl(x,name)))
  print(dim(x))
  x
}

dim(poi.haolinju <- unique(filter(poi.base,grepl('好邻居便利|好邻居生活超市',name)))) #168 #194
dim(poi.711 <- unique(filter(poi.base,grepl('7-ELEVEn|7-11',name)))) #200 #231
dim(poi.haoke <- unique(filter(poi.base,grepl('昆仑好客',name)))) #152 #145
dim(poi.quanshi <- unique(filter(poi.base,grepl('全时',name)&(!grepl('全时汇',name))))) #238 #286
dim(poi.linjia <- unique(filter(poi.base,grepl('邻家',name)))) #95 #150
poi.jingkelong <- count.poi('京客隆')#197 #207
poi.chaoshifa <- count.poi('超市发')#198 #211
poi.kuaike <- count.poi('快客') #132
poi.wumei <- count.poi('物美便利店') #135
poi.luosen <- count.poi('罗森|lawson|LAWSON') #63
poi.bianlifeng <- count.poi('便利蜂') #46


