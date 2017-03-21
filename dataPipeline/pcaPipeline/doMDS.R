library(ggplot2)

load("pcaData.rda")

d <- dist(pcaDat[,-1]) # euclidean distances between the rows
fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim

x <- fit$points[,1]
y <- fit$points[,2]
plotDat <- data.frame(X = x, Y = y, names = pcaDat[,1])

plt <- ggplot(plotDat, aes(x = X, y = Y, shape = as.factor(names),
                           color = as.factor(names))) +
    scale_shape_manual(values=seq(0,20)) + 
    geom_point()

ggsave(plt, filename = paste0("MDS", Sys.Date(), ".pdf"))
