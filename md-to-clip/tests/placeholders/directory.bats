#!/usr/bin/env bats

@test "expect '/path/to/directory' conversion when code with '/path/to/directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/directory<digits>' conversion when code with '/path/to/directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/directory1 /path/to/directory2 ...' conversion when code with '/path/to/directory1 /path/to/directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/directory1 /path/to/directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory* directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/path/to/<adjective>_directory' conversion when code with '/path/to/<adjective>_directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory image directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_directory<digits>' conversion when code with '/path/to/<adjective>_directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory image directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_directory1 /path/to/<adjective>_directory2 ...' conversion when code with '/path/to/<adjective>_directory1 /path/to/<adjective>_directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_directory1 /path/to/image_directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory* image directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '\path\to\directory' conversion when code with '\path\to\directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\directory<digits>' conversion when code with '\path\to\directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\directory1 \path\to\directory2 ...' conversion when code with '\path\to\directory1 \path\to\directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\directory1 \path\to\directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory* directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '\path\to\<adjective>_directory' conversion when code with '\path\to\<adjective>_directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\image_directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory image directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\<adjective>_directory<digits>' conversion when code with '\path\to\<adjective>_directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\image_directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory image directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\<adjective>_directory1 \path\to\<adjective>_directory2 ...' conversion when code with '\path\to\<adjective>_directory1 \path\to\<adjective>_directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\image_directory1 \path\to\image_directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/directory* image directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
