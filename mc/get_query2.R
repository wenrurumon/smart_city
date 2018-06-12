rm(list=ls())

f <- data.table::fread(dir(pattern='csv')[1])
url1 <- "http://124.65.126.42:30015/arcgis/rest/services/mcapi/MapServer/2/query?where=homeid%20=%20"
url2 <- "%20and%20city=%27nanjing%27%20and%20date_month=%27201706%27&outFields=*&f=pjson"

j <- 0
m <- function(x){
  print(paste(args,j<<-j+1))
  urli <- paste0(url1,x,url2)
  readLines(urli)
}

poi <- f$FNID
i <- as.numeric(cut(1:length(poi),20))

args <- commandArgs(trailingOnly=TRUE)
if(length(args)==0){args <- 1}

poi <- poi[i==args]
out <- lapply(poi,m)
save(out,file=paste0('nanjing2',args,'.rda'))

R CMD BATCH --no-save --no-restore '--args 1' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 2' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 3' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 4' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 5' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 6' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 7' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 8' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 9' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 10' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 11' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 12' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 13' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 14' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 15' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 16' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 17' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 18' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 19' q2_nanjing.R &
R CMD BATCH --no-save --no-restore '--args 20' q2_nanjing.R &
