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
tw_pca <- function(mat, N, M, .center, .scale){
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

#' fig
#'
#' A function for captioning and referencing images. taken from
#' http://tinyurl.com/zz7k4rh
#' @param NONE
#' @keywords
#' @export
#' @examples ```{r cars, echo=FALSE, fig.cap=fig$cap("cars",
#'           "Here you see some interesting stuff about cars and such.")}
#'            plot(cars)
#'           ```
#'            What you always wanted to know about cars is shown in
#'            figure `r fig$ref("cars")`
fig <- local({
    i <- 0
    ref <- list()
    list(
        cap=function(refName, text) {
            i <<- i + 1
            ref[[refName]] <<- i
            paste("Figure ", i, ": ", text, sep="")
        },
        ref=function(refName) {
            ref[[refName]]
        })
})
