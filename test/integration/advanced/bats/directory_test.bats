#!/usr/bin/env bats

@test "Installation check v2.0 virtualenv has boto" {
    run /home/kitchen/.venv_ansible/v2.0/venv/bin/python -c "import boto3"
    [ $status = 0 ]
}

@test "Installation Check v2.0 has no git dir" {
    run stat /home/kitchen/.venv_ansible/v2.0/ansible/.git
    [ $status = 1 ]
}

@test "Installation check v2.1 virtualenv has no boto" {
    run /home/kitchen/.venv_ansible/v2.1/venv/bin/python -c "import boto3"
    [ $status = 1 ]
}

@test "Installation Check v2.1 has no git dir" {
    run stat /home/kitchen/.venv_ansible/v2.1/ansible/.git
    [ $status = 1 ]
}

@test "Installation check devel virtualenv has boto" {
    run /home/kitchen/.venv_ansible/devel/venv/bin/python -c "import boto3"
    [ $status = 0 ]
}

@test "Installation Check devl has git dir" {
    run stat /home/kitchen/.venv_ansible/devel/ansible/.git
    [ $status = 0 ]
}

@test "Check venv_ansible owner is kitchen" {
    run stat /home/kitchen/.venv_ansible/
    [ $status = 0 ]
    [[ ${lines[0]} =~ "kitchen" ]]
}
