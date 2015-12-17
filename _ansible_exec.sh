#!/bin/bash
set -e

COLOR_END='\e[0m'
COLOR_RED='\e[0;31m' # Red

msg_exit() { 
    printf "$0 Error: $COLOR_RED$@$COLOR_END\nExiting...\n" && exit 1 
}

# Function to Run 
execute_program () {
    if [ -x "$program_to_run" ]; then
        $program_to_run $program_arg
        exit $?
    else
        msg_exit "$program_to_run is not executable or file does not exist."
        exit 1
    fi
}

# Check env
[ -z "$ANSIBLE_VENV" ] && msg_exit "You dont have ANSIBLE_VENV defined. This must be defined in your environment. As hellofresh is using python virtualenv."

# Enable the Virtual env
source $ANSIBLE_VENV/venv/bin/activate

# Parse 
program_name="${0##*/}"
program_arg="$@"
program_to_run="$ANSIBLE_VENV/venv/bin/${program_name}"
# Call function
execute_program
