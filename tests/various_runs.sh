#!/usr/bin/env bats

@test "By default we should be running ansible v1 1.9.x" {
    run ansible --version
    [[ ${lines[0]} =~ "ansible 1.9" ]]
}

@test "Run ansible ad-hoc ping pong" {
    run ansible -i localhost, -c local -m ping all
    [ $status = 0 ]
    [[ ${lines[0]} =~ "localhost | success" ]]
}

@test "Run ansible copy" {
    run ansible -i localhost, -c local -m ping -m copy -a "src=various_runs.sh dest=/tmp/various_runs.sh mode=0666" all
    [ $status = 0 ]
    [[ ${lines[0]} =~ "localhost | success" ]]
}

@test "Run stat on /tmp/various_runs.sh" {
    run stat /tmp/various_runs.sh
    [ $status = 0 ]
}
