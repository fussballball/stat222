library(ncdf4)
library(plyr)
library(digest)
library(ggplot2)

nc_files <- list.files("~/Documents/Stat222/cmip5-ng/",
                       recursive = TRUE, full.names = TRUE)

tasDat <- llply(nc_files, function(nc){
    ncin <- nc_open(nc)
    lon <- ncvar_get(ncin, "lon")
    lat <- ncvar_get(ncin, "lat")
    tas <- ncvar_get(ncin, "tas")
    list(tas = tas, lon = lon, lat = lat)
})

dims <- dim(tasDat[[1]][[1]])

## pca attempt:
## Warning, this takes a very long time
pcaDat <- ldply(tasDat, function(tasSet){
    lons <- tasSet[["lon"]]
    lats <- tasSet[["lat"]]
    tas <- tasSet[["tas"]]
    name <- digest(tasSet)
    ldply(1:dims[1], function(i){
        ldply(1:dims[2], function(j){
            ts <- as.data.frame(llply(tas[i,j,], function(x) x))
            data.frame(id = name, ts, lon = lons[i], lat = lats[j])
        })
    })
})

d <- dist(pcaDat[,-1]) # euclidean distances between the rows
fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim
fit # view results

# plot solution 
x <- fit$points[,1]
y <- fit$points[,2]
plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2", 
  main="Metric		    MDS",		 type="n")
text(x, y, labels = pcaDat[,1], cex=.7)