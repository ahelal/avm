#!/usr/bin/env bats

@test "Check that ansible-version is installed" {
    command -v ansible-version
}

@test "Ansible version no args. print usage" {
    run ansible-version
    [[ ${lines[1]} =~ "Usage" ]]
}

@test "Ansible version show installed default version v1" {
    run ansible-version installed
    [[ ${lines[0]} =~ "v1" ]]
}

@test "Ansible version show versions in virtualvenv 1.9.4 stable-2.0 v1 v2" {
    run ansible-version versions
    [[ ${lines[0]} =~ "current installed version: '1.9.4' 'stable-2.0' 'v1' 'v2' " ]]
}

@test "Ansible version set to v2" {
    command ansible-version set v2
    run ansible-version installed 
    [[ ${lines[0]} =~ "v2" ]]
}

@test "Ansible version check version is 2.0" {
    run ansible --version
    [[ ${lines[0]} =~ "ansible 2.0" ]]
}

@test "Ansible version set to v1" {
    command ansible-version set v1
    run ansible-version installed 
    [[ ${lines[0]} =~ "v1" ]]
}

@test "Ansible version path v1" {
    run ansible-version path v1
    [[ ${lines[0]} =~ "/home/travis/.venv_ansible/v1/venv/bin/" ]]
}

@test "Ansible version path v2" {
    run ansible-version path v2
    [[ ${lines[0]} =~ "/home/travis/.venv_ansible/v2/venv/bin/" ]]
}
