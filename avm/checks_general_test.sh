#!/bin/sh
# file: checks_general.sh

MY_PATH="$(dirname "${0}")"        # relative
DIR="$( cd "${MY_PATH}" && pwd )"  # absolutized and normalized

oneTimeSetUp()
{
  # Mocking
  . "${DIR}/test_mock.sh"
  alias msg_exit=mock_msg_exit
  alias whoami=mock_whoami

  # Intialize some variables
  export SETUP_USER_HOME="/tmp"

  # shellcheck disable=SC1091
  . "${DIR}/checks_general.sh"
}

testUserNotRoot()
{
  export MOCK_USER="Group"
  assertEquals "$(general_check | wc -c | tr -d ' ')" 0
}

testUserRoot()
{
  export MOCK_USER="root"
  assertTrue general_check | grep "not root"
}

testNonExistentHomeDir(){
  export SETUP_USER_HOME="/tmpXa/cnasd/asdas1"
  assertTrue general_check | grep "doesn't exist"
}

testUserWithoutSudo(){
  export MOCK_SUDO_FAIL="X"
  assertTrue general_check | grep "sudo rights"
}

testUserWithoutSudoAndIgnoreFlag(){
  export MOCK_SUDO_FAIL="X"
  export AVM_IGNORE_SUDO="1"
  assertEquals "$(general_check | wc -c | tr -d ' ')" 0
}

# load shunit2
# shellcheck disable=SC1091
. ../test/shunit2/source/2.1/src/shunit2
