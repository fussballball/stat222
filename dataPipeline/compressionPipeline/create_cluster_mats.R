##############################
## use mds.data to start
##############################
load("mds_data.rda")
mds.data <- mds.data[-which(mds.data$model== "obs"),]

#' create_bool_clust_mat
#'
#' creates a boolean matrix that indicates
#' if model i and model j were in the same
#' cluster at time t for cluster number n
#' @param n - number of clusters to use
#' @param t - time point to single out
#' @export
#' @examples'
create_bool_clust_mat <- function(n, t){
    ## clearly mds.data specific
    ## TODO: make general
    clus.dat <- mds.data[mds.data$t == t,] 
    clus.dat[,c("X","Y")] <- scale(clus.dat[,c("X","Y")])
    clusters <- kmeans(clus.dat[,c("X","Y")],n)$cluster
    as.matrix(dist(clusters)) == 0
}

##############################
## compute list of matrices
##############################

## create parameter data.frame to loop through
params <- expand.grid(n = 1:10, t = 1:max(mds.data$t))

## looping through parameters, create
## the boolean matrices, then reduce by
## the sum for each n
trans_mats <- lapply(params$n, function(n){
    bool_mats <- lapply(params$t, function(t){
        create_bool_clust_mat(n, t)
    })
    Reduce(`+`, bool_mats) / length(params$t)
})


