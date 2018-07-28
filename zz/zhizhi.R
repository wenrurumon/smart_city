
rm(list=ls())
setwd('/Users/wenrurumon/Documents/xmdata/zz')
library(data.table)
library(dplyr)
library(MASS)

d <- dir(patter='csv|key')
d <- d[c(1,2,3,6)]
f <- lapply(d,fread); names(f) <- d
f[[2]] <- dplyr::select(f[[2]],-V3,-V4)
colnames(f[[1]]) <- c('lon','lat','lo1','la1','lo2','la2','lo3','la3')
f[2:3] <- lapply(f[2:3],function(x){dplyr::select(x,
                                                  name, type, tel, locationx, locationy, addr, province, citycode, district, street, adcode
                                                  ,typecode, cityname, number, gpsx, gpsy, bdx, bdy
)})

#########################
#超市brand coding
data.poi <- do.call(rbind,f[2:3])
data.poi <- mutate(data.poi,address=paste(addr,name))
poi.base <- filter(data.poi,grepl('便利店|超市',type))
poi.base <- filter(poi.base,!grepl('易捷',name))

count.poi <- function(x,base=poi.base){
  x <- filter(base,grepl(x,name))
  print(dim(x))
  x
}

# cand <- readLines('品牌库.txt',encoding='UTF-8')
# test <- lapply(cand,count.poi)
# names(test) <- cand
# test <- (sapply(test,nrow))
# test[test>0]

