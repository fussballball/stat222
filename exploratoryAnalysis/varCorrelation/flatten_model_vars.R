## retrieve desired files (one for each var)
nc_files <- list.files("cmip5-ng/", recursive = TRUE, full.names = TRUE)

tmp <- ncvar_get(nc_open(nc_files[1]))

time <- dim(tmp)[3]
space <- dim(tmp)[2] * dim(tmp)[1]

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
mod.t <- llply(1:time, function(i){
    timeCols <- llply(vars, function(v){
        flDat[[v]][,i]
    })
    dat <- do.call(cbind, timeCols)
    colnames(dat) <- vars
    scale(dat)
})

## reassemble the model with all vars at point s
## store as a list indexed by space
mod.s <- llply(1:space, function(i){
    spaceCols <- llply(vars, function(v){
        flDat[[v]][i,]
    })
    dat <- t(do.call(rbind, spaceCols))
    colnames(dat) <- vars
    scale(dat)
})

save(mod.t, mod.s, file = "ACCESS1_3_flat.rda")
