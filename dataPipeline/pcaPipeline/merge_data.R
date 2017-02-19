
## get all the data
compressedFiles <- list.files(paste0("~/Documents/Stat222/stat222/",
                                     "dataPipeline/pcaPipeline"),
                              pattern = "_compressed", full.names = TRUE)

pcaDat <- llply(compressedFiles, function(fname){
    cDat <- read.csv(fname)
    dcast(cDat[, -1], Model ~ Variable + lat + lon)
})

pcaDat <- Reduce(function(...) left_join(..., by = "Model"), pcaDat)

save(pcaDat, file = "pcaData.rda")

quit()
