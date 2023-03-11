#!/usr/bin/env bats

@test "expect 'int' conversion when code with 'int' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{int}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int some description}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'integer' conversion when code with 'integer' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{integer}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int some description}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'int<digits>' conversion when code with 'int<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{int12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int some description 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'integer<digits>' conversion when code with 'integer<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{integer12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int some description 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'ints' conversion when code with 'ints' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{ints}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int* some description}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'integers' conversion when code with 'integers' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{integers}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int* some description}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '<adjective>_int' conversion when code with '<adjective>_int' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positive_int}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int positive integer}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_integer' conversion when code with '<adjective>_integer' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positive_integer}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int positive integer}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_int<digits>' conversion when code with '<adjective>_int<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positive_int12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int positive integer 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_integer<digits>' conversion when code with '<adjective>_integer<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positive_integer12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int positive integer 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '<integer-value>' conversion when code with '<integer-value>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {int some description: 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