#7-11 好客 全时 邻家 京客隆 超市发 快客 好邻居 物美 罗森
dim(poi.haolinju <- filter(poi.base,grepl('好邻居便利|好邻居生活超市',name))) #168
dim(poi.711 <- filter(poi.base,grepl('7-ELEVEn|7-11',name))) #200
dim(poi.haoke <- filter(poi.base,grepl('昆仑好客',name))) #152
dim(poi.quanshi <- filter(poi.base,grepl('全时',name)&(!grepl('全时汇',name)))) #238
dim(poi.linjia <- filter(poi.base,grepl('邻家',name))) #95
poi.jingkelong <- count.poi('京客隆')#197
poi.chaoshifa <- count.poi('超市发')#198
poi.kuaike <- count.poi('快客')
poi.wumei <- count.poi('物美便利店')
poi.luosen <- count.poi('罗森|lawson|LAWSON')
# dim(filter(data.poi,grepl('便利蜂',name)))
#coding to block
map <- f[[1]]
# map <- fread("beijing_unicomdata.csv")
getblock <- function(x){
  la <- x$bdx
  lo <- x$bdy
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
getblocks <- function(x,title=NULL){
  x <- (cbind(as.matrix(x),t(sapply(1:nrow(x),function(i){getblock(x[i,])}))))
  x <- data.table(apply(x[,1:3],2,paste),apply(x[,-1:-3],2,as.numeric))
}
# process
# poi.base <- getblocks(poi.base)
poi.mkt <- lapply(list(haolinju=poi.haolinju,s11=poi.711,haoke=poi.haoke,quanshi=poi.quanshi,
                       linjia=poi.linjia,jingkelong=poi.jingkelong,chaoshifa=poi.chaoshifa,
                       kuaike=poi.kuaike,wumei=poi.wumei,luosen=poi.luosen),getblocks)

#########################
#model setup general
load('poi_base.rda')
s <- dplyr::select
map2 <- s(map,lon,lat)
bbase <- poi.base %>% group_by(lon,lat) %>% summarise(base=n()) %>% filter(base>1&!is.na(lat)&!is.na(lon))
map2 <- data.table(map2,base=ifelse(is.na(bbase$base[match(paste(map2$lon,map2$lat),paste(bbase$lon,bbase$lat))]),0,bbase$base[match(paste(map2$lon,map2$lat),paste(bbase$lon,bbase$lat))]))
# udata <- f[[4]]
udata <- fread("beijing_unicomdata.csv")
udata_ptype <- udata %>% group_by(lon,lat) %>% summarise(
  n0=sum(n*(ptype==0)),
  n1=sum(n*(ptype==1)),
  n2=sum(n*(ptype==2)))
udata_ptype <- mutate(udata_ptype,p1=n1/(n0+n1+n2+1),p2=n2/(n0+n1+n2+1))
udata_local <- udata %>% group_by(lon,lat) %>% summarise(
  nloc=sum(n*(local=='Y')),
  nali=sum(n*(local=='N'))
)
udata_local <- mutate(udata_local,pali=nali/(nloc+nali+1))
map2 <- merge(map2,udata_ptype,by=c('lon','lat'))
map2 <- merge(map2,udata_local,by=c('lon','lat'))
map2 <- mutate(map2,bpp=base/(n0+n1+n2+1),bpp0=base/(n0+1),bpp1=base/(n1+1),bpp2=base/(n2+1))
#model setup project base
processb <- function(poi.x){
  b <- poi.x %>% group_by(lon,lat) %>% summarise(x=n())
  udata <- filter(map2,(base>1)|(paste(lon,lat)%in%paste(b$lon,b$lat)))
  udata <- data.table(udata,x=ifelse(is.na(b$x[match(paste(udata$lon,udata$lat),paste(b$lon,b$lat))]),0,b$x[match(paste(udata$lon,udata$lat),paste(b$lon,b$lat))]))
  b1 <- filter(udata,x>0)
  b2 <- filter(udata,x==0)
  list(b1=b1,b2=b2)
}
modelb <- function(poi.x,times=100){
  data <- processb(poi.x)
  b1 <- data$b1
  b2 <- data$b2
  modeli <- lapply(1:times,function(i){
    set.seed(i);seeds <- sample(1:nrow(b2),nrow(b1))
    print(i)
    mfile <- rbind(b1,b2[seeds,])
    mfile <- mfile[rowSums(is.na(mfile))==0,]
    mfile <- mfile[rowSums(abs(mfile)==Inf)==0,-1:-2]
    # model <- lda(x~n0+n1+n2+p1+p2+pali,data=mfile)
    model <- lda(x~.,data=mfile)
    rlt <- as.numeric(paste(predict(model,map2)$class))
    vali <- table(predict=predict(model)$class!='0',actual=mfile$x>0)
    list(sum(diag(vali))/sum(vali),rlt)
  })
  fit <- sapply(modeli,function(x){x[[1]]})
  rlt <- sapply(modeli,function(x){x[[2]]})
  list(fit=fit,rlt=rlt)
}

####################
#Our Score
load('store_score_rlt2.rda')

# rlt <- lapply(poi.mkt,modelb,times=1000)
# save(rlt,file='store_score2.rda')
# rlt2 <- sapply(rlt,function(x){
#   rowMeans(pnorm(scale(x[[2]])),na.rm=T)
# })
map.rlt <- data.table(dplyr::select(map2,lon,lat),rlt2)

x <- udata %>% group_by(lat,lon) %>% summarise(n0=sum(n*(ptype==0)),n1=sum(n*(ptype==1)),n2=sum(n*(ptype==2)))
x2 <- scale(as.matrix((log(x[,3:5]+1))))
x3 <- princomp(x2)
x3 <- x3$scores[,1]
x3 <- x3 * sign(mean(cor(x3,rowSums(x2))))
hist(x3)
cor(x3,x[,3:5])
x3 <- (x3 - min(x3))/max(x3 - min(x3))
tapply(x$n1,round(x3,1),range)
round(table(round(x3,1))/length(x3),2)

x3 <- x3*0.6 + 0.4
x3 <- cbind(dplyr::select(x,lat,lon),score=x3*100)

x3 <- merge(x3,map.rlt,by=c('lon','lat'))
score_map <- dplyr::select(x3,lon,lat)
score_duibiao <- dplyr::select(x3,-lon,-lat,-score)

score_base <- (dplyr::select(x3,score)-40)/60*40+40
score_duibiao <- apply(score_duibiao,2,function(x){
  (score_base$score) + x*20
})
cor(score_duibiao,score_base)
quantile(x3$score)
x3 <- cbind(dplyr::select(x3,lon,lat,score),score_duibiao)
# write.csv(x3,'base_score3.csv',row.names=F,quote=F)

cbind(tapply(rowSums(x[,3:5]),round(x3$score/10)*10,mean))



################
# duibiao moshi

u <- reshape2::dcast(udata, lon+lat~ptype+gender+age+local, value.var = "n", fill = 0)
u[is.na(u)] <- 0

m <- function(x){
  x <- merge(x,udata,by=c('lon','lat'))
  c(ptype=sum(filter(x,ptype=='2')$n)/sum(filter(x,ptype=='1')$n),
    local=sum(filter(x,local=='Y')$n)/sum(x$n),
    gender=sum(filter(x,gender=='M')$n)/sum(filter(x,gender=='F')$n),
    Y16 = sum(filter(x,substr(age,1,2)%in%c('16','19'))$n)/sum(x$n),
    Y25 = sum(filter(x,substr(age,1,2)%in%c('25','30'))$n)/sum(x$n),
    Y35 = sum(filter(x,substr(age,1,2)%in%c('35','40'))$n)/sum(x$n),
    Y45 = sum(filter(x,substr(age,1,2)%in%c('45','50','55','60','65','70'))$n)/sum(x$n))
}
m <- sapply(poi.mkt,m)

##################

rm(list=ls())
library(data.table)
library(dplyr)
setwd('/Users/wenrurumon/Documents/xmdata/zz')
map <- fread("北京市_20170901_bd09.key")
# test <- fread("V0110000_20180101.csv")
colnames(map) <- c('lon','lat','lo1','la1','lo2','la2','lo3','la3')
load("/Users/wenrurumon/Documents/xmdata/zz/project/hlj_mfile.rda")
load("/Users/wenrurumon/Documents/xmdata/zz/project/data_poi.rda")

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
    tmp <- mutate(map,l1=(la1-la)*(la2-la),l2=(lo1-lo)*(lo2-lo))
    tmp1 <- arrange(filter(tmp,l1<=0),l2)[1,]
    tmp2 <- arrange(filter(tmp,l2<=0),l1)[1,]
    if(is.na(tmp1$lon)&is.na(tmp1$lat)){
      return(c(NA,NA))
    }
    t1 <- tmp1$l1^2 - tmp2$l1^2
    t2 <- tmp1$l2^2 - tmp2$l2^2
    if((t1<0) & (t2<0)){return(tmp1[1:2])}
    if((t1>0) & (t2>0)){return(tmp2[1:2])}
    if((tmp1$l1+tmp1$l2)^2 > (tmp2$l1+tmp2$l2)^2){return(tmp2[1:2])}else{return(tmp1[1:2])}
  }else{
    tmp <- tmp[sqrt(tmp$l1^2+tmp$l2^2)==min(sqrt(tmp$l1^2+tmp$l2^2)),]
    return(tmp[1:2])
  }
}
getpoi <- function(x){
  la <- x[[2]]; lo <- x[[1]]
  if(is.na(la)){return(list(NULL,NULL))}
  tmap <- filter(map,lat==la&lon==lo)
  if(nrow(tmap)==0){tmp1<-NULL}else{
    tmp <- mutate(data.poi,l1=(tmap$la1-bdx)*(tmap$la2-bdx),l2=(tmap$lo1-bdy)*(tmap$lo2-bdy))
    tmp1 <- filter(tmp,l1<=0&l2<=0)
  }
  tmap <- filter(map,lat%in%(la+-1:1)&lon%in%(lo+-1:1)) %>% summarise(lo1=min(lo1),la1=min(la1),lo2=max(lo2),la2=max(la2))
  if(nrow(tmap)==0){tmp2 <- NULL}else{
    tmp <- mutate(data.poi,l1=(tmap$la1-bdx)*(tmap$la2-bdx),l2=(tmap$lo1-bdy)*(tmap$lo2-bdy))
    tmp2 <- filter(tmp,l1<=0&l2<=0)    
  }
  return(list(tmp1,tmp2))
}
poitype <- unique(sapply(strsplit(unique(data.poi$type),';'),function(x){x[[1]]}))
i <- 0
x.loc <- t(sapply(x.loc,function(x){
  print(i<<-i+1)
  getblock(x)
}))
x.poi <- lapply(1:nrow(x.loc),function(i){
  print(i)
  getpoi(x.loc[i,])
})

