#!/bin/bash
set -e
echo "Running travis travis-setup-basic.sh"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

SETUP_VERSION=${TRAVIS_COMMIT_RANGE##*...}

# Be more verbose
SETUP_VERBOSITY=""

## Install Ansible 1.9.4
ANSIBLE_VERSIONS[0]="1.9.4"
INSTALL_TYPE[0]="pip"
ANSIBLE_V1_PATH="${ANSIBLE_VERSIONS[0]}"    # v1

## Install Ansible stable-2.0 
ANSIBLE_VERSIONS[1]="stable-2.0"
PYTHON_REQUIREMENTS[1]="$DIR/python_requirements.txt"
INSTALL_TYPE[1]="git"
ANSIBLE_V2_PATH="${ANSIBLE_VERSIONS[1]}"  # v2

# Whats the default version
ANSIBLE_DEFAULT_VERSION="ANSIBLE_VERSIONS[0]"

## Create a temp dir
filename=$( echo ${0} | sed  's|/||g' )
my_temp_dir="$(mktemp -dt ${filename}.XXXX)"
## Get setup
curl -s https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/$SETUP_VERSION/setup.sh -o $my_temp_dir/setup.sh
## Run the setup
. $my_temp_dir/setup.sh
