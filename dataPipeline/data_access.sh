#!/bin/bash 

# example: bash data_access.sh variables.txt 2 models.txt 1

# download the list of options for this variable
RSYNC_PASSWORD=getdata rsync -vrlpt cmip5ng@atmos.ethz.ch::cmip5-ng |
    grep -f $1 |
    awk '{print $5}' > list.txt

# loop through all the variables
for var in $(head -n $2 $1); do
    for mod in $(head -n $4 $3); do

	# set the variables
	tmpRes="mon"
	sptRes="g025"
	scenario="rcp26"
	ensemble="r1i1p1"

	# select the desired file names to tmp.txt
	grep "$tmpRes" list.txt |
	    grep ${var}_ |
	    grep "$sptRes" |
	    grep _${mod}_ |
	    grep "$scenario" |
	    grep "$ensemble" >> tmp.txt

    done
done

# download desired files named in tmp.txt
RSYNC_PASSWORD=getdata rsync -vrlpt --files-from=tmp.txt \
	      cmip5ng@atmos.ethz.ch::cmip5-ng cmip5-ng

# remove list.txt and tmp.txt
rm list.txt tmp.txt
