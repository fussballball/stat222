##############################
## creates distance matrices
## at each t for a single
## variable, scenario,
## ensemble triple
##############################

## get params passed from shell script
## should be in order: scenario ensemble variable
args = commandArgs(trailingOnly=TRUE)
scenario <- args[1]
ensemble <- args[2]
var <- args[3]

## the location where data has been loaded
path <- "/accounts/grad/yoni/Documents/Stat222/data/cmip5-ng/"

####################
## Assemble data
####################
var <- "rlutcs"
var.files <- list.files(paste0(path, var), full.names = TRUE)
model.data <- ldply(var.files, function(var.file){
    model <- strsplit(var.file, "_")[[1]][3]
    nc <- nc_open(var.file)
    data <- flatten_model(ncvar_get(nc, var))
    data <- t(data)
    ## de-season the data:
    data <- data[,2:ncol(data)] - data[,1:(ncol(data) - 1)]
    data <- as.data.frame(data)
    colnames(data) <- paste0(var, 1:ncol(data))
    data[,1:1631] 
    data$model <- model
    data$t <- 1:nrow(data)
    ## The simulations were run for different lengths
    ## so take the min-length for comparison
    data
}, .progress = "text")

######################
## make dist matrices
######################
dist.data <- llply(unique(model.data$t), function(t){
    ## filter down to time t and keep track of
    ## the data source
    data <- model.data[model.data$t == t, ]
    sources <- data$model
    ## Keep only complete cases
    i <- sapply(colnames(data), function(col){
        all(!is.na(data[,col]))
    })
    data <- data[, i]
    ## remove model and t columns
    mod.col <- grep("model", colnames(data))
    t.col <- grep("t$", colnames(data))
    data <- data[, -c(t.col, mod.col)]
    ## scale and center the data
    data <- scale(data, scale = TRUE, center = TRUE)
    ## perform MDS
    data <- as.matrix(dist(data)) # euclidean distances between the rows
    rownames(data) <- sources
    colnames(data) <- sources
    data
}, .progress = "text")

save(dist.data, file = paste("distMatData/", scenario,"_",
                    ensemble, "_", var, ".rda", sep = ""))

