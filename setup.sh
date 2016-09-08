#!/bin/bash
set -e

## This current directory.
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## Setup Version to use
SETUP_VERSION="${SETUP_VERSION-master}"

## 'could be empty or v or vv'
SETUP_VERBOSITY="${SETUP_VERBOSITY-}"
if [ "${SETUP_VERBOSITY}" == "vv" ]; then
  echo "| verbosity level 2"
  set -x
fi

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
ANSIBLE_VERSIONS="${ANSIBLE_VERSIONS[0]:-"2.1.1.0"}"
## Label of version if any
ANSIBLE_LABEL="${ANSIBLE_LABEL:-"test_v2"}"

## Default version to use
ANSIBLE_DEFAULT_VERSION="${ANSIBLE_DEFAULT_VERSION:-'v2'}"

## Should we force venv installation
FORCE_VENV_INSTALLATION="${FORCE_VENV_INSTALLATION:-'no'}"

## Ignore sudo errors
SETUP_SUDO_IGNORE="${SETUP_SUDO_IGNORE-0}"

COLOR_END='\e[0m'    # End of color
COLOR_RED='\e[0;31m' # Red
COLOR_YEL='\e[0;33m' # Yellow
COLOR_GRN='\e[0;32m' # green

## Ansible bin path it should be something in your path
ANSIBLE_BIN_PATH="${ANSIBLE_BIN_PATH:-/usr/local/bin}"

ANSIBLE_VERSION_J2_HTTPS="${ANSIBLE_VERSION_J2_HTTPS:-https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/$SETUP_VERSION/avm.j2}"
ANSIBLE_VERSION_YML_HTTPS="${ANSIBLE_VERSION_YML_HTTPS:-https://raw.githubusercontent.com/AutomationWithAnsible/ansible-setup/$SETUP_VERSION/avm.yml}"

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

## Run command as a different user if you have SETUP_USER env set
##
RUN_COMMAND_AS() {
  if [ "$SETUP_USER" == "$USER" ]; then
    command_2_run="$1"
  else
    command_2_run=sudo su $SETUP_USER -c "$1"
  fi

  case ${SETUP_VERBOSITY} in
    '')
      ${command_2_run} > /dev/null
    ;;
    "stdout")
      ${command_2_run}
    ;;
    *)
      (>&2 echo "| Exec ${command_2_run}")
      ${command_2_run}
      ;;
  esac
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
            RUN_COMMAND_AS "$ANSIBLE_BASEDIR/$ansible_version/venv/bin/pip install --upgrade --requirement ${PYTHON_REQUIREMENTS[$i]}"
        fi
        # 3ed install Ansible in venv
        if [ ${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE} == "pip" ]; then
            echo "| $ansible_version > Using 'pip' as installation type"
            RUN_COMMAND_AS "$ANSIBLE_BASEDIR/$ansible_version/venv/bin/pip install ansible==$ansible_version"
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
            RUN_COMMAND_AS "$ANSIBLE_BASEDIR/$ansible_version/venv/bin/python setup.py install"
        else
            msg_exit "$ansible_version > Unknown installation type ${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE}"
        fi

      # 4th check if we need to setup a label for our installation
      setup_label_symlink $i
      done
}

## check symlink dir and create if needed
##
manage_symlink(){
  set +e
  # $1 src
  # $2 dest (link)
  # $3 global (will run with sudo)
  actual_dest=$(readlink $2)
  if [ "${actual_dest}" != "${1}" ] && ! [ -z "${actual_dest}" ]; then
    ! [[ -z "${SETUP_VERBOSITY}" ]] && echo "|D Attempt to Removing ${2}"
    RUN_COMMAND_AS "rm -f ${2}"
  fi
  set -e
  ! [[ -z "${SETUP_VERBOSITY}" ]] && echo "|D Creating symlink to ${1} ${2}"

  if [ -z "${3}" ]; then
    run_sudo="sudo "
  fi

  RUN_COMMAND_AS "${run_sudo}ln -sf ${1} ${2}"
}

## Setup ansible version label symlink
##
setup_label_symlink() {
  i=${1} # our index in the array
  cd $ANSIBLE_BASEDIR
  if ! [ -z "${ANSIBLE_LABEL[$i]}" ]; then
    echo "| Setup label symlink for ${ANSIBLE_LABEL[$i]} to ${ANSIBLE_BASEDIR}/${ANSIBLE_VERSIONS[$i]}"
    manage_symlink ${ANSIBLE_BASEDIR}/${ANSIBLE_VERSIONS[$i]} ${ANSIBLE_BASEDIR}/${ANSIBLE_LABEL[$i]}
  fi
}

## Check if I can change to root
##
CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1 | grep "load" | wc -l)
if [ ${CAN_I_RUN_SUDO} -eq 0 ] && [ "${SETUP_SUDO_IGNORE}" == "0"  ]; then
  msg_exit "$USER can't run the Sudo command. You might have sudo rights, But password is required. you can run$COLOR_END $COLOR_GRN'sudo whoami && $0'$COLOR_END to use the cached password in sudo"
  exit 1
