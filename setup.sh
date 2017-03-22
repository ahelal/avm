#!/bin/sh

## First thing what kind of shell are we running. It turns out that is not so easy to find
shell_path="$(ps -o comm=  $$ | tr -d "-" | head -1)" # Get this process name
if ! [ -f "${shell_path}" ]; then shell_path="/bin/${shell_path}"; fi # assume it is in /bin if not full path
shell_help="$(${shell_path} --help 2>&1 | head -1)" # just get help screen
if echo "${shell_help}" | grep bash > /dev/null 2>&1; then
  SHELL_TYPE="bash"
elif echo "${shell_help}" | grep zsh > /dev/null 2>&1; then
  SHELL_TYPE="zsh"
elif echo "${shell_help}" | grep BusyBox > /dev/null 2>&1; then
  SHELL_TYPE="BusyBox"
elif echo "${shell_help}" | grep Illegal > /dev/null 2>&1 && readlink "${shell_path}" | grep "dash"; then
  SHELL_TYPE="dash"
else
    echo "**** WARNING I HAVE NO IDEA WHAT KIND OF SHELL YOU ARE RUNNNING ****"
    echo "**** Might not work. Probably will not if it does let me know :)****"
fi

set -e

## default variable
MSG_STATUS="0"
CLEAN_DIR="0"

## Crazy printing stuff
##

## Print status (print newline if verbose)
print_status() {
  printf "[%s] %s ... " "$(date +%H:%M:%S)" "$*"
  if ! [ -z "${AVM_VERBOSE}" ]; then printf "\n"; MSG_STATUS=1; fi
}

# Print a check to complete the status message (ignore if verbose for prety printing)
print_done() {
  if [ -z "${AVM_VERBOSE}" ]; then printf "✅ \n"; MSG_STATUS="0";fi
}

print_failed() {
  if [ -z "${AVM_VERBOSE}" ]; then printf "❌  \n";fi
}

# Print a warning message
print_warning() {
  echo "⚠️  $(tput bold)$(tput setaf 1)$*$(tput sgr0) ⚠️ "
}

# Print a verbose message
print_verbose() {
  if ! [ -z "${AVM_VERBOSE}" ]; then echo "💻  $(tput bold)$*$(tput sgr0)"; fi
}

# Print a red error
print_error() {
  printf "$(tput bold)$(tput setaf 1)%s$(tput sgr0)\n" "$@" >&2
}

## Print Error msg and exit
##
msg_exit() {
  if [ "${MSG_STATUS}" = "1" ]; then print_failed; fi
  printf "\n"
  if ! [ -z "${1}" ]; then
    print_error "Setup failed 😢."
    print_error "${1}"
  else
    print_error "Setup failed 😢. You can try the folloiwng"
    print_error "1. Running the setup again."
    print_error "2. Increase verbosity level i.e. 'AVM_VERBOSE=v ./YOUR_SETUP'"
    print_error "3. Crazy verbosity i.e. 'AVM_VERBOSE=vv ./YOUR_SETUP'"
    print_error "5. Open an issue and paste the out REMOVE any sensitve data"
  fi
  exit 99
}

setup_canceled() {
  printf "\n"
  print_warning "Setup aborted by user 😱. You can run it again later."
  exit 130
}

# Print a happy green message
setup_done() {
  printf "\n%s%s🎆 🎇 🎆 🎇  Happy Ansibleing%s 🎆 🎇 🎆 🎇\n" "$(tput bold)" "$(tput setaf 2)" "$(tput sgr0)"
}

setup_exit() {
  ret="$?"
  if [ "${CLEAN_DIR}" = "1" ]; then
    print_verbose "Remove temp dir located in ${avm_dir}"
    rm -rf "${avm_dir}"
  fi
  if [ "${ret}" = "0" ]; then
    setup_done
  elif [ "${ret}" = "99" ]; then
    : # We failed lets not do anything :(
  elif [ "${ret}" = "130" ]; then
    : # User cancled
  else
    # error
    msg_exit
  fi
}

## Setup signal traps
trap setup_exit EXIT
trap setup_canceled INT

## Setup veboisty could be empty or v or vv'
AVM_VERBOSE="${AVM_VERBOSE-}"
AVM_VERBOSE="$(echo "${AVM_VERBOSE}" | tr '[:upper:]' '[:lower:]')"
if [ "${AVM_VERBOSE}" = "" ] || [ "${AVM_VERBOSE}" = "stdout" ]; then
    : # Cool Do nothing
