#!/bin/bash

END=20

for i in $(seq 10 10 20); do

    bash main_loop.sh $i $i
    
done

# finally delete all the data for this variable,
# no need for it to be taking up space...
# rm -rf cmip5-ng
