# Ansible Version Manager (AVM)
[![Build Status](https://travis-ci.org/ahelal/avm.svg?branch=master)](https://travis-ci.org/ahelal/avm)

Ansible Version Manager (AVM) is a tool to manage multi Ansible installation by creating a python virtual env for each version.

## Why

- If you need to install multiple version of ansible and add python packages without effecting your global python installation.
- Running multi version on CI for testing i.e. travis, concourse, jenkins, ...
- Using the development version of ansible to test and using stable version for production

## How

You have two options using a **setup script** or **command** to install

### Setup script
Create a wrapper script this would be useful for CI or if you want you team to run same version of ansible.

This will install avm and three versions of ansible.
```bash
#!/bin/bash
set -e

## This is an example setup script that you would encapsulate the installation

# What version of ansible setup to use
SETUP_VERSION="v0.1.0"

echo "Running travis simple.sh"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

AVM_SETUP_PATH="/avm/setup.sh"

## Install Ansible 2.0.2.0 from PIP
ANSIBLE_VERSIONS[0]="2.0.2.0"
INSTALL_TYPE[0]="pip"
ANSIBLE_LABEL[0]="v2.0"
PYTHON_REQUIREMENTS[0]="/avm/test/integration/advanced/requirements.txt"

## Install Ansible 2.1 PIP
ANSIBLE_VERSIONS[1]="2.1.1.0"
INSTALL_TYPE[1]="pip"
ANSIBLE_LABEL[1]="v2.1"

## Install Ansible devel GIT
ANSIBLE_VERSIONS[2]="devel"
INSTALL_TYPE[2]="git"
ANSIBLE_LABEL[2]="devel"
PYTHON_REQUIREMENTS[2]="/avm/test/integration/advanced/requirements.txt"

ANSIBLE_VERSION_J2_HTTPS=file:///avm/avm.j2
# Whats the default version
ANSIBLE_DEFAULT_VERSION="v2.1"

#SETUP_VERBOSITY="vv"

## Create a temp dir to download the setup script
filename=$( echo ${0} | sed  's|/||g' )
my_temp_dir="$(mktemp -dt ${filename}.XXXX)"
## Get setup script from gitub
curl -s https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/${SETUP_VERSION}/setup.sh -o $my_temp_dir/setup.sh
## Run the setup
. $my_temp_dir/setup.sh

# You can do other stuff here like install other tools for youea team

exit 0
```

You can basically override any variable defined in [setup.sh](https://github.com/AutomationWithAnsible/ansible-setup/blob/master/setup.sh) in your script.

### Setup Command
You would need first to install avm
```bash
git clone git@github.com:ahelal/avm.git
cd avm
./setup.sh
```

then you can use the command install option
```bash
# Install stable release (defaults to pip)
avm install --version 2.2.0.0 --label production

# Install development release
avm install --version devel --label dev --type git

# if you have some python lib to install in the virtual env you can also add python requirements.txt file
avm install --version 2.0.0.0 --label legacy requirements /path/to/requirements.txt
```

### Command arguments
```
Usage:
    avm  info
    avm  list
    avm  path <version>
    avm  use <version>
    avm  activate <version>
    avm  install (-v version) [-t type] [-l label] [-r requirements]

Options:
    info                        Show ansible version in use
    list                        List installed versions
    path <version>              Print binary path of specific version
    use  <version>              Use a <version> of ansible
    activate <version>          Activate virtualenv for <version>
```

## Platforms
Currently tested under
* OS-X
* Ubuntu 14.04, 16.04
* Alpine 3.4 (early support)

## Alpine docker

Experimental support for Alpine.

### Prerequisites
* apk add sudo
if your installing for non root user
* echo "auth       sufficient pam_rootok.so" > /etc/pam.d/su

if your creating an image that does not have python or gcc you can do a cleanup at the end
```apk del build-dependencies``` this.

## Debugging
### Level 1
Run your setup with ```SETUP_VERBOSITY="v" your_setup.sh```
This should give ou insight on all the goodies
### Level 2
extem debugging 
Run your setup with ```SETUP_VERBOSITY="vv" your_setup.sh```

## License
License (MIT)

## Contribution
Your contribution is welcome .
