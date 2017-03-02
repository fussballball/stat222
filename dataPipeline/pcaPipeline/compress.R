#!/usr/bin/env Rscript

## get command line arguments
args = commandArgs(trailingOnly=TRUE)
nc_files <- list.files(paste0("/accounts/grad/yoni/Documents/Stat222/",
                              "dataPipeline/pcaPipeline/cmip5-ng/"),
                       recursive = TRUE, full.names = TRUE)

## retrieve the variable passed by the commandline call
commandVar <- args[1]
## should add to command args:
N <- 30 ## compress temporily to N vars
M <- 30 ## compress spatially to M vars


varDat <- ldply(nc_files, function(nc){
    model <- strsplit(nc, "_")[[1]][3]
    ncin <- nc_open(nc)
    lon <- ncvar_get(ncin, "lon")
    lat <- ncvar_get(ncin, "lat")
    cVar <- ncvar_get(ncin, commandVar)
    tLen <- length(cVar[1,1,])
    latLen <- length(lat)
    lonLen <- length(lon)
    cMat <- matrix(rep(NA, tLen * latLen * lonLen),
                   nrow = latLen * lonLen,
                   ncol = tLen)
    dims <- expand.grid(lons = 1:lonLen, lats = 1:latLen)

    ## flatten the vector
    for(i in 1:nrow(dims)) {
        cMat[i, ] <- cVar[dims$lons[i], dims$lats[i],]
    }
    
    ## perform two way pca:
    pcaTime <- prcomp(cMat, scale = TRUE, center = TRUE)[["x"]][,1:N]
    pcaSpace <- prcomp(t(pcaTime), scale = TRUE, center = TRUE)[["x"]][,1:M]
    ret <- data.frame(Model = model, as.list(as.vector(pcaSpace)))
    colnames(ret)[-1] <- paste0(commandVar, colnames(ret)[-1])
    ret
})

## write the data to a csv file
write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
