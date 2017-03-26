#!/usr/bin/env Rscript

## load in helper functions
source("../../code/yoni/functions.R")

## get command line arguments
## retrieve the variable passed by the commandline call
args = commandArgs(trailingOnly=TRUE)
commandVar <- args[1] ## the variable we're computing on
N <- as.numeric(args[2]) ## compress temporily to N vars

nc_files <- list.files("cmip5-ng/", pattern = commandVar,
                       recursive = TRUE, full.names = TRUE)

varDat <- ldply(nc_files, function(nc){
    ## test:
    ## nc <- "cmip5-ng//tas/tas_mon_CESM1-CAM5_historicalGHG_r1i1p1_g025.nc"
    model <- strsplit(nc, "_")[[1]][3]
    nc <- nc_open(nc)
    tmp <- ncvar_get(nc, commandVar)
    
    ## remove the following time points (they're missing for some
    ## models...)
    cMat <- flatten_model(tmp[ , , -c(1069:1091)])
    
    ## remove any na-values...
    indices <- which(is.na(cMat), TRUE)
    ind2 <- ind1 <- indices
    ind1[, 2] <- indices[, 2] - 1
    ind2[, 2] <- indices[, 2] + 1
    cMat[indices] <- (cMat[ind1] + cMat[ind2]) / 2

    ## one way pca:xs
    cMat <- try(prcomp(cMat)[["x"]][,1:N])
    if(identical(class(cMat),"try-error")){
        stop(paste0("there is a problem with model ", tmp))
    }

    ## string the data out
    compressedData <- as.list(as.vector(cMat))
    names(compressedData) <- paste0(commandVar, 1:length(compressedData))
    data.frame(Model = model, compressedData)
}, .progress = "text")

## write the data to a csv file
write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