i <- 0
x.poi_count <- t(sapply(x.poi,function(x){
  print(i <<- i+1)
  if(is.null(x[[1]])){
    out1 <- 0; names(out1) <- 'na'
  } else{
    out1 <- table(sapply(strsplit(x[[1]]$type,';'),function(x){x[[1]]}))
  }
  if(is.null(x[[2]])){
    out2 <- 0; names(out2) <- 'na'
  } else{
    out2 <- table(sapply(strsplit(x[[2]]$type,';'),function(x){x[[1]]}))
  }  
  out <- c(out1[match(poitype,names(out1))],out2[match(poitype,names(out2))])
  names(out) <- paste0(rep(poitype,2),rep(1:2,each=length(poitype)))
  ifelse(is.na(out),0,out)
}))
x.poi_count <- cbind(mdata$code,x.poi_count)
temp <- x.poi_count[,grepl('1',colnames(x.poi_count))]
car.poi <- rowSums(temp[,grepl('车',colnames(temp)),drop=F])
stay.poi <- rowSums(temp[,grepl('地名|住宅',colnames(temp)),drop=F])
shop.poi <- rowSums(temp[,grepl('购物',colnames(temp)),drop=F])
rest.poi <- rowSums(temp[,grepl('餐饮',colnames(temp)),drop=F])
trans.poi <- rowSums(temp[,grepl('通行设施|交通设施服务|道路附属设施',colnames(temp)),drop=F])
edu.poi <- rowSums(temp[,grepl('科教文化服务',colnames(temp)),drop=F])
hos.poi <- rowSums(temp[,grepl('医疗保健服务',colnames(temp)),drop=F])
x.poi1 <- cbind(car.poi,stay.poi,shop.poi,rest.poi,trans.poi,edu.poi,hos.poi)
temp <- x.poi_count[,grepl('2',colnames(x.poi_count))]
car.poi <- rowSums(temp[,grepl('车',colnames(temp)),drop=F])
stay.poi <- rowSums(temp[,grepl('地名|住宅',colnames(temp)),drop=F])
shop.poi <- rowSums(temp[,grepl('购物',colnames(temp)),drop=F])
rest.poi <- rowSums(temp[,grepl('餐饮',colnames(temp)),drop=F])
trans.poi <- rowSums(temp[,grepl('通行设施|交通设施服务|道路附属设施',colnames(temp)),drop=F])
edu.poi <- rowSums(temp[,grepl('科教文化服务',colnames(temp)),drop=F])
hos.poi <- rowSums(temp[,grepl('医疗保健服务',colnames(temp)),drop=F])
x.poi2 <- cbind(car.poi,stay.poi,shop.poi,rest.poi,trans.poi,edu.poi,hos.poi)
colnames(x.poi2) <- paste0(colnames(x.poi2),2)
x.poi_count <- cbind(x.poi_count[,1],x.poi1,x.poi2)

