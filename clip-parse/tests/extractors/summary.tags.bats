#!/usr/bin/env bats

# bats test_tags=invalid, external
@test "expect error when invalid layout passed" {
    source ./clip-parse.sh

    ! parser_output_command_tags '# some

> Some text.
> See also: other.
> More information: https://example.com.

- Some text:

`some`
'
}

# bats test_tags=invalid, external
@test "expect error when invalid summary passed" {
    source ./clip-parse.sh

    ! parser_output_command_tags '# some

> Some text.

- Some text:

`some`'
}

# bats test_tags=valid, summary, description
@test "expect no error when valid summary passed" {
    source ./clip-parse.sh

    run parser_output_command_tags '# some

> Some text.
> See also: other.
> More information: https://example.com.

- Some text:

`some`'

    [[ "$output" == $'See also\nother.\nMore information\nhttps://example.com.' ]]
}
