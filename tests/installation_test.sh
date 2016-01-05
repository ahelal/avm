#!/usr/bin/env bats

@test "Installation check v1 virtualenv has no boto" {    
    run $HOME/.venv_ansible/v1/venv/bin/python -c "import boto"
    [ $status = 1 ]
}

@test "Installation Check v1 has no git dir" {    
    run stat $HOME/.venv_ansible/v1/ansible/.git
    [ $status = 1 ]
}

@test "Installation check v2 virtualenv has no boto" {      
    run $HOME/.venv_ansible/v2/venv/bin/python -c "import boto" 
    [ $status = 0 ]
}

@test "Installation Check v2 has git dir" {    
    run stat $HOME/.venv_ansible/v2/ansible/.git
    [ $status = 0 ]
}

