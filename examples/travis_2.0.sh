#!/bin/bash
set -e
echo "Running travis travis-setup-basic.sh"

echo "Travis env"
env

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Use travis commit
if [ -z "${TRAVIS_COMMIT_RANGE}" ]; then
    SETUP_VERSION="${TRAVIS_COMMIT_RANGE##*...}"
else
    SETUP_VERSION="${TRAVIS_COMMIT}"
fi
if [ -z "${SETUP_VERSION}" ]; then
    echo "Failed to get commit range from travis 'SETUP_VERSION'=${SETUP_VERSION}"
    exit 1
else
    echo "Using setup version=${SETUP_VERSION}"
fi

# Be more verbose
SETUP_VERBOSITY=""

## Install Ansible 2.0
ANSIBLE_VERSIONS[0]="2.0.2.0"
INSTALL_TYPE[0]="pip"
PYTHON_REQUIREMENTS[0]="$SETUP_DIR/python_requirements.txt"
ANSIBLE_V2_PATH="${ANSIBLE_VERSIONS[1]}" # v2 link

## Install Ansible 2.1.0
ANSIBLE_VERSIONS[1]="2.1.0.0"
INSTALL_TYPE[1]="pip"
PYTHON_REQUIREMENTS[1]="$SETUP_DIR/python_requirements.txt"

ANSIBLE_VERSIONS[2]="devel"
INSTALL_TYPE[2]="git"
PYTHON_REQUIREMENTS[2]="$SETUP_DIR/python_requirements.txt"

# Whats the default version
ANSIBLE_DEFAULT_VERSION="v2"

# V2 version
ANSIBLE_V2_PATH="${ANSIBLE_VERSIONS[0]}"

#Dev version
ANSIBLE_DEV_PATH="${ANSIBLE_VERSIONS[1]}"


## Create a temp dir
filename=$( echo ${0} | sed  's|/||g' )
my_temp_dir="$(mktemp -dt ${filename}.XXXX)"
## Get setup
curl -s https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/$SETUP_VERSION/setup.sh -o $my_temp_dir/setup.sh
## Run the setup
. $my_temp_dir/setup.sh
