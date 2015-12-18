#!/usr/bin/env bats

#Switch to v2
ansible-version set v2

@test "Installation Check boto is installed by installer on v2" {    
    run python -c "import boto"
    [ $status = 0 ]
}

