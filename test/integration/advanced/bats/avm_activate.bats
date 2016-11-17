#!/usr/bin/env bats

@test "avm activte shows it needs argument" {
    run avm activate
    [[ ${lines[0]} =~ "argument" ]]
}

@test "avm activte wrong version fails" {
    run avm activate XXXXX
    [[ ${lines[1]} =~ "available" ]]
}

@test "avm activte wrong version fails" {
    run avm activate v2.1 && echo ${AVM_ACTIVATE} && exit 0
    [[ ${lines[0]} =~ "1" ]]
}