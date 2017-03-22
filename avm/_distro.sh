#!/bin/sh

# Check your distro is supported
##
supported_distro(){
  system=$(uname)
  if [ "${system}" = "Linux" ]; then
    # shellcheck disable=SC1091
    [ -f  /etc/os-release ] && . /etc/os-release
    if [ -f /etc/redhat-release ]; then
      print_verbose "Your system is REDHAT"
      setup_redhat
    elif [ -f /etc/lsb-release ]; then
      print_verbose "Your system is Ubuntu"
      INCLUDE_FILE "${avm_dir}/avm/_distro_ubuntu.sh"
      setup_ubuntu
    elif [ "${ID}" = "alpine" ]; then
      print_verbose "Your system is Alpine"
      INCLUDE_FILE "${avm_dir}/avm/_distro_alpine.sh"
      setup_alpine
    else
      print_warning "Your linux system was not tested. It might work!"
    fi
  elif [ "${system}" = "Darwin" ]; then
    print_verbose "Your system is Mac"
    INCLUDE_FILE "${avm_dir}/avm/_distro_darwin.sh"
  else
    msg_exit "Your are not running Linux or Mac. I don't know what to do :|"
  fi
}
