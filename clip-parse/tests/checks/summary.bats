#!/usr/bin/env bats

# bats test_tags=invalid, extra-newlines
@test "expect error when invalid summary with trailing new line passed" {
    source ./clip-parse.sh

    ! parser_check_command_summary_correctness '> Some text.
> More information https://example.com.
'
}

# bats test_tags=invalid, extra-newlines
@test "expect error when invalid summary with leading new line passed" {
    source ./clip-parse.sh

    ! parser_check_command_summary_correctness '
> Some text.
> More information https://example.com.'
}

# bats test_tags=invalid, extra-newlines
@test "expect error when invalid summary with several extra lines passed" {
    source ./clip-parse.sh

    ! parser_check_command_summary_correctness '> Some text.

> More information https://example.com.'
}

# bats test_tags=invalid, no-description
@test "expect error when invalid summary without description passed" {
    source ./clip-parse.sh

    ! parser_check_command_summary_correctness '# some

> More information: https://example.com.

- Some text:

`some`
'
}

# bats test_tags=invalid, no-tags
@test "expect error when invalid summary without tags passed" {
    source ./clip-parse.sh

    ! parser_check_command_summary_correctness '# some

> Some text.

- Some text:

`some`
'
}

# bats test_tags=invalid, invalid-order
@test "expect error when invalid summary with invalid order passed" {
    source ./clip-parse.sh

    ! parser_check_command_summary_correctness '# some

> More information: https://example.com.
> Some text.

- Some text:

`some`
'
}

# bats test_tags=valid, summary
@test "expect no error when valid summary passed" {
    source ./clip-parse.sh

    parser_check_command_summary_correctness '> Some text.
> More information https://example.com.'
}
