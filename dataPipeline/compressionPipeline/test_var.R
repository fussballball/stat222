path <- paste0("/accounts/grad/yoni/Documents/Stat222/",
               "dataPipeline/compressionPipeline/cmip5-ng/")
nc.files <- list.files(path, full.names = TRUE, recursive = TRUE)

acceptable.vars <- sapply(nc.files, function(var.file){
    var <- strsplit(var.file, "/")[[1]][11]
    nc <- nc_open(var.file)
    dims <- length(dim(ncvar_get(nc, var)))
    if(dims == 3){
        var
    } else {
        NA
    }
}, USE.NAMES = FALSE)

i <- grep("max", acceptable.vars)
j <- grep("min", acceptable.vars)

acceptable.vars <- acceptable.vars[-c(i,j)]

fileConn<-file("abrupt4xCO2_variables.txt")
writeLines(na.omit(acceptable.vars), fileConn)
close(fileConn)
