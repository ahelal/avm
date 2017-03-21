#!/bin/sh

## Create Virtual environment
##
ansible_install_venv(){
  # Create base dir
  RUN_COMMAND_AS "mkdir -p ${ANSIBLE_BASEDIR}"
  RUN_COMMAND_AS "chmod 0755 ${ANSIBLE_BASEDIR}"
  # Create a bin dir in base dir
  RUN_COMMAND_AS "mkdir -p ${ANSIBLE_BASEDIR}/bin"
  RUN_COMMAND_AS "chmod 0755 ${ANSIBLE_BASEDIR}/bin"
  for i in $(seq 1 ${#ANSIBLE_VERSIONS[@]})
  do
    i=$((i-1))
    # shellcheck disable=SC2039
    ansible_version="${ANSIBLE_VERSIONS[$i]}"

    RUN_COMMAND_AS "mkdir -p ${ANSIBLE_BASEDIR}/${ansible_version}"
    cd "${ANSIBLE_BASEDIR}/${ansible_version}"

    # 1st create virtual env for this version
    if [ "${FORCE_VENV_INSTALLATION}" != "no" ] && [ ! -d "./venv" ]; then
      print_status "${ansible_version} | Creating/updating venv for ansible"
      RUN_COMMAND_AS "virtualenv venv"
      print_done
    else
      print_verbose "venv ${ansible_version} exists."
    fi

    # 2nd Check if python requirments file exists and install requirement file
    # shellcheck disable=SC2039
    if ! [ -z "${PYTHON_REQUIREMENTS[$i]}" ]; then
      print_status "${ansible_version} | Install python requirments file ${PYTHON_REQUIREMENTS[$i]}"
      RUN_COMMAND_AS "${ANSIBLE_BASEDIR}/${ansible_version}/venv/bin/pip install --upgrade --requirement ${PYTHON_REQUIREMENTS[$i]}"
      print_done
    fi
    # 3ed install Ansible in venv
    if [ "${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE}" = "pip" ]; then
      print_status "$ansible_version | Running pip"
      RUN_COMMAND_AS "${ANSIBLE_BASEDIR}/${ansible_version}/venv/bin/pip install ansible==${ansible_version}"
      print_done
    elif [ "${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE}" = "git" ]; then
      [ -z "$(which git)" ] && msg_exit "git is not installed"
      print_status "$ansible_version | Running git clone/checkout"
      if [ -d "ansible/.git" ]; then
        cd "${ANSIBLE_BASEDIR}/${ansible_version}/ansible"
        RUN_COMMAND_AS "git pull -q --rebase"
        RUN_COMMAND_AS "git submodule update --quiet --init --recursive"
      else
        RUN_COMMAND_AS "git clone git://github.com/ansible/ansible.git --recursive"
      fi
      print_done
      cd "${ANSIBLE_BASEDIR}/${ansible_version}/ansible"
      # Check out the version and install it
      print_status "$ansible_version | Running installation from git "
      RUN_COMMAND_AS "git checkout ${ansible_version}"
      RUN_COMMAND_AS "${ANSIBLE_BASEDIR}/${ansible_version}/venv/bin/python setup.py install"
      print_done
    else
      msg_exit "${ansible_version} | Unknown installation type ${INSTALL_TYPE[i]:-$DEFAULT_INSTALL_TYPE}"
    fi

    # 4th check if we need to setup a label for our installation
    setup_label_symlink $i
  done
}


## check symlink dir and create if needed
##
manage_symlink(){
  set +e
  # ${1} src
  # $2 dest (link)
  # $3 global (will run with sudo)
  actual_dest="$(readlink "${2}")"
  if [ "${actual_dest}" != "${1}" ] && ! [ -z "${actual_dest}" ]; then
    print_verbose "Attempt to Removing ${2}"
    RUN_COMMAND_AS "rm -f ${2}"
  fi
  set -e
  print_verbose "Creating symlink to ${1} ${2}"

  if [ -z "${3}" ]; then
    run_sudo="sudo "
  fi

  RUN_COMMAND_AS "${run_sudo}ln -sf ${1} ${2}"
}

## Setup ansible version label symlink
##
setup_label_symlink() {
  i="${1}" # our index in the array
  cd "${ANSIBLE_BASEDIR}"
  # shellcheck disable=SC2039
  if ! [ -z "${ANSIBLE_LABEL[$i]}" ]; then
    print_verbose "Setup label symlink for ${ANSIBLE_LABEL[$i]} to ${ANSIBLE_BASEDIR}/${ANSIBLE_VERSIONS[$i]}"
    manage_symlink "${ANSIBLE_BASEDIR}/${ANSIBLE_VERSIONS[$i]}" "${ANSIBLE_BASEDIR}/${ANSIBLE_LABEL[$i]}"
  fi
}

## Setup avm binary file
##
setup_version_bin() {
  print_status "Setting up avm command & symlink to ansible binary."
  export ANSIBLE_RETRY_FILES_ENABLED=1
  RUN_COMMAND_AS "${ANSIBLE_BASEDIR}/${ANSIBLE_DEFAULT_VERSION}/venv/bin/ansible-playbook -i localhost, "${avm_dir}/avm/avm.yml" \
    -e ANSIBLE_BIN_PATH=${ANSIBLE_BIN_PATH} \
    -e ANSIBLE_BASEDIR=${ANSIBLE_BASEDIR} \
    -e ANSIBLE_SELECTED_VERSION=${ANSIBLE_DEFAULT_VERSION} \
    -e SETUP_USER=${SETUP_USER} \
    -e ANSIBLE_VERSION_TEMPLATE_PATH=${avm_dir}/avm/avm.j2"

  # Require to run sudo as assumption is it will be global
  manage_symlink "${ANSIBLE_BASEDIR}/avm" "${ANSIBLE_BIN_PATH}/avm"
  for bin in ansible ansible-doc ansible-galaxy ansible-playbook ansible-pull ansible-vault ansible-console
  do
      print_verbose "Creating global symlink ${ANSIBLE_BASEDIR}/bin/${bin} is pointing to ${ANSIBLE_BIN_PATH}/$bin"
      manage_symlink "${ANSIBLE_BASEDIR}/bin/${bin}" "${ANSIBLE_BIN_PATH}/${bin}" RUN_SUDO
  done
  print_done

  print_status "Setting up default virtualenv to ${ANSIBLE_DEFAULT_VERSION}"
  RUN_COMMAND_AS "${ANSIBLE_BIN_PATH}/avm set ${ANSIBLE_DEFAULT_VERSION}"
  print_done
}
