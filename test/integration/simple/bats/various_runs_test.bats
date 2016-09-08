#!/usr/bin/env bats

@test "By default we should be running ansible v1 1.9.x" {
    run ansible --version
    [[ ${lines[0]} =~ "ansible 1.9" ]]
}

@test "Run ansible ad-hoc ping pong" {
    run ansible -i localhost, -c local -m ping all
    [[ ${lines[0]} =~ "localhost | success" ]]
}

@test "Run ansible copy" {
    run ansible -i localhost, -c local -m ping -m copy -a "src=/etc/passwd dest=/tmp/myfile.tmp mode=0666" all
    [[ ${lines[0]} =~ "localhost | success" ]]
}

@test "Run stat on /tmp/myfile.tmp" {
    run stat /tmp/myfile.tmp
    [ $status = 0 ]
}
