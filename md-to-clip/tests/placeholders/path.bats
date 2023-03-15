#!/usr/bin/env bats

@test "expect '/path/to/file_or_directory' conversion when code with '/path/to/file_or_directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file_or_directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file_or_directory<digits>' conversion when code with '/path/to/file_or_directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file_or_directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path file or directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file_or_directory1 /path/to/file_or_directory2 ...' conversion when code with '/path/to/file_or_directory1 /path/to/file_or_directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file_or_directory1 /path/to/file_or_directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path* file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/path/to/<adjective>_file_or_directory' conversion when code with '/path/to/<adjective>_file_or_directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file_or_directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path image file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file_or_directory<digits>' conversion when code with '/path/to/<adjective>_file_or_directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file_or_directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path image file or directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file_or_directory1 /path/to/<adjective>_file_or_directory2 ...' conversion when code with '/path/to/<adjective>_file_or_directory1 /path/to/<adjective>_file_or_directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file_or_directory1 /path/to/image_file_or_directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path* image file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '\path\to\file_or_directory' conversion when code with '\path\to\file_or_directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\file_or_directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\file_or_directory<digits>' conversion when code with '\path\to\file_or_directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\file_or_directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path file or directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\file_or_directory1 \path\to\file_or_directory2 ...' conversion when code with '\path\to\file_or_directory1 \path\to\file_or_directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\file_or_directory1 \path\to\file_or_directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path* file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '\path\to\<adjective>_file_or_directory' conversion when code with '\path\to\<adjective>_file_or_directory' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\image_file_or_directory}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path image file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\<adjective>_file_or_directory<digits>' conversion when code with '\path\to\<adjective>_file_or_directory<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\image_file_or_directory12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path image file or directory 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '\path\to\<adjective>_file_or_directory1 \path\to\<adjective>_file_or_directory2 ...' conversion when code with '\path\to\<adjective>_file_or_directory1 \path\to\<adjective>_file_or_directory2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{\path\to\image_file_or_directory1 \path\to\image_file_or_directory2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/path* image file or directory}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
