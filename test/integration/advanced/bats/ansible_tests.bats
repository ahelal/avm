#!/usr/bin/env bats

@test "Check that ansible is installed" {
    command -v ansible
}

@test "Check that ansible-playbook is installed" {
    command -v ansible-playbook
}

@test "Check that ansible-playbook is installed" {
    command -v ansible-playbook
}

@test "Check that ansible-doc is installed" {
    command -v ansible-doc
}

@test "Check that ansible-galaxy is galaxy" {
    command -v ansible-galaxy
}

@test "Check that ansible-playbook is installed" {
    command -v ansible-playbook
}

@test "Check that ansible-pull is installed" {
    command -v ansible-pull
}

@test "Check that ansible-vault is installed" {
    command -v ansible-vault
}

@test "Check that ansible-console is installed" {
    command -v ansible-console
}