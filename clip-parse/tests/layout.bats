#!/usr/bin/env bats

# bats test_tags=invalid, layout
@test "expect layout check error when invalid page passed" {
    source ./clip-parse.sh

    ! parser_check_layout_correctness '# some

> Some text.

- Some text:

`some`
'
}

# bats test_tags=valid, layout
@test "expect no layout check error when valid page passed" {
    source ./clip-parse.sh

    parser_check_layout_correctness '# some

> Some text.

- Some text:

`some`'
}
