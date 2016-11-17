#!/usr/bin/env bats

@test "avm activte shows it needs argument" {
    run avm activate
    [[ ${lines[0]} =~ "argument" ]]
}

@test "avm activte wrong version fails" {
    run avm activate XXXXX
    [[ ${lines[1]} =~ "available" ]]
}