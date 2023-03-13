#!/usr/bin/env bats

@test "expect '<file-value>' conversion when code with '<file-value>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{~/.bashrc}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {file file: ~/.bashrc}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
