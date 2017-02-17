#!/bin/bash

var=$1
tmpRes=$2

# I'm going to keep these fixed for now
sptRes="g025"
scenario="rcp26"
ensemble="r1i1p1"

# get the list of all possible file names, then filter down to
# only those we want into list.txt
RSYNC_PASSWORD=getdata rsync -vrlpt cmip5ng@atmos.ethz.ch::cmip5-ng |
    grep "$tmpRes" | grep "$sptRes" | grep "$scenario" |
    grep "$ensemble" | grep "$var/" | grep -f "$3" |
    awk '{print $5}' > list.txt

# download desired files named in list.txt
RSYNC_PASSWORD=getdata rsync -vrlpt --files-from=list.txt \
	      cmip5ng@atmos.ethz.ch::cmip5-ng cmip5-ng

rm list.txt
