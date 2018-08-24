
rm(list=ls())
setwd('E:\\xmandata\\zhizhi\\jinan\\data')
library(MASS)
library(data.table)
library(dplyr)
raw <- lapply(dir(pattern='data'),fread)

raw.poi <- select(raw[[1]],-V1)
raw.poi2 <- raw[[2]]
raw.profile <- select(raw[[4]],-V1)
raw.profile[raw.profile==""] <- NA
store.poi <- filter(raw.poi2,typelabel=='shop')
store.poi.key <- unique(paste(store.poi$lon, store.poi$lat))
raw.poi.key <- paste(raw.poi$lon,raw.poi$lat)

##################################
# Macro
##################################

qpca <- function(A,rank=0){
  A <- scale(A)
  A.svd <- svd(A)
  if(rank==0){
    d <- A.svd$d
  } else {
    d <- A.svd$d-A.svd$d[min(rank+1,nrow(A),ncol(A))]
  }
  d <- d[d > 1e-10]
  r <- length(d)
  prop <- d^2; prop <- cumsum(prop/sum(prop))
  d <- diag(d,length(d),length(d))
  u <- A.svd$u[,1:r,drop=F]
  v <- A.svd$v[,1:r,drop=F]
  x <- u%*%sqrt(d)
  y <- sqrt(d)%*%t(v)
  z <- x %*% y
  rlt <- list(rank=r,X=x,Y=y,Z=x%*%y,prop=prop)
  return(rlt)
}

checkchain <- function(x){
  filter(store.poi,grepl(x,name))
}

##################################
# 250*250
##################################

sum2 <- function(x){
  sum(as.numeric(x),na.rm=T)
}
p1 <- raw.profile %>% group_by(lat,lon) %>% summarise(
  np1=sum2((ptype==1)*n),np2=sum2((ptype==2)*n),np0=sum2((ptype==0)*n)
)
p2 <- raw.profile %>% filter(ptype>0) %>% group_by(lon,lat) %>% summarise(
  nmale=sum2((gender=='M')*n),nfemale=sum2((gender=='F')*n)
)
p3 <- raw.profile %>% filter(ptype>0) %>% group_by(lon,lat) %>% summarise(
  nlocal=sum2((iscore=='Y')*n),nalien=sum2((iscore=='N')*n)
)
p4 <- raw.profile %>% filter(ptype>0) %>% group_by(lon,lat,age) %>% summarise(n=sum2(n))
p4$age2 <- 0
p4$age2[(substr(p4$age,1,2) %in% sort(substr(unique(p4$age),1,2))[c(1:3,14)])] <- 18
p4$age2[(substr(p4$age,1,2) %in% sort(substr(unique(p4$age),1,2))[c(4:7)])] <- 40
p4$age2[(substr(p4$age,1,2) %in% sort(substr(unique(p4$age),1,2))[c(8:11)])] <- 60
p4$age2[(substr(p4$age,1,2) %in% sort(substr(unique(p4$age),1,2))[c(12,13,15)])] <- 100
p4 <- p4 %>% group_by(lon,lat) %>% summarise(
  n18 = sum2((age2==18)*n),n40 = sum2((age2==40)*n),n60 = sum2((age2==60)*n),n100 = sum2((age2==100)*n)
)

udata <- merge(p1,p2,by=c('lon','lat'))
udata <- merge(udata,p3,by=c('lon','lat'))
udata <- merge(udata,p4,by=c('lon','lat'))
udata <- merge(udata,raw.poi,by=c('lon','lat'))

##################################
# 750*750
##################################

nrow(udata)
udata2 <- t(sapply(1:nrow(udata),function(i){
  print(i)
  r <- udata[i,]
  r <- colSums(select(filter(udata,(lon%in%(r$lon+(-1:1)))&(lat%in%(r$lat+(-1:1)))),-lon,-lat))
  r
}))
colnames(udata2) <- paste0(colnames(udata2),'_750')
udata <- data.table(udata,udata2)

######################
# ModelFile
######################

store.poi <- filter(raw.poi2,typelabel=='shop')
map <- select(udata,lon,lat)
map.key <- paste(map$lon,map$lat)
udata <- select(udata,-lon,-lat)
fdata <- data.table(udata,udata2)
fdata.pca <- qpca(fdata)
fdata <- fdata.pca$X[,1:which(fdata.pca$prop>=.95)[1],drop=F]
fdata.test <- data.frame(y=NA,fdata)
ta <- c('孟鑫','陶鲁','统一银座','华联鲜超','忠力超市','橙子便利','明天连锁','倍全')[c(1:4,8)]
ta <- lapply(ta,checkchain)
bscore <- pnorm(scale(sign(cor(udata$np1,fdata[,1]))*fdata[,1]))

#####################
# Model
#####################

model <- function(t1,samples=10){
  t1.key <- paste(t1$lon,t1$lat)
  ref.key <- map.key[!map.key%in%t1.key]
  temp <- lapply(1:samples,function(i){
    ri.key <- sample(ref.key,length(t1.key))
    sel <- c(match(t1.key,map.key),match(ri.key,map.key))
    y.sel <- rep(c(1,0),each=length(t1.key))
    fdata.sel <- data.frame(y=y.sel,fdata[sel,,drop=F])
    model.sel <- lda(y~.,data=fdata.sel)
    fit <- sum(diag(table(predict(model.sel)$class,y.sel)))/length(y.sel)
    rlt <- as.numeric(paste(predict(model.sel,fdata.test)$class))
    list(fit=fit,rlt=rlt)
  })
  fit <- sapply(temp,function(x){x$fit})
  rlt <- rowMeans(sapply(temp,function(x){x$rlt}))
  list(fit=fit,rlt=rlt)
}

system.time(test <- lapply(ta,model,samples=10))
prlt <- test
prlt.fit <- sapply(prlt,function(x){x$fit})
prlt.rlt <- sapply(prlt,function(x){x$rlt})
save(prlt,file='ycy_rlt_1000.rda')

#####################
# Result
#####################

chain_score <- sapply(prlt,function(x){(x$rlt*40+bscore*60)/100*50+40})
colnames(chain_score) <- c('孟鑫','陶鲁','统一银座','华联鲜超','忠力超市','橙子便利','明天连锁','倍全')[c(1:4,8)]
chain_score <- data.table(map,chain_score,base=40+50*bscore)
colnames(chain_score)[ncol(chain_score)] <- 'base'
ta.data <- sapply(ta,function(t1){
  t1.key <- paste(t1$lon,t1$lat)
  t1.udata <- colMeans(udata[match(t1.key,map.key)])
  t1.udata
})
colnames(ta.data) <- c('孟鑫','陶鲁','统一银座','华联鲜超','忠力超市','橙子便利','明天连锁','倍全')[c(1:4,8)]
write.csv(chain_score,'chain_score.csv',row.names=F)
write.csv(ta.data,'chain_basic.csv')

  
