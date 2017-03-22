

## Ubuntu setup
##
setup_ubuntu(){
  VER=$(lsb_release -sr)

  #if [ "$[$(date +%s) - $(stat -c %Z /var/lib/apt/periodic/update-success-stamp)]" -ge 600000 ]; then
    print_status "Ubuntu-${VER} apt package update (might take some time)"
    RUN_COMMAND_AS "sudo apt-get -y update"
    print_done
  #else
   # print_verbose "Skipping apt-get update"
 # fi

  if [ "${VER}" = "14.04" ]; then
    print_status "Ubuntu-${VER} installing some apt packages (might take some time)"
    UBUNTU_PKGS="${UBUNTU_PKGS:-python-setuptools python-dev python-pip build-essential libffi-dev libyaml-dev libssl-dev curl software-properties-common}"
    RUN_COMMAND_AS "sudo apt-get install -y ${UBUNTU_PKGS}"
    print_done
  elif [ "${VER}" = "16.04" ]; then
    print_status "Ubuntu-${VER} installing some apt packages (might take some time)"
    UBUNTU_PKGS="${UBUNTU_PKGS:-python-minimal python-setuptools python-pip python-dev build-essential libffi-dev libyaml-dev libssl-dev curl software-properties-common}"
    RUN_COMMAND_AS "sudo apt install -y ${UBUNTU_PKGS}"
    print_done
  else
    print_warning "Your Ubuntu linux version was not tested. It might work"
  fi

  print_status "Installing/upgrading virtualenv for Ubuntu"
  if [ -z "$(which pip)" ]; then
    sudo -H easy_install -q --upgrade virtualenv
  else
    sudo -H pip install -q --upgrade virtualenv
  fi
  print_done
}


