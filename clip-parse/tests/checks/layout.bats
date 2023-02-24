#!/usr/bin/env bats

# bats test_tags=invalid, extra-newlines
@test "expect error when invalid layout with trailing new line passed" {
    source ./clip-parse.sh

    ! parser_check_layout_correctness '# some

> Some text.
> More information https://example.com.

- Some text:

`some`
'
}

# bats test_tags=invalid, extra-newlines
@test "expect error when invalid layout with leading new line passed" {
    source ./clip-parse.sh

    ! parser_check_layout_correctness '
# some

> Some text.
> More information https://example.com.

- Some text:

`some`'
}

# bats test_tags=invalid, extra-newlines
@test "expect error when invalid layout with several empty lines passed" {
    source ./clip-parse.sh

    ! parser_check_layout_correctness '# some


> Some text.
> More information https://example.com.

- Some text:

`some`'
}

# bats test_tags=invalid, no-header
@test "expect error when invalid layout with missing header passed" {
    source ./clip-parse.sh

    ! parser_check_layout_correctness '> Some text.
> More information https://example.com.

- Some text:

`some`'
}

# bats test_tags=invalid, no-summary
@test "expect error when invalid layout with missing summary passed" {
    source ./clip-parse.sh

    ! parser_check_layout_correctness '# some

- Some text:

`some`'
}

# bats test_tags=invalid, no-examples
@test "expect error when invalid layout with missing examples passed" {
    source ./clip-parse.sh

    ! parser_check_layout_correctness '# some

> Some text.
> More information https://example.com.'
}

# bats test_tags=valid, layout
@test "expect no error when valid page passed" {
    source ./clip-parse.sh

    parser_check_layout_correctness '# some

> Some text.
> More information https://example.com.

- Some text:

`some`'
}
