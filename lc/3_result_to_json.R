rm(list=ls())

library(data.table)
dir()
map <- fread('grid_map.csv')

sales <- fread("lc_bj_0410.txt")
x <- sales
colnames(x) <- c('dt','pt','ct','la','lo','lc','ge','ag','n')
x <- x[ag!='NULL'&lc!='NULL'&ge!='NULL']
xk <- unique(x[,.(la,lo)])
mk <- map[city==x$ct[1]]
xk <- xk[,c('lat','lon','lat1','lon1'):=
		list(la*mk$mlat+mk$slat,lo*mk$mlon+mk$slon,
			(la+1)*mk$mlat+mk$slat,(lo+1)*mk$mlon+mk$slon)]
xk <- xk[,c('lat2','lon2'):=list((lat+lat1)/2,(lon+lon1)/2)]
xk1 <- paste(xk$la,xk$lo)
x1 <- paste(x$la,x$lo)
key <- match(x1,xk1)
x <- data.table(x,key)[,!c('la','lo')]
xk <- data.table(1:nrow(xk),xk[,!c('la','lo')])
write.csv(x,'beijing_data.csv',quote=F,row.names=F)
write.csv(xk,'beijing_grid_map.csv',quote=F,row.names=F)

sales <- fread("lc_sh_0410.txt")
x <- sales
colnames(x) <- c('dt','pt','ct','la','lo','lc','ge','ag','n')
x <- x[ag!='NULL'&lc!='NULL'&ge!='NULL']
xk <- unique(x[,.(la,lo)])
mk <- map[city==x$ct[1]]
xk <- xk[,c('lat','lon','lat1','lon1'):=
		list(la*mk$mlat+mk$slat,lo*mk$mlon+mk$slon,
			(la+1)*mk$mlat+mk$slat,(lo+1)*mk$mlon+mk$slon)]
xk <- xk[,c('lat2','lon2'):=list((lat+lat1)/2,(lon+lon1)/2)]
xk1 <- paste(xk$la,xk$lo)
x1 <- paste(x$la,x$lo)
key <- match(x1,xk1)
x <- data.table(x,key)[,!c('la','lo')]
xk <- data.table(1:nrow(xk),xk[,!c('la','lo')])


###########

rm(list=ls())
library(data.table)
library(dplyr)
x <- fread('beijing_data.csv')%>%group_by(key,pt)%>%summarise(n=sum(n))
k <- fread('beijing_grid_map.csv')
k <- cbind(k[x$key][,.(lon2,lat2)],x$n,x$pt)
k0 <- k[V3==0]
k1 <- k[V3==1]
k2 <- k[V3==2]

t0 <- sapply(1:nrow(k0),function(i){
	i <- k0[i]
	paste('{','\'lng\':',i$lon2,',\'lat\':',i$lat2, ',\'count\':',i$V2,'}')
})
t0 <- paste('{\'dataArray\':[',paste(t0,collapse=','),']}') 
t1 <- sapply(1:nrow(k1),function(i){
	i <- k1[i]
	paste('{','\'lng\':',i$lon2,',\'lat\':',i$lat2, ',\'count\':',i$V2,'}')
})
t1 <- paste('{\'dataArray\':[',paste(t1,collapse=','),']}') 
t2 <- sapply(1:nrow(k2),function(i){
	i <- k2[i]
	paste('{','\'lng\':',i$lon2,',\'lat\':',i$lat2, ',\'count\':',i$V2,'}')
})
t2 <- paste('{\'dataArray\':[',paste(t2,collapse=','),']}') 

write(gsub('\'','"',t0),'t0.json')
write(gsub('\'','"',t1),'t1.json')
write(gsub('\'','"',t2),'t2.json')



