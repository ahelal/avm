#!/usr/bin/env bats

@test "Check that avm is installed" {
    command -v avm
}

@test "Check avm no args. print usage" {
    run avm
    [[ ${lines[1]} =~ "Usage" ]]
}

@test "avm info shows default version v2.1" {
    run avm installed
    [[ ${lines[0]} =~ "v2.1" ]]
}

@test "avm show list should match setup" {
    run avm list
    [[ ${lines[0]} =~ "installed versions: '2.0.2.0' '2.1.1.0' 'devel' 'v2.0' 'v2.1'" ]]
}

@test "avm use to v2.0" {
    command avm use v2.0
    run avm info
    [[ ${lines[0]} =~ "v2.0" ]]
}

@test "avm check version is 2.0" {
    run ansible --version
    [[ ${lines[0]} =~ "ansible 2.0" ]]
}

@test "Ansible version path v2.0" {
    run avm path v2.0
    [[ ${lines[0]} =~ "/home/kitchen/.venv_ansible/v2.0/venv/bin/" ]]
}

@test "avm use v2.1" {
    command avm use v2.1
    run avm info
    [[ ${lines[0]} =~ "v2.1" ]]
}

@test "avm path v2.1" {
    run avm path v2.1
    [[ ${lines[0]} =~ "/home/kitchen/.venv_ansible/v2.1/venv/bin/" ]]
}


