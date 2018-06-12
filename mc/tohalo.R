
rm(list=ls())
library(data.table)
library(dplyr)
x <- fread('q2_xuzhou.csv')
objectid <- x$objectid
city <- x$city
consumeid <- x$consumeid
create_time <- paste(Sys.time())
date_month <- x$date_month
homeid <- x$homeid
jobid <- x$jobid
pop_num <- x$pop_num
update_time <- paste(Sys.time())
y <- cbind(objectid,city,consumeid,create_time,date_month,homeid,jobid,pop_num,update_time)
map <- fread('xuzhou_grid.csv')
options(digits=17)
colnames(map) <- c('FNID','city','wkt')
p <- map$wkt
p <- strsplit(gsub('MULTIPOLYGON |\\(|\\)','',p),' |,')
p <- do.call(rbind,p)[,-1:-4*3]
p <- apply(p,2,as.numeric)
p2 <- t(
  apply(p,1,function(x){
    x <- c(range(x[c(1,3,5,7,9)]),range(x[c(1,3,5,7,9)+1]))
    c(x[c(1,3)],x[c(2,4)])
  })
)
colnames(p2) <- strsplit('ext_min_x,ext_min_y,ext_max_x,ext_max_y',',')[[1]]
map <- cbind(dplyr::select(map,FNID,city),p2)

write.csv(x,'q2_xuzhou_x.csv',quote=F,row.names=F)
write.csv(map,'q2_xuzhou_map.csv',quote=F,row.names=F)
