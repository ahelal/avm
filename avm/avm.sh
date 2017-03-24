#!/bin/sh
set -e

# avm cli tool

AVM_BASEDIR="{{ AVM_BASEDIR }}"
# Just to fall back to default this will be overwriten later on in the script
ANSIBLE_SELECTED_VERSION="{{ ANSIBLE_SELECTED_VERSION }}"

SETUP_VERSION="${SETUP_VERSION-master}"

## Print Error msg
msg_exit() {
  printf "> %s\n" "$@"
  exit 1
}

## Function: help
print_help() {
echo 'avm
Usage:
    avm  info
    avm  list
    avm  path <version>
    avm  use <version>
    avm  activate <version>
    avm  install (-v version) [-t type] [-l label] [-r requirements]
    avm  upgrade (-c)

Options:
    info                        Show ansible version in use
    list                        List installed versions
    path <version>              Print binary path of specific version
    use  <version>              Use a <version> of ansible
    activate <version>          Activate virtualenv for <version>
    upgrade                     Upgrade avm to latest final release
"""
exit 0
}

print_install_help() {
echo """avm install
options:
  -v|--version              Version to install (this is mandatory)
  -t|--type                 Type of installation git or pip (default PIP)
  -l|--label                Custom label for this installation i.e. v2.1, dev, test, ...
  -r|--requirements         Provide a pip requirements files to install in virutalenv
'
exit 0
}

show_installed(){
  ansible_link="$(readlink "${AVM_BASEDIR}"/bin/ansible)"
  version="$(echo "${ansible_link}" | sed 's|'"$AVM_BASEDIR"'||g ; s|/venv/bin/||g ; s|ansible||g; s|/||g')"
  echo "current version: \"$version\""
}

show_versions(){
  cd "${AVM_BASEDIR}"
  for version in *
  do
    [ "${version}" = "ansible-version" ] && continue
    [ "${version}" = "bin" ] && continue
    [ "${version}" = "avm" ] && continue
    versions_list="${versions_list} '${version}'"
  done
  echo "${versions_list}"
}

# Verify version
verify_version(){
  versions_list="$(show_versions)"
  # loop over version list and check if ANSIBLE_SELECTED_VERSION is there
  found_version="0"
  for version_item in ${versions_list}
  do
    if [ "${version_item}" = "'${ANSIBLE_SELECTED_VERSION}'" ]; then
      found_version="1"
      break
    fi
  done

  if [ "${found_version}" = "0" ]; then
    echo "The desired version \"${ANSIBLE_SELECTED_VERSION}\" is not in the version list."
    echo "available version: ${versions_list}"
    exit 1
  fi
  if ! [ -d "${AVM_BASEDIR}/${ANSIBLE_SELECTED_VERSION}/venv/bin/" ]; then
    msg_exit "Your virtualenv seems to be not installed or incorrect reference. \"$AVM_BASEDIR/${ANSIBLE_SELECTED_VERSION}/venv/bin/\" is not a valid directory"
  fi
}

print_path(){
  verify_version
  echo "${AVM_BASEDIR}/${ANSIBLE_SELECTED_VERSION}/venv/bin/"
}

setup_links(){
    verify_version
    for bin in ansible ansible-doc ansible-galaxy ansible-playbook ansible-pull ansible-vault ansible-console
    do
      if [ -e "${AVM_BASEDIR}/${ANSIBLE_SELECTED_VERSION}/venv/bin/${bin}" ]; then
        ln -sf "${AVM_BASEDIR}/${ANSIBLE_SELECTED_VERSION}/venv/bin/${bin}" "${AVM_BASEDIR}/bin/${bin}"
      else
        echo "skiping '${AVM_BASEDIR}/${ANSIBLE_SELECTED_VERSION}/venv/bin/${bin}' binary is missing."
      fi
    done
    echo "Updated to use ${ANSIBLE_SELECTED_VERSION}"
}

case $1 in
"info" | "installed")
  show_installed
  ;;
"list" | "versions")
  echo "installed versions: $(show_versions)"
  ;;
"path")
  [ -z "$2" ] && msg_exit "'path' requires a version as an argument."
  version="$2"
  export ANSIBLE_SELECTED_VERSION="$2"
  print_path
  ;;
"use" | "set")
  version="$2"
  [ -z "$2" ] && msg_exit "use requires a version as an argument."
  export ANSIBLE_SELECTED_VERSION="$2"
  setup_links
  ;;
"activate" )
    version="${2}"
    [ -z "${version}" ] && msg_exit "activate requires a version as an argument."
    ! [ -z "${AVM_ACTIVATE}" ] && msg_exit "You are allready in anisble env. type 'exit' to quit from virtual env"

    export ANSIBLE_SELECTED_VERSION="$2"
    printf "> Attempt to activate (this will create a subshell). "
    print_path

    mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')
    if [ "${SHELL}" = "/bin/bash" ]; then
        echo ". ~/.bashrc" > "${mytmpdir}/.bashrc"
        echo "export AVM_ACTIVATE=1" >> "${mytmpdir}/.bashrc"
        echo ". $(print_path)/activate" >> "${mytmpdir}/.bashrc"
        /bin/bash --login --init-file "$(print_path)/activate"
    elif [ "${SHELL}" = "/bin/zsh" ]; then
        echo ". ~/.zshrc" > "${mytmpdir}/.zshrc"
        echo "export AVM_ACTIVATE=1" >> "${mytmpdir}/.zshrc"
        echo ". $(print_path)/activate" >> "${mytmpdir}/.zshrc"
        export ZDOTDIR="${mytmpdir} zsh -i"
    else
        msg_exit "${SHELL} is not supported."
    fi
  ;;
"install" )
  [ -z "$2" ] && [ -z "$3" ] && msg_exit "install requires arguments. for more help type 'avm install --help"
  [ "${2}" = "-h" ] || [ "${2}" = "--help" ] && print_install_help
  shift
  while [ $# -gt 1 ]
  do
    key="$1"
    case ${key} in
      -v|--version)
        export ANSIBLE_VERSIONS_0="$2"
        shift ;;
      -t|--type)
        export INSTALL_TYPE_0="$2"
        shift ;;
      -l|--label)
        export ANSIBLE_LABEL_0="$2"
        shift ;;
      -r|--requirements)
        export PYTHON_REQUIREMENTS_0="$2"
        shift ;;
      -h|--help)
        print_install_help;;
      *)
        msg_exit " unkown option ${1} for install."
      ;;
    esac
    shift
  done
  [ -z "${ANSIBLE_VERSIONS_0}" ] && msg_exit " --version is required"
  cd "${AVM_BASEDIR}/.source_git/avm/" || msg_exit "'${AVM_BASEDIR}/.source_git/avm' does not exist"
  # shellcheck disable=SC1091
  . ./setup.sh
  ;;
'')
  print_help
  ;;
*)
  echo "$0: Unkown option '$1'"
  print_help
  ;;
esac

exit 0
