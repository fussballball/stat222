options(stringsAsFactors = FALSE)

.First <- function(){

    quietLoad <- function(lib){
        suppressPackageStartupMessages(
            library(lib, character.only = TRUE)
        )
    }
    
    libs <- c("plyr", "ncdf4", "digest")

    sapply(libs, quietLoad)
    rm(libs, quietLoad)

    cat("\nHello!\n") 
}

.Last <- function(){
    
    cat("\nGoodbye!\n")
    
}
