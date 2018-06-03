

f <- data.table::fread(dir()[1])
url1 <- "http://124.65.126.42:30015/arcgis/rest/services/mcapi/MapServer/3/query?where=%20grid_id%20=%20"
url2 <- "%20and%20city=%27nanjing%27%20and%20date_month=%27201706%27&outFields=*&f=pjson"

m <- function(x){
  urli <- paste0(url1,x,url2)
  readLines(urli)
}

poi <- f$FNID
i <- as.numeric(cut(1:length(poi),20))

args <- 
