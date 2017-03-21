#!/bin/sh

print_status "Installing/upgrading virtualenv for MAC."
# Install virtual env
if ! [ -z "$(which pip)" ]; then
  sudo -H pip install -q --upgrade virtualenv
else
  sudo -H easy_install -q --upgrade virtualenv
fi
print_done
