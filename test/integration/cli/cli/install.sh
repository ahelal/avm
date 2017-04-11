#!/bin/bash
set -e

echo "Running advanced.sh"
TEST_SHELL="${TEST_SHELL-/bin/sh}"

if [ -f /etc/redhat-release ]; then
  yum update
fi

if [ -f /etc/lsb-release ]; then
  sudo apt-get -y install git
fi

## Setup config
export SETUP_USER=kitchen
# don't clone use local path
export AVM_VERSION="local"
export AVM_VERBOSE="v"

## Whats the default version
export ANSIBLE_DEFAULT_VERSION="v2.1"

## Install Ansible 2.0.2.0
export ANSIBLE_VERSIONS_0="2.0.2.0"
export INSTALL_TYPE_0="pip"
export ANSIBLE_LABEL_0="v2.0"
export PYTHON_REQUIREMENTS_0="/avm/test/integration/advanced/requirements.txt"

## Install Ansible 2.1
export ANSIBLE_VERSIONS_1="2.1.1.0"
export INSTALL_TYPE_1="pip"
export ANSIBLE_LABEL_1="v2.1"

## Install Ansible devel
export ANSIBLE_VERSIONS_2="devel"
export INSTALL_TYPE_2="git"
export ANSIBLE_LABEL_2="devel"
export PYTHON_REQUIREMENTS_2="/avm/test/integration/advanced/requirements.txt"

## Run the setup
${TEST_SHELL} /avm/setup.sh
