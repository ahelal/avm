#!/bin/sh

checks_post(){
  print_status "Installing/upgrading virtualenv for Ubuntu"
  if [ -z "$(which pip)" ]; then
    sudo -H easy_install -q --upgrade virtualenv
  else
    sudo -H pip install -q --upgrade virtualenv
  fi
  print_done
}
