# ansible-setup
[![Build Status](https://travis-ci.org/AutomationWithAnsible/ansible-setup.svg?branch=master)](https://travis-ci.org/AutomationWithAnsible/ansible-setup)

Setup mutli Ansible installation in python virtual env


## Why
If you need to install multiple version of ansible and add python packages withouth effecting your global python installation.

## how
Create a wrapper script like this one
```bash
#!/bin/bash
set -e

## This is an example setup script that you would encapsulate the installation 

# What version of ansible setup to use 
SETUP_VERSION="master"

# Whats my path
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## Array of versions to install

## 1. Install Ansible 1.9.4
ANSIBLE_VERSIONS[0]="1.9.4"
INSTALL_TYPE[0]="pip"
# Make this the default for v1
ANSIBLE_V1_PATH="${ANSIBLE_VERSIONS[0]}"

## 2. Install Ansible dev
ANSIBLE_VERSIONS[1]="devel"
PYTHON_REQUIREMENTS[1]="$DIR/python_requirements.txt"
INSTALL_TYPE[1]="git"
# Make this the default for development 
ANSIBLE_DEV_PATH="${ANSIBLE_VERSIONS[1]}"

## 3. Install Ansible stable-2.0 
ANSIBLE_VERSIONS[2]="stable-2.0"
PYTHON_REQUIREMENTS[2]="$DIR/python_requirements.txt"
INSTALL_TYPE[2]="git"
# Make this default for v2
ANSIBLE_V2_PATH="${ANSIBLE_VERSIONS[2]}"   

## 4. Install Ansible 1.9.3
ANSIBLE_VERSIONS[3]="stable-2.0"
PYTHON_REQUIREMENTS[3]="$DIR/python_requirements.txt"
INSTALL_TYPE[3]="pip"

# Whats the system default version
ANSIBLE_DEFAULT_VERSION="${ANSIBLE_VERSIONS[1]}"


## Create a temp dir to download the setup script
filename=$( echo ${0} | sed  's|/||g' )
my_temp_dir="$(mktemp -dt ${filename}.XXXX)"
## Get setup script from gitub
curl -s https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/$SETUP_VERSION/setup.sh -o $my_temp_dir/setup.sh
## Run the setup
. $my_temp_dir/setup.sh

# You can do other stuff here like install test-kitchen or whatever

exit 0
```

## Platforms
Currently supports Mac and ubuntu 14.04

## Options
You can basicly override any variable defined in [setup.sh](https://github.com/AutomationWithAnsible/ansible-setup/blob/master/setup.sh) in your script.


## Debugging
Run your setup with **export SETUP_VERBOSITY="" && bash -x your_setup.sh**
This should give ou insight on all the goodies
