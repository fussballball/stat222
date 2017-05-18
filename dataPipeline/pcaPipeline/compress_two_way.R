#!/usr/bin/env Rscript

## load in helper functions
source("../../code/yoni/functions.R")

## get command line arguments
## retrieve the variable passed by the commandline call
args = commandArgs(trailingOnly=TRUE)
commandVar <- args[1] ## the variable we're computing on
N <- as.numeric(args[2]) ## compress temporily to N vars
M <- as.numeric(args[3]) ## compress temporily to M vars

nc_files <- list.files("cmip5-ng/", pattern = commandVar,
                       recursive = TRUE, full.names = TRUE)

varDat <- ldply(nc_files, function(nc){
    model <- strsplit(nc, "_")[[1]][3]
    tmp <- nc
    nc <- nc_open(nc)
    cMat <- flatten_model(ncvar_get(nc, commandVar))
    ## remove any na-values...
    indices <- which(is.na(cMat), TRUE)
    ind2 <- ind1 <- indices
    ind1[, 2] <- indices[, 2] - 1
    ind2[, 2] <- indices[, 2] + 1
    cMat[indices] <- (cMat[ind1] + cMat[ind2]) / 2
    ## perform two way pca:
    cMat <- try(tw_pca(t(cMat), N, M, TRUE, TRUE))
    if(identical(class(cMat),"try-error")){
        stop(paste0("the problematic model is: ", tmp))
    }
    compressedData <- as.list(as.vector(cMat))
    names(compressedData) <- paste0(commandVar, 1:length(compressedData))
    data.frame(Model = model, compressedData)
})

## write the data to a csv file
write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
