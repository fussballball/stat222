#!/usr/bin/env Rscript

## load in helper functions
source("../../code/yoni/functions.R")

## get command line arguments
args = commandArgs(trailingOnly=TRUE)
nc_files <- list.files("cmip5-ng/", recursive = TRUE, full.names = TRUE)

## retrieve the variable passed by the commandline call
commandVar <- args[1]
## should add to command args:
N <- 4 ## compress temporily to N vars
M <- 2 ## compress temporily to M vars

varDat <- ldply(nc_files, function(nc){
    model <- strsplit(nc, "_")[[1]][3]
    nc <- nc_open(nc)
    cMat <- flatten_model(ncvar_get(nc, commandVar))
    ## perform two way pca:
    cMat <- tw_pca(t(cMat), N, M, TRUE, TRUE)
    compressedData <- as.list(as.vector(cMat))
    names(compressedData) <- paste0(commandVar, 1:length(compressedData))
    data.frame(Model = model, compressedData)
})

## write the data to a csv file
write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
