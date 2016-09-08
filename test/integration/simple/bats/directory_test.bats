#!/usr/bin/env bats

@test "Installation check v1 virtualenv has no boto" {
    run /home/kitchen/.venv_ansible/v1/venv/bin/python -c "import boto"
    [ $status = 1 ]
}

@test "Installation Check v1 has no git dir" {
    run stat /home/kitchen/.venv_ansible/v1/ansible/.git
    [ $status = 1 ]
}

@test "Installation Check v2 has no git dir" {
    run stat /home/kitchen/.venv_ansible/v2/ansible/.git
    [ $status = 1 ]
}

@test "Installation Check devel has git dir" {
    run stat /home/kitchen/.venv_ansible/devel/ansible/.git
    [ $status = 0 ]
}

@test "Check venv_ansible owner is kitchen" {
    run stat /home/kitchen/.venv_ansible/
    [ $status = 0 ]
    [[ ${lines[0]} =~ "kitchen" ]]
}
