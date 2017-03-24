#!/bin/sh

general_packages(){
    # yeah serious containers :(
    for package in sed grep wc curl python
    do
        is_installed "${package}"
    done

    ## pip or easyinstall should be installed
    pip_bin=$(is_installed "pip" 1)
    easy_install_bin=$(is_installed "easy_install" 1)

    if [ "${pip_bin}" = "1" ] && [ "${easy_install_bin}" = "1" ]; then
        msg_exit "Opps 'easy_install' or 'pip' is not installed or not in your path."
    fi

}
