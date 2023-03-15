#!/usr/bin/env bats

@test "expect 'width' conversion when code with 'width' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{width}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float width}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'width_value' conversion when code with 'width_value' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{width_value}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float width}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'widths' conversion when code with 'widths' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{widths}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float* width}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'width_values' conversion when code with 'width_values' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{width_values}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float* width}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect 'position' conversion when code with 'position' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{position}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'position_value' conversion when code with 'position_value' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{position_value}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'positions' conversion when code with 'positions' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positions}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int* position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'position_values' conversion when code with 'position_values' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{position_values}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int* position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'default_position' conversion when code with 'default_position' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_position}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int default position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'default_position_value' conversion when code with 'default_position_value' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_position_value}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int default position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'default_positions' conversion when code with 'default_positions' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_positions}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int* default position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'default_position_values' conversion when code with 'default_position_values' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_position_values}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int* default position}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect 'argument' conversion when code with 'argument' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{argument}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'argument_value' conversion when code with 'argument_value' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{argument_value}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'arguments' conversion when code with 'arguments' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{arguments}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'argument_values' conversion when code with 'argument_values' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{argument_values}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'arg' conversion when code with 'arg' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{arg}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'arg_value' conversion when code with 'arg_value' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{arg_value}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'args' conversion when code with 'args' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{args}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'arg_values' conversion when code with 'arg_values' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{arg_values}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* argument}\`"

    run bash -c "./md-to-clip.sh -spc placeholders-test.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
