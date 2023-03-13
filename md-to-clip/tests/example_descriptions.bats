#!/usr/bin/env bats

@test "expect contracted I/O stream replacement when example with contracted I/O streams passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description with \\\`stdin\\\`, \\\`stdout\\\`, and \\\`stderr\\\`:

\\\`some code\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> More information: https://example.com

- Some description with stdin, stdout, and stderr:

\`some code\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect I/O stream replacement when example with I/O streams passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description with standard input, standard output, and standard error:

\\\`some code\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> More information: https://example.com

- Some description with stdin, stdout, and stderr:

\`some code\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect term replacement when example with 'specified'/'given' term passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description with a specified, and a given terms:

\\\`some code\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> More information: https://example.com

- Some description with a specific, and a specific terms:

\`some code\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
