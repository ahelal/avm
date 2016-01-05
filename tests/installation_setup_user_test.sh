#!/usr/bin/env bats

@test "Installation check v1 virtualenv has no boto" {    
    run /home/travis-setup/.venv_ansible/v1/venv/bin/python -c "import boto"
    [ $status = 1 ]
}

@test "Installation Check v1 has no git dir" {    
    run stat /home/travis-setup/.venv_ansible/v1/ansible/.git
    [ $status = 1 ]
}

@test "Installation Check v2 has git dir" {    
    run stat /home/travis-setup/.venv_ansible/v2/ansible/.git
    [ $status = 0 ]
}

@test "Check venv_ansible owner is travis-setup" {    
    run stat /home/travis-setup/.venv_ansible/
    [ $status = 0 ]
    [[ ${lines[0]} =~ "travis-setup" ]]
}
