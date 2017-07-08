# Ansible Version Manager (AVM)
[![Build Status](https://travis-ci.org/ahelal/avm.svg?branch=master)](https://travis-ci.org/ahelal/avm)

Ansible Version Manager (AVM) is a tool to manage multi Ansible installation by creating a python virtual environment for each version.

## Why
* Running multiple version of Ansible on the same host.
* Using the development version of ansible for testing and using stable version for production.
* Make your CI run multiple versions for testing i.e. travis, concourse, jenkins, ... or test-kitchen or molecule.
* Create a wrapper script to manage Ansible within your teams and make upgrading roll back easier for many users with different OS and shells.
* If you need add python packages to and make it accessible to Ansible without effecting your global python installation. i.e. boto, dnspython, netaddr or others

## Incompatibly as of 1.0.0 version (not released yet)
* Change in variable names
* Stopped using bash arrays ```i.e. ANSIBLE_VERSIONS[0]``` to be more Posix and use flat variables ```i.e. ANSIBLE_VERSIONS_0```

For more info check [Setup variables](setup-variables)

## How

You have two options using a **setup script** or **command** to install

### Setup wrapper script
Create a wrapper script this would be useful for CI or if you want your team to have unified installation.

```bash
#!/bin/sh
set -e
# What version of AVM setup to use
export AVM_VERSION="v1.0.0"

## Install Ansible 1.9.6 using pip and label it 'v1.9'
export ANSIBLE_VERSIONS_0="1.9.6"
export INSTALL_TYPE_0="pip"
export ANSIBLE_LABEL_0="v1.9"

## Install Ansible 2.2.3.0 using pip and label it 'v2.2'
export ANSIBLE_VERSIONS_1="2.2.3.0"
export INSTALL_TYPE_1="pip"
export ANSIBLE_LABEL_1="v2.2"

## Install Ansible 2.3.1.0 using pip and label it 'v2.3'
export ANSIBLE_VERSIONS_2="2.3.1.0"
export INSTALL_TYPE_2="pip"
export ANSIBLE_LABEL_2="v2.3"

## Install Ansible from devel using git and label it 'devel'
export ANSIBLE_VERSIONS_2="devel"
export INSTALL_TYPE_2="git"
export ANSIBLE_LABEL_2="devel"

# Whats the default version
export ANSIBLE_DEFAULT_VERSION="v1.9"

## Create a temp dir to download avm
avm_dir="$(mktemp -d 2> /dev/null || mktemp -d -t 'mytmpdir')"
git clone https://github.com/ahelal/avm.git "${avm_dir}" > /dev/null 2>&1
## Run the setup
/bin/sh "${avm_dir}/setup.sh"

exit 0
```

### Setup Command
You would need first to install avm
```bash
git https://github.com/ahelal/avm.git
cd avm
./setup.sh
```

then you can use the avm cli to install
```bash
# Install stable release (defaults to pip)
avm install --version 2.2.0.0 --label production

# Install development release
avm install --version devel --label dev --type git

# if you have some python lib to install in the virtual env you can also add python requirements.txt file
avm install --version 2.0.0.0 --label legacy --requirements /path/to/requirements.txt
```

### avm command usage
Once install you can use *avm* the cli to switch between version. for more info run **avm --help**
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

## Setup variables

If you are using [Setup wrapper script](setup-wrapper-script) you can override any of the following variables in your script.

| Name | default | Description |
|----------------------|---------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| AVM_VERSION | master | avm version to install. Supports releases, tags, branches. if set to "local" will use *pwd* as source of installation. |
| AVM_VERBOSE |  | Setup verbosity could be empty, v, vv or vvv |
| SETUP_USER | $USER | The setup user that will have avm and use avm. |
| SETUP_USER_HOME | $USER home dir | The home dir of setup user.  |
| AVM_IGNORE_SUDO |  | Simply ignore sudo errors. |
| DEFAULT_INSTALL_TYPE | pip | Default installation type if not defined. |
| AVM_UPDATE_VENV | 0 |  |
| ANSIBLE_BIN_PATH | /usr/local/bin | Path to install the ansible and avm binary.  |
| ANSIBLE_VERSIONS_X |  |  |
| ANSIBLE_LABEL_X |  |  |
| INSTALL_TYPE_X |  |  |
| UBUNTU_PKGS |  |  |


## Supported platforms
Currently tested under
* OSX
* Ubuntu 14.04, 16.04
* Alpine 3.4 (early support)

## support shells
* bash
* dash
* zsh
* busybox ash

## Alpine docker

Experimental support for Alpine in docker

if your installing for **non root** user you require
```bash
apk add sudo
echo "auth       sufficient pam_rootok.so" > /etc/pam.d/su
```

if your creating an image that does not have python or gcc you can do a cleanup at the end
```bash
apk del build-dependencies
```

## Debugging

### Verbosity
Setup verbosity could be empty or *v*, *vv* or *vvv*

i.e. ```AVM_VERBOSE="vv" your_setup.sh```

*v*   : Show verbose messages, but mute stdout, stderr
*vv*  : Show verbose messages and stdout, stderr
*vvv* : Show verbose messages, stdout, stderr and set -x

### In depth debugging
By default avm uses the *AVM_VERSION* to download and checkout that branch. if you want to debug and change the script you can use *AVM_VERSION=local* to use a local version of avm.


## License
License (MIT)

## Contribution
Your contribution is welcome.
