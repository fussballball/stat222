
## get all the data
compressedFiles <- list.files(paste0("~/Documents/Stat222/stat222/",
                                     "dataPipeline/pcaPipeline"),
                              pattern = "_compressed", full.names = TRUE)

pcaDat <- llply(compressedFiles, function(fname){
    cDat <- read.csv(fname)
    dcast(cDat, Model ~ Variable + lat + lon)
})

pcaDat <- do.call(cbind, pcaDat)

save(pcaDat, "pcaData.rda")
