#!/bin/sh

## What user is used for the setup and he's home dir
SETUP_USER="${SETUP_USER-$USER}"
SETUP_USER_HOME="${SETUP_USER_HOME:-$(eval echo "~${SETUP_USER}")}"
print_verbose "Setup SETUP_USER=${SETUP_USER} and SETUP_USER_HOME=${SETUP_USER_HOME}"
## Ignore sudo errors
AVM_IGNORE_SUDO="${AVM_IGNORE_SUDO-0}"

## AVM base dir (default to ~/.avm)
AVM_BASEDIR="${AVM_BASEDIR:-$SETUP_USER_HOME/.avm}"

## Supported types is pip and git. If no type is defined pip will be used
DEFAULT_INSTALL_TYPE="${DEFAULT_INSTALL_TYPE:-pip}"

## Should we force python venv installation with each run
AVM_UPDATE_VENV="${AVM_UPDATE_VENV:-'no'}"

## Ansible bin path it should be something in your path
ANSIBLE_BIN_PATH="${ANSIBLE_BIN_PATH:-/usr/local/bin}"

print_status "Checking general system has minumum requirements"
INCLUDE_FILE "${avm_dir}/avm/checks_general.sh"
general_check
print_done

INCLUDE_FILE "${avm_dir}/avm/_distro.sh"
supported_distro

print_status "Checking post distro check."
INCLUDE_FILE "${avm_dir}/avm/checks_post.sh"
checks_post

print_status "Checking packages on your system has minumum requirements"
INCLUDE_FILE "${avm_dir}/avm/checks_packages.sh"
general_packages
print_done

# Include required files
INCLUDE_FILE "${avm_dir}/avm/ansible_install.sh"
# Install ansible in the virtual envs
ansible_install_venv
# Setup avm binary file
setup_version_bin
# Setup default version
setup_default_version
