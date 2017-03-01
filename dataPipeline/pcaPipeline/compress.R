#!/usr/bin/env Rscript

## get command line arguments
args = commandArgs(trailingOnly=TRUE)
nc_files <- list.files(paste0("/accounts/grad/yoni/Documents/Stat222/",
                              "dataPipeline/pcaPipeline/cmip5-ng/"),
                       recursive = TRUE, full.names = TRUE)

## retrieve the variable passed by the commandline call
commandVar <- args[1]

varDat <- ldply(nc_files, function(nc){
    model <- strsplit(nc, "_")[[1]][3]
    ncin <- nc_open(nc)
    lon <- ncvar_get(ncin, "lon")
    lat <- ncvar_get(ncin, "lat")
    cVar <- ncvar_get(ncin, commandVar)
    ## loop through every lat/lon pair, compress the
    ## time series at that point, and output a data.frame
    ## of with the compressed data.
    ldply(1:length(lon), function(i){
        ldply(1:length(lat), function(j){
            series <- cVar[i,j,]
            ## series <- series[-1] - series[-length(series)]
            data.frame(Model = model,
                       Variable = commandVar,
                       lon = lon[i],
                       lat = lat[j],
                       varDts = var(series)) ## or var
        })
    })
})

## write the data to a csv file
write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
