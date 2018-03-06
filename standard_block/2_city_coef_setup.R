
library(geosphere)

options(digits=22)
x <- '39.588558403090445 115.85861214160138 40.66312427234367 117.2424039947548'
x <- as.numeric(strsplit(x,' ')[[1]])

xm <- (x[1:2]+x[3:4])/2
latdist <- distm(c(xm[2],x[1]),c(xm[2],x[3]))
londist <- distm(c(x[2],xm[1]),c(x[4],xm[1]))

giv <- c(lon = (x[4] - x[2])/londist * 200,lat = (x[3] - x[1])/latdist * 200)
gsp <- x[1:2]

paste('ceil((weighted_centroid_lat -',gsp[1],')/',giv[1],') as lat2, ceil((weighted_centroid_lon -',gsp[2],')/',giv[2],') as lon2')
