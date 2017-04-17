#!/bin/bash

while read ens; do
    while read var; do
	# report the current step
	echo "variable: $var  ensemble: $ens"

	# get the data for this variable for all the models
	echo "retrieving data"
	bash pull_data.sh $var $ens
	echo "data retrieval complete"

	# now pull the data into R, compress it, and store it
	echo "compressing $var to dist matrices; ensemble: $ens"
	Rscript compress_to_dist_mat.R "abrupt4xCO2" $ens $var
	echo "$var compression complete"

	# remove the data to make room for more
	rm -rf /accounts/grad/yoni/Documents/Stat222/data/cmip5-ng
    done < abrupt4xCO2_variables.txt
done < abrupt4xCO2_ensembles.txt
