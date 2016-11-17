# Ansible Version Manager (AVM)
[![Build Status](https://travis-ci.org/ahelal/avm.svg?branch=master)](https://travis-ci.org/ahelal/avm)

Ansible Version Manager (AVM) is a tool to manage mutli Ansible installation by creating a python virtual env for each version.

## Why

- If you need to install multiple version of ansible and add python packages withouth effecting your global python installation.
- Running multi version on CI for testing i.e. travis, concourse, jenkins, ...
- Using the development version of ansible to test and using stable version for production

## how
Create a wrapper script like this one
```bash
#!/bin/bash
set -e

## This is an example setup script that you would encapsulate the installation

# What version of ansible setup to use
SETUP_VERSION="v0.1.0"

echo "Running travis simple.sh"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

AVM_SETUP_PATH="/avm/setup.sh"

## Install Ansible 2.0.2.0
ANSIBLE_VERSIONS[0]="2.0.2.0"
INSTALL_TYPE[0]="pip"
ANSIBLE_LABEL[0]="v2.0"
PYTHON_REQUIREMENTS[0]="/avm/test/integration/advanced/requirements.txt"

## Install Ansible 2.1
ANSIBLE_VERSIONS[1]="2.1.1.0"
INSTALL_TYPE[1]="pip"
ANSIBLE_LABEL[1]="v2.1"

## Install Ansible devel
ANSIBLE_VERSIONS[2]="devel"
INSTALL_TYPE[2]="git"
ANSIBLE_LABEL[2]="devel"
PYTHON_REQUIREMENTS[2]="/avm/test/integration/advanced/requirements.txt"

SETUP_USER=kitchen

ANSIBLE_VERSION_J2_HTTPS=file:///avm/avm.j2
# Whats the default version
ANSIBLE_DEFAULT_VERSION="v2.1"

#SETUP_VERBOSITY="vv"

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
Currently supports Mac and ubuntu 14.04, 16.04

## Options
You can basicly override any variable defined in [setup.sh](https://github.com/AutomationWithAnsible/ansible-setup/blob/master/setup.sh) in your script.


## Debugging
Run your setup with **export SETUP_VERBOSITY="v" && bash -x your_setup.sh**
This should give ou insight on all the goodies
