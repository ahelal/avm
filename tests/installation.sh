#!/usr/bin/env bats


@test "Installation Check boto is installed by installer on v2" {
    command ansible-version set v2
    run python -c "import boto"
    [ $status = 0 ]
}

@test "Installation Run setup again TRAVIS_BUILD_DIR/example/travis-test." {
    run $TRAVIS_BUILD_DIR/example/travis-test.sh
    [ $status = 0 ]
}