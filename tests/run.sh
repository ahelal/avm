#!/bin/bash 
set -e
set -x 

./common.sh
./ansible-version.sh
./various_runs.sh
# Run setup again with full path
bash -x ../example/travis-test.sh
./installation.sh
ansible --version
