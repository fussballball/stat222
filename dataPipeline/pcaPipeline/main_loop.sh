#!/bin/bash

## set dimensions of compression
N=$1
M=$2

while read var; do
    # check to see if we already have the data loaded,
    # if not, download it:
    bool=$([ "$(ls -A cmip5-ng/$var)" ] && echo "true" || echo "false")

    if [ "$bool" = "false" ]; then
	# get the data for this variable for all the models
	bash pull_data.sh $var "mon" pca_mods.txt
    fi
    
    # now pull the data into R, compress it, and store it
    Rscript compress.R "$var" $N $M
    
done < pca_variables.txt

# melt and concatenate all the compressed data:
Rscript merge_data.R

# run the mds and save an image
Rscript doMDS.R $N $M
