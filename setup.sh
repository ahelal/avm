#!/bin/bash
set -e

## This current directory.
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## Setup Version to use
SETUP_VERSION="${SETUP_VERSION-master}"

## Less verbosity 'could be empty or -q'
SETUP_VERBOSITY="${SETUP_VERBOSITY--q}"

## What user is use for the setup and he's home dir
SETUP_USER="${SETUP_USER-$USER}"
SETUP_USER_HOME="${SETUP_USER_HOME:-$(eval echo ~${SETUP_USER})}"

## Ubuntu apt pre-req
UBUNTU_PKGS="${UBUNTU_PKGS:-python-setuptools python-dev build-essential libffi-dev libssl-dev curl software-properties-common}"

## Ansible virtual environment directory
ANSIBLE_BASEDIR="${ANSIBLE_BASEDIR:-$SETUP_USER_HOME/.venv_ansible}"

## Supported types is pip and git. If no type is defined pip will be used
DEFAULT_INSTALL_TYPE="${DEFAULT_INSTALL_TYPE:-pip}"

## Array of versions of ansiblet to install and what requirements files for each version
ANSIBLE_VERSIONS[0]="${ANSIBLE_VERSIONS[0]:-"1.9.4"}"

## Default version to use
ANSIBLE_DEFAULT_VERSION="v1"

## What version to use for each v1,v2,dev
ANSIBLE_V1_PATH="${ANSIBLE_VERSIONS[0]}"    # v1

## Ubuntu Ruby
SETUP_INSTALL_RUBY="${SETUP_INSTALL_RUBY:-""}"
SETUP_RUBY_VERSION="${SETUP_RUBY_VERSION:-"ruby1.9"}"
SETUP_RUBY_CUSTOM_REPO_INSTALL="${SETUP_RUBY_CUSTOM_REPO_INSTALL:-""}"
SETUP_RUBY_CUSTOM_REPO="${SETUP_RUBY_CUSTOM_REPO:-"ppa:brightbox/ruby-ng-experimental"}"

## Should we force venv installation
FORCE_VENV_INSTALLATION="${FORCE_VENV_INSTALLATION:-'no'}"

COLOR_END='\e[0m'    # End of color
COLOR_RED='\e[0;31m' # Red
COLOR_YEL='\e[0;33m' # Yellow
COLOR_GRN='\e[0;32m' # green

## Ansible bin path it should be something in your path
ANSIBLE_BIN_PATH="${ANSIBLE_BIN_PATH:-/usr/local/bin}"

ANSIBLE_VERSION_J2_HTTPS="${ANSIBLE_VERSION_J2_HTTPS:-https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/$SETUP_VERSION/ansible-version.j2}"
ANSIBLE_VERSION_YML_HTTPS="${ANSIBLE_VERSION_YML_HTTPS:-https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/$SETUP_VERSION/ansible-version.yml}"

## Print Error msg
##
msg_exit() {
  printf "> $COLOR_RED$@$COLOR_END\nExiting...\n" && exit 1
}

## Print warning msg
##
msg_warning() {
  printf "| $COLOR_YEL$@$COLOR_END\n"
}

## Check setup home dir
##
! [ -d "$SETUP_USER_HOME" ] && msg_exit "Your home directory \"$SETUP_USER_HOME\" doesn't exist."

## Run command as a different user if you have SETUP_USER env set
##
RUN_COMMAND_AS() {
  if [ "$SETUP_USER" == "$USER" ]; then
    $1
  else
    sudo su $SETUP_USER -c "$1"
  fi
}

