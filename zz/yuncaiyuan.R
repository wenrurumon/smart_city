
rm(list=ls())
setwd('/Users/wenrurumon/Documents/xmdata/zz/project')
load('ycy.rda')
library(MASS)
library(data.table)
library(dplyr)
library(openxlsx)
poi.fs <- select(raw.poi2,adcode,typecode,lon,lat,typelabel)
raw.poi2 <- read.xlsx('/Users/wenrurumon/Downloads/2018济南poi.xlsx',1)
raw.poi2 <- data.table(raw.poi2,select(poi.fs,lon,lat,typelabel))
store.poi <- filter(raw.poi2,typelabel=='shop')

######################
# Macro
######################

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

######################
# Data Processing
######################

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

j <- 0
model <- function(t1,samples=10){
  print(j<<-j+1)
  t1.key <- paste(t1$lon,t1$lat)
  ref.key <- map.key[!map.key%in%t1.key]
  temp <- lapply(1:samples,function(i){
    # print(i)
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

system.time(test <- lapply(ta,model,samples=10000))
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
colnames(chain_score)[ncol(chain_score)] <- 'bae'
ta.data <- sapply(ta,function(t1){
  t1.key <- paste(t1$lon,t1$lat)
  t1.udata <- colMeans(udata[match(t1.key,map.key)])
  t1.udata
})
colnames(ta.data) <- c('孟鑫','陶鲁','统一银座','华联鲜超','忠力超市','橙子便利','明天连锁','倍全')[c(1:4,8)]
write.csv(chain_score,'chain_score.csv',row.names=F)
write.csv(ta.data,'chain_basic.csv')