elif [ "${AVM_VERBOSE}" = "v" ]; then
  print_warning " verbosity level 1"
elif [ "${AVM_VERBOSE}" = "vv" ]; then
  print_warning " verbosity level 2"
  set -x
else
  msg_exit "Unknown verbosity ${AVM_VERBOSE}"
fi

## Run command as a different user if you have SETUP_USER env set
##
RUN_COMMAND_AS() {
  if [ "${SETUP_USER}" = "${USER}" ]; then
    command_2_run=${*}
  else
    command_2_run=sudo su "${SETUP_USER}" -c "${*}"
  fi
  case "${AVM_VERBOSE}" in
    '')
      eval "${command_2_run}" > /dev/null 2>&1
    ;;
    "stdout")
      eval "${command_2_run}"
    ;;
    *)
      (>&2 print_verbose "Executing ${command_2_run}")
      eval "${command_2_run}"
      ;;
  esac
}

## Include a file
##
INCLUDE_FILE(){
  print_verbose "Sourcing file '${1}'"
  test -f "${1}"
  # shellcheck disable=SC1090
  . "${1}"
}

## Good to know what shell
print_verbose "AVM run using shell=${SHELL_TYPE}"

## Check if git is installed
[ -z "$(which git)" ] && msg_exit "git is not installed or not in your path."

# AVM version to install. Supports git releases (default to master)
# if set to "local" will use pwd good for debuging and ci
AVM_VERSION="${AVM_VERSION-master}"

## What user is used for the setup and he's home dir
SETUP_USER="${SETUP_USER-$USER}"
SETUP_USER_HOME="${SETUP_USER_HOME:-$(eval echo "~${SETUP_USER}")}"
print_verbose "Setup SETUP_USER=${SETUP_USER} and SETUP_USER_HOME=${SETUP_USER_HOME}"

## AVM base dir (default to ~/.avm)
AVM_BASEDIR="${AVM_BASEDIR:-$SETUP_USER_HOME/.avm}"

## Supported types is pip and git. If no type is defined pip will be used
DEFAULT_INSTALL_TYPE="${DEFAULT_INSTALL_TYPE:-pip}"

## Array of versions of ansiblet to install and what requirements files for each version
ANSIBLE_VERSIONS="${ANSIBLE_VERSIONS_0:-"2.2.1.0"}"

## Label of version if any
#ANSIBLE_LABEL="${ANSIBLE_LABEL:-"test_v2"}"

## Default version to use
ANSIBLE_DEFAULT_VERSION="${ANSIBLE_DEFAULT_VERSION:-${ANSIBLE_VERSIONS}}"

## Should we force venv installation
AVM_UPDATE_VENV="${AVM_UPDATE_VENV:-'no'}"

## Ignore sudo errors
AVM_IGNORE_SUDO="${AVM_IGNORE_SUDO-0}"

## Ansible bin path it should be something in your path
ANSIBLE_BIN_PATH="${ANSIBLE_BIN_PATH:-/usr/local/bin}"

## We have 2 options depanding on verion
##   1- Local used for development and in CI for testing
##   2- Cloning the repo from github then checking the version
print_status "Setting AVM version '${AVM_VERSION}' directory"
if [ "${AVM_VERSION}" = "local" ]; then
    MY_PATH="$(dirname "${0}")"        # relative
    DIR="$( cd "${MY_PATH}" && pwd )"  # absolutized and normalized
    avm_dir="${DIR}"
else
    avm_dir="$(mktemp -d 2> /dev/null || mktemp -d -t 'mytmpdir')"
    print_verbose "cloning 'https://github.com/ahelal/avm.git' to ${avm_dir}"
    git clone https://github.com/ahelal/avm.git "${avm_dir}" > /dev/null 2>&1
    cd "${avm_dir}"
    print_verbose "checking out ${AVM_VERSION}"
    git checkout "${AVM_VERSION}" > /dev/null 2>&1
    CLEAN_DIR="1"
fi
print_done

print_status "Checking general system has minumum requirements"
INCLUDE_FILE "${avm_dir}/avm/checks_general.sh"
general_check
print_done

# include distro files (might install some stuff if needed)
INCLUDE_FILE "${avm_dir}/avm/_distro.sh"
supported_distro

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

exit 0