## Create Virtual environment
##
ansible_install_venv(){
    # Create base dir
    RUN_COMMAND_AS "mkdir -p ${ANSIBLE_BASEDIR}"
    # Create a bin dir in base dir
    RUN_COMMAND_AS "mkdir -p ${ANSIBLE_BASEDIR}/bin"
    for i in $(seq 1 ${#ANSIBLE_VERSIONS[@]})
    do
        i=$(($i-1))
        ansible_version="${ANSIBLE_VERSIONS[$i]}"

        RUN_COMMAND_AS "mkdir -p ${ANSIBLE_BASEDIR}/${ansible_version}"
        cd "${ANSIBLE_BASEDIR}/${ansible_version}"
        
        # 1st create virtual env for this version
        if [ "$FORCE_VENV_INSTALLATION" != "no" ] && [ ! -d "./venv" ]; then
          echo "| $ansible_version > Creating/updating venv for ansible $ansible_version"
          RUN_COMMAND_AS "virtualenv venv"
        else
          echo "| $ansible_version > venv $ansible_version exists"
        fi

        # 2nd Check if python requirments file exists and install requirement file
        if ! [ -z "${PYTHON_REQUIREMENTS[$i]}" ]; then
            echo "| $ansible_version > Install python requirments file ${PYTHON_REQUIREMENTS[$i]}"
            RUN_COMMAND_AS "$ANSIBLE_BASEDIR/$ansible_version/venv/bin/pip install $SETUP_VERBOSITY --upgrade --requirement ${PYTHON_REQUIREMENTS[$i]}"
        fi
        # 3ed install Ansible in venv
        if [ ${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE} == "pip" ]; then
            echo "| $ansible_version > Using 'pip' as installation type"
            RUN_COMMAND_AS "$ANSIBLE_BASEDIR/$ansible_version/venv/bin/pip install $SETUP_VERBOSITY ansible==$ansible_version"
        elif [ ${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE} == "git" ]; then
            [[ -z "$(which git)" ]] && msg_exit "git is not installed"
            echo "| $ansible_version > Using 'git' as installation type"
            if [ -d "ansible/.git" ]; then
                cd "${ANSIBLE_BASEDIR}/${ansible_version}/ansible"
                RUN_COMMAND_AS "git pull --rebase"
                RUN_COMMAND_AS "git submodule update --init --recursive"
            else
                RUN_COMMAND_AS "git clone git://github.com/ansible/ansible.git --recursive"
            fi
            cd "${ANSIBLE_BASEDIR}/${ansible_version}/ansible"
            # Check out the version and install it
            RUN_COMMAND_AS "git checkout $ansible_version"
            RUN_COMMAND_AS "$ANSIBLE_BASEDIR/$ansible_version/venv/bin/python setup.py $SETUP_VERBOSITY install"
        else
            msg_exit "$ansible_version > Unknown installation type ${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE}"
        fi
      done
}

## Setup default ansible version for v1,v2 and dev
##
setup_symlink() {
  cd $ANSIBLE_BASEDIR
  # Create link for v1, v2, dev
  if ! [ -z "$ANSIBLE_V1_PATH" ]; then
    echo "| Setup default symlink for V1 ${ANSIBLE_BASEDIR}/v1 to ${ANSIBLE_BASEDIR}/$ANSIBLE_V1_PATH"
    RUN_COMMAND_AS "ln -sf ${ANSIBLE_BASEDIR}/$ANSIBLE_V1_PATH ${ANSIBLE_BASEDIR}/v1"
  fi
  if ! [ -z "$ANSIBLE_V2_PATH" ]; then
    echo "| Setup default symlink for V2 ${ANSIBLE_BASEDIR}/v2 ${ANSIBLE_BASEDIR}/${ANSIBLE_V2_PATH}"
    RUN_COMMAND_AS "ln -sf ${ANSIBLE_BASEDIR}/$ANSIBLE_V2_PATH ${ANSIBLE_BASEDIR}/v2"
  fi
  if ! [ -z "$ANSIBLE_DEV_PATH" ]; then 
    echo "| Setup default symlink for DEV ${ANSIBLE_BASEDIR}/dev ${ANSIBLE_BASEDIR}/${ANSIBLE_DEV_PATH}"
    RUN_COMMAND_AS "ln -sf ${ANSIBLE_BASEDIR}/$ANSIBLE_DEV_PATH ${ANSIBLE_BASEDIR}/dev"
  fi
}

## Do some checks user, python and easy_install
##
[[ "$(whoami)" == "root" ]] && msg_exit "Please run as a normal user not root."
[[ -z "$(which python)" ]] && msg_exit "Opps python is not installed or not in your path."

## Check if I can change to root
##
CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1 | grep "load" | wc -l)
if [ ${CAN_I_RUN_SUDO} -eq 0 ]; then
  msg_exit "$USER can't run the Sudo command. You might have sudo rights, But password is required. you can run$COLOR_END $COLOR_GRN'sudo whoami && $0'$COLOR_END to use the cached password in sudo"
  exit 1
fi

# Check your distro is supported
##
system=$(uname)
if [ "$system" == "Linux" ]; then
  distro=$(lsb_release -i)
  if [[ $distro == *"Ubuntu"* ]] || [[ $distro == *"Debian"* ]] ;then
    sudo apt-get install -y $UBUNTU_PKGS
    # Ruby 
    if ! [ -z "$SETUP_INSTALL_RUBY" ]; then
      if ! [ -z "$SETUP_RUBY_CUSTOM_REPO_INSTALL" ] ;then
        echo " Installing custom Ruby repo ${SETUP_RUBY_CUSTOM_REPO}"
        sudo add-apt-repository ${SETUP_RUBY_CUSTOM_REPO} -y
        sudo apt-get update
      fi
      echo " Installing ${SETUP_RUBY_VERSION}"
      sudo apt-get install -y ${SETUP_RUBY_VERSION}
    fi
  else
    msg_warning "Your linux system was not tested. It might work"
  fi
fi

# Check curl and easy_install
[[ -z "$(which curl)" ]] && msg_exit "curl is not in your path. Please install it or reference it in your path"
[[ -z "$(which easy_install)" ]] && msg_exit "easy_install is not in your path."

## Setup ansible-version binary file
##
setup_version_bin() {
  
  filename=$( echo ${0} | sed  's|/||g' )
  my_temp_dir=$(RUN_COMMAND_AS "mktemp -dt ${filename}.XXXX")

  # Get ansible yaml and j2 file from github
  RUN_COMMAND_AS "curl -s -o $my_temp_dir/ANSIBLE_VERSION_YML $ANSIBLE_VERSION_YML_HTTPS"
  RUN_COMMAND_AS "curl -s -o $my_temp_dir/ANSIBLE_VERSION_J2 $ANSIBLE_VERSION_J2_HTTPS"

  RUN_COMMAND_AS "${ANSIBLE_BASEDIR}/${ANSIBLE_DEFAULT_VERSION}/venv/bin/ansible-playbook -i localhost, $my_temp_dir/ANSIBLE_VERSION_YML \
    -e ANSIBLE_BIN_PATH=$ANSIBLE_BIN_PATH \
    -e ANSIBLE_BASEDIR=$ANSIBLE_BASEDIR \
    -e ANSIBLE_SELECTED_VERSION=$ANSIBLE_DEFAULT_VERSION \
    -e SETUP_USER=$SETUP_USER \
    -e ANSIBLE_VERSION_TEMPLATE_PATH=$my_temp_dir/ANSIBLE_VERSION_J2"

  # Require to run sudo as assumption is it will be global
  echo "| Creating symlink ${ANSIBLE_BASEDIR}/ansible-version ${ANSIBLE_BIN_PATH}/ansible-version"
  sudo ln -sf ${ANSIBLE_BASEDIR}/ansible-version ${ANSIBLE_BIN_PATH}/ansible-version 

  for bin in ansible ansible-doc ansible-galaxy ansible-playbook ansible-pull ansible-vault
  do
      # Require to run sudo as assumption is it will be global
      echo "| Creating global symlink ${ANSIBLE_BASEDIR}/bin/${bin} is pointing to ${ANSIBLE_BIN_PATH}/$bin"
      sudo ln -sf ${ANSIBLE_BASEDIR}/bin/${bin} ${ANSIBLE_BIN_PATH}/$bin
  done

  echo "| Setting up default virtualenv to $ANSIBLE_DEFAULT_VERSION"
  RUN_COMMAND_AS "ansible-version set $ANSIBLE_DEFAULT_VERSION"
}

# Install virtual env
sudo -H easy_install --upgrade virtualenv

# Install ansible in the virtual envs
ansible_install_venv

# Setup default symlink
setup_symlink

# Setup ansible-version binary file
setup_version_bin
