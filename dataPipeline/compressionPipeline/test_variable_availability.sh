#!/bin/bash

# These are fixed
tmpRes="mon"
sptRes="g025"
scenario="abrupt4xCO2"

# get the list of all possible file names, then filter down to
# only those we want into list.txt
RSYNC_PASSWORD=getdata rsync -vrlpt cmip5ng@atmos.ethz.ch::cmip5-ng |
    grep "mon" | grep "$sptRes" | grep "$scenario" |
    grep "ACCESS1-3" | awk '{print $5}' > list.txt

# download desired files named in list.txt
RSYNC_PASSWORD=getdata rsync -vrlpt --files-from=list.txt \
    cmip5ng@atmos.ethz.ch::cmip5-ng cmip5-ng

cut -f 5 -d "_" list.txt | uniq  > abrupt4xCO2_ensembles.txt

Rscript test_var.R

rm -rf cmip5-ng
