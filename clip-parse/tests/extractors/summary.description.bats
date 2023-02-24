#!/usr/bin/env bats

# bats test_tags=invalid, external
@test "expect error when invalid layout passed" {
    source ./clip-parse.sh

    ! parser_output_command_description '# some

> Some text.
> See also: other.
> More information: https://example.com.

- Some text:

`some`
'
}

# bats test_tags=invalid, external
@test "expect error when summary layout passed" {
    source ./clip-parse.sh

    ! parser_output_command_description '# some

> Some text.

- Some text:

`some`'
}

# bats test_tags=valid, summary, description
@test "expect no command description extraction error when valid summary passed" {
    source ./clip-parse.sh

    run parser_output_command_description '# some

> Some text.
> See also: other.
> More information: https://example.com.

- Some text:

`some`'

    [[ "$output" == "Some text." ]]
}
