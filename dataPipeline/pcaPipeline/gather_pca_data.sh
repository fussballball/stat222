#!/bin/bash

while read var; do
    # get the data for this variable for all the models
    bash pull_data_for_var.sh "mon" pca_mods.txt
    # data can be found in /Users/Yoni/Documents/Stat222/cmip5-ng
    # now pull the data into R, compress it, and store it
    Rscript compress.R var
    
done < pca_variables.txt
