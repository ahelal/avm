#!/bin/sh
set -e

## First thing what kind of shell are we running. It turns out that is not so easy to find
## Really unreliable and should be changed :(
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

## default variable
MSG_STATUS="0"
avm_dir=""

## Check a command
##  $1 binary to check
##  $2 report but don't fail
is_installed(){
  if command -v "${1}" > /dev/null 2>&1; then
    fail="0"
  else
    fail="1"
  fi
  if ! [ -z "${2}" ]; then
    echo "${fail}"
  else
    if [ "${fail}" = "1" ]; then msg_exit "Opps '${1}' is not installed or not in your path."; fi
  fi
}

tput_installed=$(is_installed "tput" 1)
tput_alternative(){
  printf "%s" "${*}"
}
if [ "${tput_installed}" = "1" ]; then
  alias tput=tput_alternative
fi

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
## $1 optional msg
msg_exit() {
  if [ "${MSG_STATUS}" = "1" ]; then print_failed; fi
  printf "\n"
  if ! [ -z "${1}" ]; then
    # We know why it failed
    print_error "Setup failed 😢."
    print_error "${1}"
  else
    print_error "Setup failed 😢. You can try the folloiwng"
    print_error "1. Running the setup again."
    print_error "2. Increase verbosity level by populating 'AVM_VERBOSE=v' supports '', 'v', 'vv' or 'vvv'"
    print_error "3. Open an issue and paste the out REMOVE any sensitve data"
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

setup_verboisty(){
  ## Setup verbosity could be empty or v, vv or vvv'
  ##      Show only status messages
  ##  v   show verbose messages, but mute stdout, stderr
  ##  vv  show verbose messages, show stdout, stderr
  ##  vvv show verbose messages, show stdout, stderr and set -x
  AVM_VERBOSE="${AVM_VERBOSE-}"
  AVM_VERBOSE="$(echo "${AVM_VERBOSE}" | tr '[:upper:]' '[:lower:]')"
  if [ "${AVM_VERBOSE}" = "" ] || [ "${AVM_VERBOSE}" = "stdout" ]; then
      : # Cool Do nothing
  elif [ "${AVM_VERBOSE}" = "v" ]; then
    print_warning " verbosity level 1"
  elif [ "${AVM_VERBOSE}" = "vv" ]; then
    print_warning " verbosity level 2"
  elif [ "${AVM_VERBOSE}" = "vvv" ]; then
    print_warning " verbosity level 3"
    set -x
  else
    msg_exit "Unknown verbosity ${AVM_VERBOSE}"
  fi
}
setup_verboisty

## Run command as a different user if you have SETUP_USER env set
##
RUN_COMMAND_AS() {
  if [ "${SETUP_USER}" = "${USER}" ]; then
    command_2_run=${*}
  else
    command_2_run=sudo su "${SETUP_USER}" -c "${*}"
  fi
  case "${AVM_VERBOSE}" in
    '' | 'v')
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
  if ! [ -f "${1}" ]; then
   msg_exit "Failed to include file ${1}"
  fi
  # shellcheck disable=SC1090
  . "${1}"
}

## Manage git
##
## $1 git repo (required)
## $2 package name (required)
## $3 branch (required)
## $4 return variable name (required)
## $5 submodules upgdate
manage_git(){
    git_repo="${1}"
    package_name="${2}"
    branch="${3}"
    submodule="${5}"
    #
    source_git_dir="${AVM_BASEDIR}/.source_git"
    app_git_dir="${source_git_dir}/${package_name}"

    RUN_COMMAND_AS "mkdir -p ${source_git_dir}"
    if ! [ -d "${app_git_dir}/.git" ]; then
      cd "${source_git_dir}" || msg_exit "Failed to cd into '${source_git_dir}'"
      print_verbose "Cloning '${git_repo}' to ${app_git_dir}"
      RUN_COMMAND_AS "git clone ${git_repo} --recursive"
    else
      RUN_COMMAND_AS "git fetch origin"
    fi

    # will also run this first run :(
    print_verbose "checking out '${branch}' from '${git_repo}'"
    cd "${app_git_dir}"
    RUN_COMMAND_AS "git checkout ${branch}"
    RUN_COMMAND_AS "git pull -q --rebase"

    if [ -z "${submodule}" ]; then
        print_verbose "git updating submodule for '${git_repo}'"
        cd "${source_git_dir}/${package_name}"
        RUN_COMMAND_AS "git submodule update --quiet --init --recursive"
    fi
    # Return path
    eval "${4}=${source_git_dir}/${package_name}"
}

## Good to know what shell
print_verbose "AVM run using shell=${SHELL_TYPE}"

# AVM version to install. Supports git releases (default to master)
# if set to "local" will use pwd good for debuging and CI
AVM_VERSION="${AVM_VERSION-master}"

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

## We have 2 options depanding on verion
##  1- local used for development and in CI for testing
##  2- Cloning the repo from github then checking the version
avm_dir_setup(){
  print_status "Setting AVM version '${AVM_VERSION}' directory"
  is_installed "git"
  if [ "${AVM_VERSION}" = "local" ]; then
      MY_PATH="$(dirname "${0}")"        # relative
      DIR="$( cd "${MY_PATH}" && pwd )"  # absolutized and normalized
      avm_dir="${DIR}"
  else
      manage_git https://github.com/ahelal/avm.git avm "${AVM_VERSION}" avm_dir
  fi
  print_done
}
avm_dir_setup

# Include Main file
INCLUDE_FILE "${avm_dir}/avm/main.sh"

exit 0
