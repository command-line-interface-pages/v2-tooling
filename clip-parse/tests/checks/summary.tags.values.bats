#!/usr/bin/env bats

# bats test_tags=invalid, extra-spaces
@test "expect error when invalid tag value with trailing space passed" {
    source ./clip-parse.sh

    ! __parser_check_command_tag_value_correctness 'Internal' 'true '
}

# bats test_tags=invalid, extra-spaces
@test "expect error when invalid tag value with leading space passed" {
    source ./clip-parse.sh

    ! __parser_check_command_tag_value_correctness 'Internal' ' true'
}

# bats test_tags=invalid, no-valid-tag
@test "expect error when invalid tag passed" {
    source ./clip-parse.sh

    ! __parser_check_command_tag_value_correctness 'Invalid' 'Some text.'
}

# bats test_tags=valid, all
@test "expect error when valid tag value value passed" {
    source ./clip-parse.sh

    __parser_check_command_tag_value_correctness 'Internal' true
}