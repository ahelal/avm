#!/bin/sh

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
