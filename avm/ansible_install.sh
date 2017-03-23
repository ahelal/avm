#!/bin/sh

get_variable(){
  python -c "import os; print os.environ.get(\"${1}\",\"${2}\")"
}

ansible_install_venv(){
  # Create base dir
  RUN_COMMAND_AS "mkdir -p ${AVM_BASEDIR}"
  RUN_COMMAND_AS "chmod 0755 ${AVM_BASEDIR}"

  # Create a bin dir in base dir
  RUN_COMMAND_AS "mkdir -p ${AVM_BASEDIR}/bin"
  RUN_COMMAND_AS "chmod 0755 ${AVM_BASEDIR}/bin"
  count_ansible_version=$(printenv | sort | grep ANSIBLE_VERSIONS_  | sed 's/=.*//' | wc -l | tr -d ' ' )
  if [ "${count_ansible_version}" = "0" ]; then
    print_warning "You have not specified any ANSIBLE_VERSIONS_X to install :( so no ansible will be installed."
  else
    print_verbose "Number of Ansible versions to install ${count_ansible_version}"
  fi

  printenv | sort | grep ANSIBLE_VERSIONS_  | sed 's/=.*//' | while read -r item ; do
    index="$(echo "${item}" | sed 's:.*_::')"
    # lets get ANSIBLE_VERSIONS_I INSTALL_TYPE_I PYTHON_REQUIREMENTS_I
    ansible_version=$(get_variable "${item}" )
    python_requirement=$(get_variable "PYTHON_REQUIREMENTS_${index}" )
    install_type=$(get_variable "INSTALL_TYPE_${index}" "${DEFAULT_INSTALL_TYPE}" )
    print_verbose "Install for index(${index}) ${item}=${ansible_version} python_requirement=${python_requirement} install_type=${install_type}"

    RUN_COMMAND_AS "mkdir -p ${AVM_BASEDIR}/${ansible_version}"
    cd "${AVM_BASEDIR}/${ansible_version}"

    # 1st create virtual env for this version
    if [ "${AVM_UPDATE_VENV}" != "no" ] && [ ! -d "./venv" ]; then
      print_status "${ansible_version} | Creating/updating venv for ansible"
      RUN_COMMAND_AS "virtualenv venv"
      print_done
    else
      print_verbose "venv ${ansible_version} exists."
    fi

    # 2nd Check if python requirments file exists and install requirement file
    if ! [ -z "${python_requirement}" ]; then
      print_status "${ansible_version} | Install python requirments file ${python_requirement}"
      RUN_COMMAND_AS "${AVM_BASEDIR}/${ansible_version}/venv/bin/pip install --upgrade --requirement ${python_requirement}"
      print_done
    fi

    # 3ed install Ansible in venv either using pip or git
    if [ "${install_type}" = "pip" ]; then
      print_status "$ansible_version | Running pip install"
      RUN_COMMAND_AS "${AVM_BASEDIR}/${ansible_version}/venv/bin/pip install ansible==${ansible_version}"
      print_done
    elif [ "${install_type}" = "git" ]; then
      source_git_dir=${AVM_BASEDIR}/.source_git
      mkdir -p "${source_git_dir}"
      cd "${source_git_dir}"
      print_status "$ansible_version | Running git clone/checkout"
      if [ -d "ansible/.git" ]; then
        cd "ansible"
        RUN_COMMAND_AS "git pull -q --rebase"
        RUN_COMMAND_AS "git submodule update --quiet --init --recursive"
      else
        RUN_COMMAND_AS "git clone git://github.com/ansible/ansible.git --recursive"
        cd "ansible"
      fi
      RUN_COMMAND_AS "git checkout ${ansible_version}"
      print_done

      print_status "$ansible_version | Running setup from git "
      RUN_COMMAND_AS "${AVM_BASEDIR}/${ansible_version}/venv/bin/python setup.py install"
      print_done
    else
      msg_exit "${ansible_version} | Unknown installation type ${install_type} for ansible_version"
    fi

    # 4th check if we need to setup a label for our installation
    setup_label_symlink "${index}"
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
    print_verbose "Attempt to remove ${2}"
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
  cd "${AVM_BASEDIR}"
  # shellcheck disable=SC2039
  ansible_label=$(get_variable "ANSIBLE_LABEL_${i}")
  ansible_version=$(get_variable "ANSIBLE_VERSIONS_${i}")
  if ! [ -z "${ansible_label}" ]; then
    print_verbose "Setup label symlink for ${ansible_label} to ${AVM_BASEDIR}/${ansible_version}"
    manage_symlink "${AVM_BASEDIR}/${ansible_version}" "${AVM_BASEDIR}/${ansible_label}"
  fi
}

## Setup avm binary file
##
setup_version_bin() {
  print_status "Setting up avm cli command & symlink to ansible binaries."

  # Template the actual avm cli tool and fix perm and owner
  print_verbose "Templating avm cli in ${AVM_BASEDIR}/avm"
  # shellcheck disable=SC2016
  RUN_COMMAND_AS 'sed -e "s%{{ AVM_BASEDIR }}%$AVM_BASEDIR%" -e "s%{{ ANSIBLE_SELECTED_VERSION }}%$ANSIBLE_DEFAULT_VERSION%" "${avm_dir}/avm/avm.sh" > ${AVM_BASEDIR}/avm'
  RUN_COMMAND_AS "sudo chmod 0755 ${AVM_BASEDIR}/avm"
  RUN_COMMAND_AS "sudo chown ${SETUP_USER} ${AVM_BASEDIR}/avm"

  manage_symlink "${AVM_BASEDIR}/avm" "${ANSIBLE_BIN_PATH}/avm"
  for bin in ansible ansible-doc ansible-galaxy ansible-playbook ansible-pull ansible-vault ansible-console
  do
      print_verbose "Creating global symlink ${AVM_BASEDIR}/bin/${bin} is pointing to ${ANSIBLE_BIN_PATH}/$bin"
      manage_symlink "${AVM_BASEDIR}/bin/${bin}" "${ANSIBLE_BIN_PATH}/${bin}" RUN_SUDO
  done
  print_done
}

setup_default_version() {
  if [ -z "${ANSIBLE_DEFAULT_VERSION}" ]; then
      # Try to fall back to first item
      first_item=$(printenv | sort | grep ANSIBLE_VERSIONS_  | sed 's/=.*//' | head -1)
      ansible_version=$(get_variable "${first_item}" )
      ANSIBLE_DEFAULT_VERSION="${ansible_version}"
  fi
  # Fallback to first element
  if [ -z "${ANSIBLE_DEFAULT_VERSION}" ]; then
    print_verbose "No default version set and no fallback."
  else
    print_status "Setting up default version to ${ANSIBLE_DEFAULT_VERSION}"
    RUN_COMMAND_AS "${ANSIBLE_BIN_PATH}/avm set ${ANSIBLE_DEFAULT_VERSION}"
    print_done
  fi

}
