library(ggplot2)

load("mds_data.rda")
mds.data <- mds.data[-which(mds.data$model== "obs"),]

create_bool_clust_mat <- function(n, t){
    clus.dat <- mds.data[mds.data$t == t,]
    clus.dat[,c("X","Y")] <- scale(clus.dat[,c("X","Y")])
    clusters <- kmeans(clus.dat[,c("X","Y")],n)$cluster
    as.matrix(dist(clusters)) == 0
}

params <- expand.grid(n = 1:10, t = 1:max(mds.data$t))

trans_mats <- lapply(params$n, function(n){
    bool_mats <- lapply(params$t, function(t){
        create_bool_clust_mat(n, t)
    })
    Reduce(`+`, bool_mats) / length(params$t)
})


