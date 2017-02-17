#!/usr/bin/env Rscript

## get command line arguments
args = commandArgs(trailingOnly=TRUE)

nc_files <- list.files("~/Documents/Stat222/cmip5-ng/",
                       recursive = TRUE, full.names = TRUE)

## retrieve the variable passed by the commandline call
commandVar <- args[1]

varDat <- ldply(nc_files, function(nc){
    name <- digest(nc)
    ncin <- nc_open(nc)
    lon <- ncvar_get(ncin, "lon")
    lat <- ncvar_get(ncin, "lat")
    cVar <- ncvar_get(ncin, commandVar)
    ldply(1:length(lon), function(i){
        ldply(1:length(lat), function(j){
            series <- cVar[i,j,]
            ddt_series <- series[-1] - series[-length(series)]
            data.frame(id = name,
                       variable = commandVar,
                       lon = lon[i],
                       lat = lat[i],
                       varDts = var(ddt_series))
        })
    })
})

write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
