#!/usr/bin/env bats

@test "expect contracted extension conversion when code with contracted extension passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{ext}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string extension}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect extension conversion when code with extension passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{extension}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string extension}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
