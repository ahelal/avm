#!/bin/bash
set -e

echo "Running simple.sh"
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
export AVM_VERBOSE="vv"

## Install Ansible 1.9.6 using pip and label it 'v1'
export ANSIBLE_VERSIONS_0="1.9.6"
export INSTALL_TYPE_0="pip"
export ANSIBLE_LABEL_0="v1"

## Install Ansible 2.1.1 using pip and label it 'v2'
export ANSIBLE_VERSIONS_1="2.1.1.0"
export INSTALL_TYPE_1="pip"
export ANSIBLE_LABEL_1="v2"

## Install Ansible devel using git and label it 'devel'
export ANSIBLE_VERSIONS_2="devel"
export INSTALL_TYPE_2="git"
export ANSIBLE_LABEL_2="devel"

## Whats the default version
export ANSIBLE_DEFAULT_VERSION="v1"

## Run the setup
${TEST_SHELL} /avm/setup.sh
