#!/bin/bash
set -e
echo "Running travis simple.sh"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

AVM_SETUP_PATH="/avm/setup.sh"

if [ -f /etc/redhat-release ]; then
  yum update
fi

if [ -f /etc/lsb-release ]; then
  sudo apt-get -y install git
fi

## Install Ansible 1.9.6
ANSIBLE_VERSIONS[0]="1.9.6"
INSTALL_TYPE[0]="pip"
ANSIBLE_LABEL[0]="v1"

## Install Ansible 2.1
ANSIBLE_VERSIONS[1]="2.1.1.0"
INSTALL_TYPE[1]="pip"
ANSIBLE_LABEL[1]="v2"

## Install Ansible stable-2.0
ANSIBLE_VERSIONS[2]="devel"
INSTALL_TYPE[2]="git"
ANSIBLE_LABEL[2]="devel"

SETUP_USER=kitchen

ANSIBLE_VERSION_J2_HTTPS=file:///avm/avm.j2
# Whats the default version
ANSIBLE_DEFAULT_VERSION="v1"

SETUP_VERSION=feature/optional_Setup
#SETUP_VERBOSITY="vv"
#
. $AVM_SETUP_PATH
