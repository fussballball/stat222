#!/usr/bin/env Rscript

## load in helper functions
source("../../code/yoni/functions.R")

## get command line arguments
args = commandArgs(trailingOnly=TRUE)
nc_files <- list.files("cmip5-ng/"), recursive = TRUE, full.names = TRUE)

## retrieve the variable passed by the commandline call
commandVar <- args[1]
## should add to command args:
N <- 30 ## compress temporily to N vars
M <- 30 ## compress spatially to M vars


varDat <- ldply(nc_files, function(nc){
    model <- strsplit(nc, "_")[[1]][3]
    cMat <- flatten_model(nc_open(nc))
    ## perform two way pca:
    cMat <- tw_pca(cMat, N, M, TRUE, TRUE)
    ret <- data.frame(Model = model, as.list(as.vector(cMat)))
    colnames(ret)[-1] <- paste0(commandVar, colnames(ret)[-1])
    ret
})

## write the data to a csv file
write.csv(varDat, file = paste0(commandVar,"_compressed.csv"))

quit()
