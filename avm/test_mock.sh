#!/bin/sh

# our mock does not exit just prints msg
mock_msg_exit(){
  echo "${1}"
}

# print a username
mock_whoami(){
  if [ "${MOCK_USER}" ]; then
    echo "${MOCK_USER}"
  else
    echo "avm"
  fi
}

mock_sudo_check(){
  if [ -z "${MOCK_SUDO_FAIL}" ]; then
    echo "0"
  else
    echo "1"
  fi
}