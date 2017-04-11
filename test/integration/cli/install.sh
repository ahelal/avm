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

## Link dir .avm/.source_git/ since we are running local
mkdir -p /home/${SETUP_USER}/.avm/.source_git/
ln -sfn /avm /home/${SETUP_USER}/.avm/.source_git/

## Run the setup
${TEST_SHELL} /avm/setup.sh

## Run installation
printf "\nRunning avm install cli (1)\n"
/usr/local/bin/avm install -v 2.0.2.0 -l v2.0 -r /avm/test/integration/cli/requirements.txt

printf "\nRunning avm install cli (2)\n"
/usr/local/bin/avm install -v 2.1.1.0 -l v2.1 -t pip

printf "\nRunning avm install cli (3)\n"
/usr/local/bin/avm install --version devel --label devel --requirements /avm/test/integration/cli/requirements.txt -t git
