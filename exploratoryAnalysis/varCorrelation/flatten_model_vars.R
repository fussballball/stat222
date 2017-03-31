## retrieve desired files (one for each var)
nc_files <- list.files("cmip5-ng/", recursive = TRUE, full.names = TRUE)

time <- dim(ncvar_get(nc_open(nc_files[1])))[3]

## store var names
vars <- unlist(lapply(strsplit(nc_files, "/"), function(i) i[3]))

## flatten each dataset 
flDat <- llply(nc_files, function(nc){
    var <- strsplit(nc, "/")[[1]][3]
    dat <- nc_open(nc)
    dat <- ncvar_get(dat, var)
    flatten_model(dat) ## flat dat
})
names(flDat) <- vars ## link datasets to var names

## reassemble the model with all vars at time t
## store as a list indexed by time
modt <- llply(1:time, function(i){
    timeCols <- llply(vars, function(v){
        flDat[[v]][,i]
    })
    dat <- do.call(cbind, timeCols)
    colnames(dat) <- vars
    scale(dat)
})

save(modt, file = "ACCESS1_3_flat.rda")
