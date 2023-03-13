#!/usr/bin/env bats

@test "expect 'boolean' conversion when code with 'boolean' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{boolean}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool boolean}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'boolean<digits>' conversion when code with 'boolean<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{boolean12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool boolean 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'boolean1 boolean2 ...' conversion when code with 'boolean1 boolean2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{boolean1 boolean2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool* boolean}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<boolean-value>' conversion when code with '<boolean-value>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{True}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool boolean: True}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<boolean-value1>|<boolean-value2>' conversion when code with '<boolean-value1>|<boolean-value2>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{True|False}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool boolean: True, False}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '<adjective>_boolean' conversion when code with '<adjective>_boolean' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_boolean}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool default boolean}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_boolean<digits>' conversion when code with '<adjective>_boolean<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_boolean12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool default boolean 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_boolean1 <adjective>_boolean2 ...' conversion when code with '<adjective>_boolean1 <adjective>_boolean2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_boolean1 default_boolean2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {bool* default boolean}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