mdata <- cbind(mdata,x.loc) %>% filter(!is.na(lon))
udata2 <- udata%>%group_by(lon,lat)%>%
  summarise(male=sum(n*(gender=='M')),female=sum(n*(gender=='F')),
            p0=sum(n*(ptype==0)),p1=sum(n*(ptype==1)),p2=sum(n*(ptype==2)),
            local=sum(n*(local=='Y')),nlocal=sum(n*(local=='N')))
tmp <- udata %>% group_by(lon,lat)%>% summarise(nlocal=sum(n*(local=='N')))
udata2$nlocal <- tmp$nlocal
udata3 <- udata %>% group_by(lon,lat,age) %>% summarise(n=sum(n))
udata3 <- reshape2::dcast(udata3,lon+lat~age,value.var='n',fill=0)
udata3 <- cbind(dplyr::select(udata3,lon,lat),y18=rowSums(udata3[,3:5]),y40=rowSums(udata3[,6:9]),y60=rowSums(udata3[,10:13]),y70=rowSums(udata3[,14:17]))
udata2 <- merge(udata2,udata3,by=c('lon','lat'))

m2 <- function(x){
  lo <- x$lon[[1]]
  la <- x$lat[[1]]
  dcenter <- as.matrix(filter(udata2,lon==lo&lat==la))
  if(nrow(dcenter)==0){
    dcenter <- rep(0,13)
  } else {
    dcenter <- dcenter[1,]
  }
  los <- lo+(-1:1)
  las <- la+(-1:1)
  dmove1 <- filter(udata2,(lon%in%los)&(lat%in%las))#750*750
  dmove1 <- colSums(as.matrix(dmove1)[,-1:-2,drop=F])
  names(dmove1) <- paste0(names(dmove1),"_1")
  los <- lo+(-2:2)
  las <- la+(-2:2)
  dmove2 <- filter(udata2,(lon%in%los)&(lat%in%las))#1250*1250
  dmove2 <- colSums(as.matrix(dmove2)[,-1:-2,drop=F])-dmove1
  names(dmove2) <- paste0(names(dmove2),"_2")
  dmove2 <- round(dmove2*(1000^2-750^2)/(1250*1250-750*750)+dmove1)
  dmove1 <- (dmove1-dcenter[-1:-2])*250*250/(750^2-250^2) + dcenter[-1:-2]
  c(dcenter,dmove1,dmove2)
}

mdata2 <- t(sapply(1:nrow(mdata),function(i){m2(mdata[i,])}))
k2 <- paste(mdata2[,1],mdata2[,2])
k1 <- paste(mdata$lon,mdata$lat)
test <- cbind(dplyr::select(mdata,-lon,-lat),mdata2)
test[is.na(test)] <- 0

