#!/usr/bin/env bats

# bats test_tags=invalid, external
@test "expect error when invalid layout passed" {
    source ./clip-parse.sh

    ! parser_output_command_description '# some

> Some text.
> More information: https://example.com.

- Some text:

`some`
'
}

# bats test_tags=invalid, external
@test "expect error when invalid summary passed" {
    source ./clip-parse.sh

    ! parser_output_command_description '# some

> Some text.

- Some text:

`some`'
}

# bats test_tags=valid, summary, extra-spaces
@test "expect no error when valid description with trailing space passed" {
    source ./clip-parse.sh

    run parser_output_command_description '# some

> Some text. 
> More information: https://example.com.

- Some text:

`some`'

    [[ "$output" == "Some text." ]]
}

# bats test_tags=valid, summary, extra-spaces
@test "expect no error when valid description with leading space passed" {
    source ./clip-parse.sh

    run parser_output_command_description '# some

>  Some text.
> More information: https://example.com.

- Some text:

`some`'

    [[ "$output" == "Some text." ]]
}

# bats test_tags=valid, summary, extra-spaces
@test "expect no error when valid description with several spaces passed" {
    source ./clip-parse.sh

    run parser_output_command_description '# some

> Some  text.
> More information: https://example.com.

- Some text:

`some`'

    [[ "$output" == "Some text." ]]
}

# bats test_tags=valid, summary, extra-description-lines
@test "expect no error when valid header with several extra description lines passed" {
    source ./clip-parse.sh

    run parser_output_command_description '# some

> Some text.
> Some text.
> More information: https://example.com.

- Some text:

`some`'

    [[ "$output" == $'Some text.\nSome text.' ]]
}

# bats test_tags=valid, summary, description
@test "expect no error when valid description passed" {
    source ./clip-parse.sh

    run parser_output_command_description '# some

> Some text.
> More information: https://example.com.

- Some text:

`some`'

    [[ "$output" == "Some text." ]]
}
