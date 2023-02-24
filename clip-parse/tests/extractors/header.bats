#!/usr/bin/env bats

# bats test_tags=invalid, external
@test "expect error when invalid layout passed" {
    source ./clip-parse.sh

    ! parser_output_command_name_with_subcommands '# some

> Some text.

- Some text:

`some`
'
}

# bats test_tags=invalid, extra-level
@test "expect error when invalid header with second level passed" {
    source ./clip-parse.sh

    ! parser_output_command_name_with_subcommands '## some

> Some text.

- Some text:

`some`
'
}

# bats test_tags=valid, header
@test "expect no header extraction error when valid header passed" {
    source ./clip-parse.sh

    run parser_output_command_name_with_subcommands '#  some  command with  subcommand 

> Some text.

- Some text:

`some`'

    [[ "$output" == "some command with subcommand" ]]
}
