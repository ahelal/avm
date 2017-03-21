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

#TODO sould properly replace ANSIBLE_VERSION_J2_HTTPS=file:///avm/avm.j2
# Whats the default version
ANSIBLE_DEFAULT_VERSION="v2.1"

#AVM_VERBOSITY="vv"

. $AVM_SETUP_PATH