colnames(x3) <- c('month','code','cat','sales','profit')
x3 <- x3 %>% group_by(code,cat) %>% summarise(sales=mean(sales),profit=mean(profit))
sales <- reshape2::dcast(x3,code~cat,value.var='sales',fill=0)
colnames(sales)[-1] <- paste0('sales',colnames(sales)[-1])
profit <- reshape2::dcast(x3,code~cat,value.var='profit',fill=0)
colnames(profit)[-1] <- paste0('profit',colnames(profit)[-1])
x3 <- cbind(sales,profit[,-1])

test <- cbind(test,x3[match(test[,1],x3[,1]),-1])
test <- cbind(test,x.poi_count[match(test$code,x.poi_count[,1]),-1])

mfile <- cbind(test,
               sales=rowSums(test[,grepl('sales',colnames(test))]),
               profit=rowSums(test[,grepl('profit',colnames(test))]))
raw <- mfile <- mutate(mfile,n250=male+female,n500=male_1+female_1,n1000=male_2+female_2)
mfile <- filter(mfile,n1000>100)
write.csv(mfile,'119store_hlj.csv',quote=T,row.names=F)

######################

storeinfo <- mfile[,1:8]
sales <- mfile[,grepl('sales|profit',colnames(mfile))]
sales <- sales[,which(colMeans(sales==0)<0.2)]
s1 <- sales[,grepl('sales',colnames(sales))]
s1[,-ncol(s1)] <- s1[,-ncol(s1)]/s1[,ncol(s1)]
sales[,grepl('sales',colnames(sales))] <- s1
s1 <- sales[,grepl('profit',colnames(sales))]
s1[,-ncol(s1)] <- s1[,-ncol(s1)]/s1[,ncol(s1)]
sales[,grepl('profit',colnames(sales))] <- s1

poi <- mfile[,c(76:89)]
unicom <- mfile[,c(9:41)]
unicom <- cbind(unicom,n250=unicom[,1]+unicom[,2],n500=rowSums(unicom[,12:13]),n1000=rowSums(unicom[,23:24]))
unicom[is.na(unicom)] <- 0

x <- (cbind(unicom,poi))[,colSums(is.na(scale(cbind(unicom,poi))))==0]
x[,1:11] <- x[,1:11]/rowSums(x[,1:2])
x[,12:22] <- x[,12:22]/rowSums(x[,12:13])
x[,23:33] <- x[,23:33]/rowSums(x[,23:24])
x[,4:5] <- x[,4:5]/rowSums(x[,4:5])
x[,15:16] <- x[,15:16]/rowSums(x[,15:16])
x[,26:27] <- x[,26:27]/rowSums(x[,26:27])
x[is.na(x)] <- 0

#####################

cuttest <- function(y){
  x1 <- x[,1:11]*x$n250
  x2 <- x[,12:22]*x$n500
  x3 <- x[,23:33]*x$n1000
  x4 <- dplyr::select(x,n250,n500,n1000)
  x5 <- x[,grepl('poi',colnames(x)),drop=F]
  out <- t(sapply((0:9),function(i){
    p <- i/10
    sel <- y>=quantile(y,p)
    c(colSums(x1[sel,])/sum(x$n250[sel]),colSums(x2[sel,])/sum(x$n500[sel]),colSums(x3[sel,])/sum(x$n1000[sel]),colMeans(x4[sel,]),colMeans(x5[sel,]),n=sum(sel),y=mean(y[sel]))
  }))
  x.out <- out
  x.coef <- apply(scale(out),2,function(o){
    x.coef <- coef(summary(lm(o~I(1:10))))[-1,]
    x.coef[1]*(x.coef[4]<=0.05)
  })
  list(out=x.out,coef=x.coef)
}
test <- apply(sales,2,cuttest)

out.sales <- test$sales$out
# out.sales <- test$sales14$out
bj <- colSums(udata2)[-1:-2]
bj[1:2] <- bj[1:2]/sum(bj[1:2])
bj[3] <- bj[3]/sum(bj[3:5])
bj[4:5] <- bj[4:5]/sum(bj[4:5])
bj[6:7] <- bj[6:7]/sum(bj[6:7])
bj[8:11] <- bj[8:11]/sum(bj[8:11])
out.sales <- t(rbind(out.sales,c(bj,rep(NA,ncol(out.sales)-length(bj)))))
colnames(out.sales) <- c((0:9)/10,'bj')
plot.ts(t(out.sales[grepl('female',row.names(out.sales)),-ncol(out.sales)]))


# write.csv(out.sales,'haolinju_quantile.csv')
# write.csv(sapply(test,function(x){x$coef}),'haolinju_coef.csv')

######################

