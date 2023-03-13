#!/usr/bin/env bats

@test "expect trailing dot and backtick removal when correct summary passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description:

\\\`some code\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> More information: https://example.com"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '/^>/ p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect multiple consecutive comma replacement when 'See also' tag value with multiple consecutive commas passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`,, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description:

\\\`some code\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> More information: https://example.com"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '/^>/ p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'or' keyword removal when 'See also' tag value with 'or' keyword passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, or \\\`command2\\\`.
> More information: <https://example.com>.

- Some description:

\\\`some code\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> More information: https://example.com"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '/^>/ p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect --help example removal when --help example passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description:

\\\`some code\\\`

- Display a help:

\\\`sed --help\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> Help: --help
> More information: https://example.com

- Some description:

\`some code\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect --version example removal when --version example passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description:

\\\`some code\\\`

- Display a version:

\\\`sed --version\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> Version: --version
> More information: https://example.com

- Some description:

\`some code\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'Help' tag to be before 'Version' tag when both --help and --version examples passed" {
    declare page="# command

> Some description.
> See also: \\\`command1\\\`, \\\`command2\\\`.
> More information: <https://example.com>.

- Some description:

\\\`some code\\\`

- Display a help:

\\\`sed --help\\\`

- Display a version:

\\\`sed --version\\\`"

    declare expected_output="> Some description
> See also: command1, command2
> Help: --help
> Version: --version
> More information: https://example.com

- Some description:

\`some code\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
