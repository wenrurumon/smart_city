
rm(list=ls())
library(data.table)
library(dplyr)

f <- dir(pattern='.csv')
fs <- lapply(f,fread)
map <- fs[[1]]
fs <- fs[-1]

model <- function(x){
	key <- unique(x[,.(lat,lon)])
	mk <- map[city==x$city[1]]
	key <- data.table(key,
	lat1 = key$lat * mk$mlat + mk$slat,
	lon1 = key$lon * mk$mlon + mk$slon,
	lat2 = (key$lat+1) * mk$mlat + mk$slat,
	lon2 = (key$lon+1) * mk$mlon + mk$slon,
	lat3 = (key$lat+.5) * mk$mlat + mk$slat,
	lon3 = (key$lon+.5) * mk$mlon + mk$slon
	)
	list(x=x,key=key)
}

#i <- 0
x <- lapply(fs,function(x){
	#print(i<<-i+1)
	model(x)
})
test <- lapply(x,function(x){
	list(x=x$x[age!='NULL'] %>% group_by(date,ptype,city,lat,lon) %>% summarise(n=sum(n)),
		key=x$key)
})
names(test) <- f[-1]
test <- do.call(c,test)
names(test) <- gsub('.csv','',names(test))
for(i in 1:16){
	names(test) <- gsub(map$city[i],map$name[i],names(test))
}
for(i in 1:34){
	write.csv(test[[i]],names(test)[i],quote=F,row.names=F)
}

#########

x <- dir()[-1:-19]
for (i in paste('gzip',x)){system(i)}
