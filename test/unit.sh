#!/bin/sh
MY_PATH="$(dirname "${0}")"        # relative
DIR="$( cd "${MY_PATH}" && pwd )"  # absolutized and normalized

cd "${DIR}" || echo "Can't cd into '${DIR}'" && exit

# Install shunit2
if [ ! -d shunit2 ]; then
    git clone https://github.com/kward/shunit2.git
fi
