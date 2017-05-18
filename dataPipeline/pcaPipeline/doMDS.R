args = commandArgs(trailingOnly=TRUE)

## load in the merged data
load("pcaData.rda")

## scale and center the data
d <- scale(pcaDat[,-c(1,2)])

d <- dist(d) # euclidean distances between the rows
fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim

x <- fit$points[,1]
y <- fit$points[,2]
plotDat <- data.frame(X = x, Y = y, names = pcaDat[,2])

save(plotDat, file = paste0("mdsData_", args[1], "_",
                args[2], ".rda"))

plt <- ggplot(plotDat, aes(x = X, y = Y, shape = as.factor(names),
                           color = as.factor(names))) +
    scale_shape_manual(values=seq(0,20)) + 
    geom_point()

ggsave(plt, filename = paste0("MDS_", args[1], "_",
                args[2], "_", Sys.Date(), ".pdf"))
