#!/bin/sh

general_check(){
  ## We should not be root
  [ "$(whoami)" = "root" ] && msg_exit "Please run as a normal user not root."

  ## We should have sudo rights
  set +e
  CAN_I_RUN_SUDO="$(sudo -n uptime 2>&1 | grep "load" -c)"
  if [ "${CAN_I_RUN_SUDO}" = "0" ] && [ "${AVM_IGNORE_SUDO}" = "0" ]; then
    msg_exit "${USER} can not run the sudo command. You might have sudo rights, but password is required. you can run 'sudo true' to cache the password in sudo then run setup."
  fi
  set -e

  ## Setup user home dir should exist
  if [ ! -d "${SETUP_USER_HOME}" ]; then
    msg_exit "Your home directory \"${SETUP_USER_HOME}\" doesn't exist."
  fi
}
