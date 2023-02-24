#!/usr/bin/env bats

# bats test_tags=invalid, header
@test "expect layout check error when invalid page passed" {
    source ./clip-parse.sh

    ! parser_output_command_name_with_subcommands '# some

> Some text.

- Some text:

`some`
'
}

# bats test_tags=valid, header
@test "expect no command extraction error when valid page passed" {
    source ./clip-parse.sh

    run parser_output_command_name_with_subcommands '#  some 

> Some text.

- Some text:

`some`'

    [[ "$output" == "some" ]]
}
