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
    tMax <- length(cVar[1,1,])
    cMat <- matrix(rep(NA, tMax), nrow = 1, ncol = tMax)
    # flatten the tensor
    for(i in 1:length(lon)){
        for(j in 1:length(lat)){
            cMat <- rbind(cMat, cVar[i,j,])
        }
    }

    ## perform two way pca:
    pca1 <- prcomp(cMat, scale = TRUE, center = TRUE)[["x"]][,1:N]
    pca2 <- prcomp(t(pca1), scale = TRUE, center = TRUE)[["x"]][,1:M]
    ret <- data.frame(Model = model, as.list(as.vector(pca2)))
    colnames(ret)[-1] <- paste0(commandVar, colnames(ret)[-1])
    ret
})

## write the data to a csv file
write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
