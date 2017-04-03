#' flatten_model
#'
#' takes a netcdf object (of a single, one-dimensional variable) and
#' flattens the tensor data into a matrix
#' @param ncin - the netcdf obj to flatten
#' @param Var - the name of the variable
#' @export
flatten_model <- function(cVar){
    ## get index dimesions
    tLen <- dim(cVar)[3]
    latLen <- dim(cVar)[2]
    lonLen <- dim(cVar)[1]
    ## create matrix skeleton
    cMat <- matrix(NA,
                   nrow = latLen * lonLen,
                   ncol = tLen)
    dims <- expand.grid(lons = 1:lonLen, lats = 1:latLen)
    ## flatten the tensor
    for(i in 1:nrow(dims)) {
        cMat[i, ] <- cVar[dims$lons[i], dims$lats[i],]
    }
    ## return the matrix
    cMat
}

#' tw_pca
#'
#' performs "two-way" pca on a matrix, currently does not
#' make any checks, so be careful when using!
#' @param mat - XxY matrix to compress
#' @param N - number to compress to in Y
#' @param M - number to compress to in X
#' @export
tw_pca <- function(mat, N, M, .center = TRUE, .scale = TRUE){
    mat <- prcomp(mat, scale = .scale, center = .center)[["x"]][,1:N]
    prcomp(t(mat), scale = .scale, center = .center)[["x"]][,1:M]
}


#' down_filter
#'
#' averages grid points in the simplest way possible
#' @param ncin - the netcdf object to down filter
#' @param Var - the desired variable in that object
#' @param N - the sqrt of the cell-count reduction
#' @export
down_filter <- function(cVar, N){
    ## get index dimesions
    tLen <- dim(cVar)[3]
    latLen <- dim(cVar)[2]
    lonLen <- dim(cVar)[1]
    ## creat new lat, lons, and tensor:
    nlon <- seq(1, lonLen, by = N)
    nlat <- seq(1, latLen, by = N)
    nVar <- array(NA, dim = c(length(nlon) - 1, length(nlat) - 1, tLen))
    ## loop through every group of N points and average:
    for(i in 1:(length(nlon) - 1)){
        for(j in 1:(length(nlat) - 1)){
            ith <- nlon[i]
            jth <- nlat[j]
            nVar[i, j, ] <- apply(cVar[ith:(ith+N), jth:(jth+N), ], 3, mean)
            if(any(is.na(nVar[i,j,]))){
                warning("i and j are NA'd")
            }
        }
    }
    nVar
}

#' plot_scatter_mat
#'
#' plot a scatter matrix of vars in a df. I encourage
#' scaling before using, though it shouldn't matter.
#' @param df - dataframe with vars of interest
#' @export
plot_scatter_mat <- function(df){
## from:
## https://www.r-bloggers.com/how-to-display-scatter-plot-matrices-with-r-and-lattice/
    splom(df,
          panel=panel.hexbinplot,
          diag.panel = function(x, ...){
              yrng <- current.panel.limits()$ylim
              d <- density(x, na.rm=TRUE)
              d$y <- with(d, yrng[1] + 0.95 * diff(yrng) * y / max(y) )
              panel.lines(d)
              diag.panel.splom(x, ...)
          },
          lower.panel = function(x, y, ...){
              panel.hexbinplot(x, y, ...)
              panel.loess(x, y, ..., col = 'red')
          },
          pscale=0, varname.cex=0.7
          )
}

#' coll_diff
#'
#' do diff on a column of a dataframe
#' @param df dataframe of interest
#' @param col name of column to diff
#' @export
col_diff <- function(df, col){
    df[, paste0(col, "_diff")] <- c(NA, diff(df[,col]))
    df
}