fi

## Ubuntu setup
##
setup_ubuntu(){
    # Ubuntu
    VER=$(lsb_release -sr)
    echo "| Updating some ubuntu-${VER} packages (might take some time)"
    if [ "${VER}" == "14.04" ]; then
      RUN_COMMAND_AS "sudo apt-get install -y $UBUNTU_PKGS"
    elif [ "${VER}" == "16.04" ]; then
      RUN_COMMAND_AS "sudo apt -y update"
      RUN_COMMAND_AS "sudo apt install -y python-minimal"
      RUN_COMMAND_AS "sudo apt install -y ${UBUNTU_PKGS}"
    else
      msg_warning "Your ubuntu linux version was not tested. It might work"
    fi
}

## Redhat setup
##
setup_redhat(){
  echo "REDHAT STILL EXPERMINTAL"
  exit 1
}

## Get template
avm_script_Setup(){
  filename=$( echo ${0} | sed  's|/||g' )
  ## Temp get stdout
  TEMP_SETUP_VERBOSITY=${SETUP_VERBOSITY}
  SETUP_VERBOSITY="stdout"
  my_temp_dir=$(RUN_COMMAND_AS "mktemp -dt ${filename}.XXXX")
  SETUP_VERBOSITY=${TEMP_SETUP_VERBOSITY}

cat > $my_temp_dir/AVM_YML <<- EOM
---
 - hosts: all
   gather_facts: False
   connection: local
   tasks:
      - template: src="{{ ANSIBLE_VERSION_TEMPLATE_PATH }}" dest="{{ ANSIBLE_BASEDIR }}/avm" owner="{{ SETUP_USER }}" mode=0755
EOM

  # Get ansible yaml and j2 file from github
  RUN_COMMAND_AS "curl -f -s -o $my_temp_dir/AVM_J2 $ANSIBLE_VERSION_J2_HTTPS"

  echo ${my_temp_dir}
}

## Setup avm binary file
##
setup_version_bin() {
  my_temp_dir=$(avm_script_Setup)

  RUN_COMMAND_AS "${ANSIBLE_BASEDIR}/${ANSIBLE_DEFAULT_VERSION}/venv/bin/ansible-playbook -i localhost, $my_temp_dir/AVM_YML \
    -e ANSIBLE_BIN_PATH=$ANSIBLE_BIN_PATH \
    -e ANSIBLE_BASEDIR=$ANSIBLE_BASEDIR \
    -e ANSIBLE_SELECTED_VERSION=$ANSIBLE_DEFAULT_VERSION \
    -e SETUP_USER=$SETUP_USER \
    -e ANSIBLE_VERSION_TEMPLATE_PATH=$my_temp_dir/AVM_J2"

  # Require to run sudo as assumption is it will be global
  echo "| Creating symlink ${ANSIBLE_BASEDIR}/avm ${ANSIBLE_BIN_PATH}/avm"
  manage_symlink ${ANSIBLE_BASEDIR}/avm ${ANSIBLE_BIN_PATH}/avm

  for bin in ansible ansible-doc ansible-galaxy ansible-playbook ansible-pull ansible-vault ansible-console
  do
      # Require to run sudo as assumption is it will be global
      echo "| Creating global symlink ${ANSIBLE_BASEDIR}/bin/${bin} is pointing to ${ANSIBLE_BIN_PATH}/$bin"
      manage_symlink ${ANSIBLE_BASEDIR}/bin/${bin} ${ANSIBLE_BIN_PATH}/$bin RUN_SUDO
  done

  echo "| Setting up default virtualenv to $ANSIBLE_DEFAULT_VERSION"
  RUN_COMMAND_AS "avm set $ANSIBLE_DEFAULT_VERSION"
}

## Check setup home dir
##
! [ -d "$SETUP_USER_HOME" ] && msg_exit "Your home directory \"$SETUP_USER_HOME\" doesn't exist."

## Do some checks user
##
[[ "$(whoami)" == "root" ]] && msg_exit "Please run as a normal user not root."

# Check your distro is supported
##
system=$(uname)
if [ "$system" == "Linux" ]; then
  if [ -f /etc/redhat-release ]; then
    setup_redhat
  elif [ -f /etc/lsb-release ]; then
    setup_ubuntu
  else
    msg_warning "Your linux system was not tested. It might work"
  fi
fi

## Do some checks python curl and easy_install
##
[[ -z "$(which python)" ]] && msg_exit "Opps python is not installed or not in your path."
[[ -z "$(which curl)" ]] && msg_exit "curl is not in your path. Please install it or reference it in your path"
[[ -z "$(which easy_install)" ]] && msg_exit "easy_install is not in your path."

# Install virtual env
sudo -H easy_install --upgrade virtualenv

# Install ansible in the virtual envs
ansible_install_venv

# Setup avm binary file
setup_version_bin

echo "Happy ansibleing..."
exit 0