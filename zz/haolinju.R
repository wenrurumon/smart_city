
rm(list=ls())
load('hlj_mfile.rda')

library(openxlsx)
setwd('project')
f <- function(x,i){
  x <- try(read.xlsx(x,i))
  print(i)
  if(class(x)=="try-error"){
    print('close')
    return(NA)
  }else{
    x
  }
}
x1 <- f("好邻居基础数据.xlsx",1)
x2 <- f("好邻居基础数据.xlsx",2)
x3 <- f("好邻居基础数据.xlsx",3)
x4 <- f("好邻居基础数据.xlsx",4)

colnames(x2) <- c('month','code','psd')
x2 <- x2 %>% group_by(code) %>% summarise(psd=mean(psd))
x1 <- filter(x1,code%in%x2$code)
mdata <- merge(x1,x2,by=c('code'))

x.loc <- lapply(strsplit(x1$location,','),as.numeric)
getblock <- function(x){
  la <- x[1]
  lo <- x[2]
  tmp <- mutate(map,l1=(la1-la)*(la2-la),l2=(lo1-lo)*(lo2-lo))
  tmp <- filter(tmp,l1<=0&l2<=0)
  if(nrow(tmp)==1){
    return(tmp[1:2])
  }else if(nrow(tmp)==0){
    return(c(NA,NA))
  }else{
    tmp <- tmp[sqrt(tmp$l1^2+tmp$l2^2)==min(sqrt(tmp$l1^2+tmp$l2^2)),]
    return(tmp[1:2])
  }
}
x.loc <- t(sapply(x.loc,getblock))
mdata <- cbind(mdata,x.loc)
mdata <- merge(mdata,udata,by=c('lon','lat'))

#Local%
x <- cbind(
  udata %>% group_by(local) %>% summarise(bj=sum(n)),
  (mdata %>% group_by(local) %>% summarise(hlj=sum(n)))[,2,drop=F]
)
x <- rbind(x,cbind(local='Y%',round(x[2,-1]/colSums(x[,-1])*100,2)))
cbind(x,idx=(x[,3]/x[,2]))

#Gender%
x <- cbind(
  udata %>% group_by(gender) %>% summarise(bj=sum(n)),
  (mdata %>% group_by(gender) %>% summarise(hlj=sum(n)))[,2,drop=F]
)
x <- rbind(x,cbind(gender='M/F',round(x[2,-1]/x[1,-1],2)))
cbind(x,idx=(x[,3]/x[,2]))

#Ptype%
x <- cbind(
  udata %>% group_by(ptype) %>% summarise(bj=sum(n)),
  (mdata %>% group_by(ptype) %>% summarise(hlj=sum(n)))[,2,drop=F]
)
x <- rbind(x,cbind(ptype='2/1',round(x[3,-1]/x[2,-1]*100,2)))
cbind(x,idx=(x[,3]/x[,2]))

#

