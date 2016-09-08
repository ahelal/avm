#!/usr/bin/env bats

@test "Check that avm is installed" {
    command -v avm
}

@test "Check avm no args. print usage" {
    run avm
    [[ ${lines[1]} =~ "Usage" ]]
}

@test "avm info shows default version v1" {
    run avm installed
    [[ ${lines[0]} =~ "v1" ]]
}

@test "avm show list should match setup" {
    run avm list
    [[ ${lines[0]} =~ "current installed version: '1.9.6' '2.1.1.0' 'devel' 'v1' 'v2'" ]]
}

@test "avm use to v2" {
    command avm use v2
    run avm info
    [[ ${lines[0]} =~ "v2" ]]
}

@test "avm check version is 2.1" {
    run ansible --version
    [[ ${lines[0]} =~ "ansible 2.1" ]]
}

@test "avm use v1" {
    command avm use v1
    run avm info
    [[ ${lines[0]} =~ "v1" ]]
}

@test "avm path v1" {
    run avm path v1
    [[ ${lines[0]} =~ "/home/kitchen/.venv_ansible/v1/venv/bin/" ]]
}

@test "Ansible version path v2" {
    run avm path v2
    [[ ${lines[0]} =~ "/home/kitchen/.venv_ansible/v2/venv/bin/" ]]
}
