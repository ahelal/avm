#!/bin/sh

general_packages(){
    ## Python should be installed
    [ -z "$(which python)" ] && msg_exit "Opps python is not installed or not in your path."

    ## Curl should be installed
    [ -z "$(which curl)" ] && msg_exit "curl is not installed or not in your path."

    ## sed should be installed
    [ -z "$(which sed)" ] && msg_exit "sed is not installed or not in your path."

    ## wc should be installed
    [ -z "$(which wc)" ] && msg_exit "wc is not installed or not in your path."

    ## pip or easyinstall should be installed
    if [ -z "$(which easy_install)" ] && [ -z "$(which pip)" ]; then
    msg_exit "easy_install or pip is not installed or not in your path."
    fi
}
