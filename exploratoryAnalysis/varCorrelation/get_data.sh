#!/bin/bash

# We'll be pulling data for all variables from a single model:
tmpRes="mon"
sptRes="g025"
model="ACCESS1-3"
scenario="historicalGHG"
ensemble="r1i1p1"

# get the list of all possible file names, then filter down to
# only those we want into list.txt
RSYNC_PASSWORD=getdata rsync -vrlpt cmip5ng@atmos.ethz.ch::cmip5-ng |
awk '{print $5}' | grep "$tmpRes" | grep "$sptRes"  | grep "$scenario" | 
grep "$ensemble" | grep "$model" > list.txt

# download desired files named in list.txt
RSYNC_PASSWORD=getdata rsync -vrlpt --files-from=list.txt \
	      cmip5ng@atmos.ethz.ch::cmip5-ng cmip5-ng

rm list.txt
