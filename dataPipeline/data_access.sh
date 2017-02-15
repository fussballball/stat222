#!/bin/bash 

# example: bash data_access.sh variables.txt 2 1
tmpRes="ann"
sptRes="g025"
scenario="rcp26"
ensemble="r1i1p1"

head -n $2 $1 > tmp.txt

RSYNC_PASSWORD=getdata rsync -vrlpt cmip5ng@atmos.ethz.ch::cmip5-ng |
    grep "$tmpRes" | grep "$sptRes" | grep "$scenario" |
    grep "$ensemble" | grep -f tmp.txt |
    awk '{print $5}' > list.txt

rm tmp.txt

for var in $(head -n $2 $1); do
    grep ${var} list.txt | head -n $3 >> tmp.txt
done

# download desired files named in tmp.txt
RSYNC_PASSWORD=getdata rsync -vrlpt --files-from=tmp.txt \
	      cmip5ng@atmos.ethz.ch::cmip5-ng cmip5-ng

# remove list.txt and tmp.txt
rm list.txt tmp.txt
