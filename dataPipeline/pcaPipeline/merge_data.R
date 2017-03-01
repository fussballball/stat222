
## get all the data
compressedFiles <- list.files(paste0("/accounts/grad/yoni/Documents/Stat222/",
                                     "dataPipeline/pcaPipeline"),
                              pattern = "_compressed", full.names = TRUE)

pcaDat <- llply(compressedFiles, function(fname){
    cDat <- read.csv(fname)
    dcast(cDat[, -1], Model ~ Variable + lat + lon)
})

pcaDat <- Reduce(function(...) left_join(..., by = "Model"), pcaDat)

save(pcaDat, file = "pcaData.rda")

quit()

load("pcaData.rda")
library(ggplot2)
d <- dist(pcaDat[,-1]) # euclidean distances between the rows
fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim

x <- fit$points[,1]
y <- fit$points[,2]
plotDat <- data.frame(X = x, Y = y, names = pcaDat[,1])
plt <-ggplot(plotDat, aes(x = X, y = Y, shape = names, color = names)) +
    scale_shape_manual(values=seq(0,20)) + 
    geom_point()

ggsave(plt, filename = "varMDS.pdf")
