

## Alpine setup
##
setup_alpine(){
  # shellcheck disable=SC1091
  . /etc/os-release
  echo "| Updating some alpine packages (might take some time)"
  if [ "${PRETTY_NAME}" != "Alpine Linux v3.4" ]; then
    print_warning "Your Alpine linux version was not tested. It might work"
  fi
  RUN_COMMAND_AS "sudo /sbin/apk add --no-cache --quiet python py-pip"
  RUN_COMMAND_AS "sudo /sbin/apk --no-cache add --virtual build-dependencies \
                            python-dev libffi-dev openssl-dev build-base git"
}

