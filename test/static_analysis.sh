#!/bin/sh

MY_PATH="$(dirname "$0")"              # relative
DIR="$( ( cd "${MY_PATH}" && pwd ) )"  # absolutized and normalized
ROOT_DIR="$( cd "${DIR}/../" && pwd )"

msg_exit(){
    echo "$1" && exit 1
}

check_file(){
    echo "*** Checking $2 in $1"
    cd "${1}" || return
    shellcheck "${2}"
}

hash shellcheck 2> /dev/null || msg_exit "Error: shellcheck is not installed."

check_file "${ROOT_DIR}/test" static_analysis.sh
check_file "${ROOT_DIR}" setup.sh
