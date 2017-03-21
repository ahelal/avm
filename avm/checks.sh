#!/bin/sh

## Do some checks

## Check if running use can change to root
##

set +e
CAN_I_RUN_SUDO="$(sudo -n uptime 2>&1 | grep "load" -c)"
if [ "${CAN_I_RUN_SUDO}" = "0" ] && [ "${SETUP_SUDO_IGNORE}" = "0" ]; then
  msg_exit "${USER} can not run the sudo command. You might have sudo rights, but password is required. you can run 'sudo true' to cache the password in sudo then run setup."
fi
set -e

## Check setup home dir
##
! [ -d "${SETUP_USER_HOME}" ] && msg_exit "Your home directory \"${SETUP_USER_HOME}\" doesn't exist."

## Do some checks user
##
[ "$(whoami)" = "root" ] && msg_exit "Please run as a normal user not root."

[ -z "$(which python)" ] && msg_exit "Opps python is not installed or not in your path."

[ -z "$(which curl)" ] && msg_exit "curl is not installed or not in your path."

if [ -z "$(which easy_install)" ] && [ -z "$(which pip)" ]; then
   msg_exit "easy_install or pip is not installed or not in your path."
fi
