
## Ubuntu apt pre-req
UBUNTU_PKGS="${UBUNTU_PKGS:-python-setuptools python-dev build-essential libffi-dev libyaml-dev libssl-dev curl software-properties-common}"


## Ubuntu setup
##
setup_ubuntu(){
  # Ubuntu
  VER=$(lsb_release -sr)
  echo "| Updating some ubuntu-${VER} packages (might take some time)"
  if [ "${VER}" = "14.04" ]; then
    RUN_COMMAND_AS "sudo apt-get install -y ${UBUNTU_PKGS}"
  elif [ "${VER}" = "16.04" ]; then
    RUN_COMMAND_AS "sudo apt -y update"
    RUN_COMMAND_AS "sudo apt install -y python-minimal"
    RUN_COMMAND_AS "sudo apt install -y ${UBUNTU_PKGS}"
  else
    print_warning "Your ubuntu linux version was not tested. It might work"
  fi
}