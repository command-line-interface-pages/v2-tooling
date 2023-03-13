#!/usr/bin/env bats

@test "expect 'float' conversion when code with 'float' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{float}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float float}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'float<digits>' conversion when code with 'float<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{float12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float float 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'float1 float2 ...' conversion when code with 'float1 float2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{float1 float2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float* float}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<float-value>' conversion when code with '<float-value>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{12.1}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float float: 12.1}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '<adjective>_float' conversion when code with '<adjective>_float' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positive_float}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float positive float}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_float<digits>' conversion when code with '<adjective>_float<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positive_float12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float positive float 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_float1 <adjective>_float2 ...' conversion when code with '<adjective>_float1 <adjective>_float2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{positive_float1 positive_float2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {float* positive float}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
