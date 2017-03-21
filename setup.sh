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

# Let's fail
set -e

## Crazy printing stuff
##
MSG_STATUS="0"

## Print status (print newline if verbose)
print_status() {
  printf "[%s] %s ... " "$(date +%H:%M:%S)" "$*"
  if ! [ -z "${AVM_VERBOSITY}" ]; then printf "\n"; MSG_STATUS=1; fi
}

# Print a check to complete the status message (ignore if verbose for prety printing)
print_done() {
  if [ -z "${AVM_VERBOSITY}" ]; then printf "✅ \n"; MSG_STATUS="0";fi
}

print_failed() {
  if [ -z "${AVM_VERBOSITY}" ]; then printf "❌  \n";fi
}


# Print a warning message
print_warning() {
  echo "⚠️  $(tput bold)$(tput setaf 1)$*$(tput sgr0) ⚠️ "
}

# Print a verbose message
print_verbose() {
  if ! [ -z "${AVM_VERBOSITY}" ]; then echo "💻  $(tput bold)$*$(tput sgr0)"; fi
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
    print_error "2. Increase verbosity level i.e. 'AVM_VERBOSITY=v ./YOUR_SETUP'"
    print_error "3. Crazy verbosity i.e. 'AVM_VERBOSITY=vv ./YOUR_SETUP'"
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
  printf "\n$(tput bold)$(tput setaf 2)🎆 🎇 🎆 🎇  Happy Ansibleing$(tput sgr0) 🎆 🎇 🎆 🎇\n"
}

setup_exit() {
  ret="$?"
  if [ "${ret}" = "0" ]; then
    setup_done
  elif [ "${ret}" = "99" ]; then
    :
  else
    # error
    msg_exit
  fi
}

## Setup trap stuf
# shellcheck disable=SC2154
trap setup_exit EXIT
trap setup_canceled INT
## Variable Section

## Setup veboisty could be empty or v or vv'
AVM_VERBOSITY="${AVM_VERBOSITY-}"
AVM_VERBOSITY="$(echo "${AVM_VERBOSITY}" | tr '[:upper:]' '[:lower:]')"
if [ "${AVM_VERBOSITY}" = "" ] || [ "${AVM_VERBOSITY}" = "stdout" ]; then
    true # Cool Do nothing
elif [ "${AVM_VERBOSITY}" = "v" ]; then
  print_warning " verbosity level 1"
elif [ "${AVM_VERBOSITY}" = "vv" ]; then
  print_warning " verbosity level 2"
  set -x
else
  msg_exit "Unknown verbosity ${AVM_VERBOSITY}"
fi

## Run command as a different user if you have SETUP_USER env set
##
RUN_COMMAND_AS() {
  if [ "${SETUP_USER}" = "${USER}" ]; then
    command_2_run="${1}"
  else
    command_2_run=sudo su "${SETUP_USER}" -c "${1}"
  fi

  case "${AVM_VERBOSITY}" in
    '')
      ${command_2_run} > /dev/null
    ;;
    "stdout")
      ${command_2_run}
    ;;
    *)
      (>&2 print_verbose " executing ${command_2_run}")
      ${command_2_run}
      ;;
  esac
}

## Include a file
##
INCLUDE_FILE(){
  print_verbose "Sourcing file '${1}'"
  test -f "${1}" > /dev/null 2>&1
  . "${1}"
}

## Check git
[ -z "$(which git)" ] && msg_exit "git is not installed or not in your path."

# By default what version to use for Jinja2 template
# shellcheck disable=SC2034
AVM_VERSION="${AVM_VERSION-master}"

## What user is use for the setup and he's home dir
SETUP_USER="${SETUP_USER-$USER}"
SETUP_USER_HOME="${SETUP_USER_HOME:-$(eval echo "~${SETUP_USER}")}"
print_verbose "Setup SETUP_USER=${SETUP_USER} and SETUP_USER_HOME=${SETUP_USER_HOME}"

## Ansible virtual environment directory
ANSIBLE_BASEDIR="${ANSIBLE_BASEDIR:-$SETUP_USER_HOME/.venv_ansible}"

AVM_SOURCEDIR="${AVM_SOURCEDIR:-$ANSIBLE_BASEDIR/.source}"

## Supported types is pip and git. If no type is defined pip will be used
DEFAULT_INSTALL_TYPE="${DEFAULT_INSTALL_TYPE:-pip}"

## Array of versions of ansiblet to install and what requirements files for each version
ANSIBLE_VERSIONS="${ANSIBLE_VERSIONS[0]:-"2.2.1.0"}"

## Label of version if any
#ANSIBLE_LABEL="${ANSIBLE_LABEL:-"test_v2"}"

## Default version to use
ANSIBLE_DEFAULT_VERSION="${ANSIBLE_DEFAULT_VERSION:-${ANSIBLE_VERSIONS}}"

## Should we force venv installation
FORCE_VENV_INSTALLATION="${FORCE_VENV_INSTALLATION:-'no'}"

## Ignore sudo errors
SETUP_SUDO_IGNORE="${SETUP_SUDO_IGNORE-0}"

## Ansible bin path it should be something in your path
ANSIBLE_BIN_PATH="${ANSIBLE_BIN_PATH:-/usr/local/bin}"

ANSIBLE_VERSION_J2_HTTPS="${ANSIBLE_VERSION_J2_HTTPS:-https://raw.githubusercontent.com/ahelal/avm/${SETUP_VERSION}/avm.j2}"

print_status "Setting AVM version '${AVM_VERSION}' directory"
######## At this point setup will start ########
## We have 2 paths
##   1- cloning the repo (default option since we will be curling and dont have all the repo)
##   2- Local used for development and in CI for testing
if [  "${AVM_VERSION}" = "local" ]; then
    avm_dir="$(pwd)"
else
    ## Clone
    avm_dir="$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')"
    print_verbose "cloning 'https://github.com/ahelal/avm.git' to ${avm_dir}"
    git clone https://github.com/ahelal/avm.git "${avm_dir}" >/dev/null 2>&1
    cd "${avm_dir}/"
    git checkout "${AVM_VERSION}" >/dev/null 2>&1
fi
print_done

# Do some checks
print_status "Checking your system has minumum requirements"
INCLUDE_FILE "${avm_dir}/avm/checks.sh"
print_done

# Include required files
INCLUDE_FILE "${avm_dir}/avm/_distro.sh"
INCLUDE_FILE "${avm_dir}/avm/ansible_install.sh"

# Install ansible in the virtual envs
ansible_install_venv

# Setup avm binary file
setup_version_bin

exit 0
