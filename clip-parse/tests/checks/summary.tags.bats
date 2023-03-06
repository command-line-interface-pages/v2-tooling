#!/usr/bin/env bats

# bats test_tags=invalid, extra-spaces
@test "expect error when invalid tag with trailing space passed" {
    source ./clip-parse.sh

    ! __parser_check_command_tag_correctness 'More information '
}

# bats test_tags=invalid, extra-spaces
@test "expect error when invalid tag with leading space passed" {
    source ./clip-parse.sh

    ! __parser_check_command_tag_correctness ' More information'
}

# bats test_tags=invalid, extra-spaces
@test "expect error when invalid tag with several spaces passed" {
    source ./clip-parse.sh

    ! __parser_check_command_tag_correctness 'More  information'
}

# bats test_tags=invalid, no-valid-tag
@test "expect error when invalid tag passed" {
    source ./clip-parse.sh

    ! __parser_check_command_tag_correctness 'Invalid'
}

# bats test_tags=valid, other
@test "expect error when valid tag passed" {
    source ./clip-parse.sh

    __parser_check_command_tag_correctness 'More information'
}