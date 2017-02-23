#!/bin/bash

bash pull_data.sh "tas" "mon"
mv cmip5-ng tas-his 
bash pull_data.sh "pr" "mon"
mv cmip5-ng pr-his