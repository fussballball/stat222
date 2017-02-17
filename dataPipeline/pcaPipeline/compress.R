#!/usr/bin/env Rscript

## get command line arguments
args = commandArgs(trailingOnly=TRUE)

library(ncdf4)
library(plyr)
library(digest)
library(ggplot2)

nc_files <- list.files("~/Documents/Stat222/cmip5-ng/",
                       recursive = TRUE, full.names = TRUE)

commandVar <- args[1]

tasDat <- ldply(nc_files, function(nc){
    name <- digest(nc)
    ncin <- nc_open(nc)
    lon <- ncvar_get(ncin, "lon")
    lat <- ncvar_get(ncin, "lat")
    tas <- ncvar_get(ncin, "tas")
    ldply(1:length(lon), function(i){
        ldply(1:length(lat), function(j){
            series <- tas[i,j,]
            ddt_series <- series[-1] - series[-length(series)]
            data.frame(id = name,
                       variable = commandVar,
                       lon = lon[i],
                       lat = lat[i],
                       var_dts = var(ddt_series))
        })
    })
})

write.csv(tasDat, file = paste0(commandVar,"_compressed.csv"))
