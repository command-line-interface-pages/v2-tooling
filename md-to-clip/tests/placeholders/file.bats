#!/usr/bin/env bats

@test "expect '/path/to/file' conversion when code with '/path/to/file' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file file}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file<digits>' conversion when code with '/path/to/file<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file file 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file1 /path/to/file2 ...' conversion when code with '/path/to/file1 /path/to/file2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file1 /path/to/file2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* file}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/path/to/<adjective>_file' conversion when code with '/path/to/<adjective>_file' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file image file}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file<digits>' conversion when code with '/path/to/<adjective>_file<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file image file 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file1 /path/to/<adjective>_file2 ...' conversion when code with '/path/to/<adjective>_file1 /path/to/<adjective>_file2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file1 /path/to/image_file2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* image file}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/path/to/file[.jpg, .jpeg]' conversion when code with '/path/to/file[.jpg, .jpeg]' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file[.jpg, .jpeg]}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file file with optional .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file<digits>[.jpg, .jpeg]' conversion when code with '/path/to/file<digits>[.jpg, .jpeg]' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file12[.jpg, .jpeg]}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file file 12 with optional .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file1[.jpg, .jpeg] /path/to/file2[.jpg, .jpeg] ...' conversion when code with '/path/to/file1[.jpg, .jpeg] /path/to/file2[.jpg, .jpeg] ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file1[.jpg, .jpeg] /path/to/file2[.jpg, .jpeg] ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* file with optional .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/path/to/file(.jpg, .jpeg)' conversion when code with '/path/to/file(.jpg, .jpeg)' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file(.jpg, .jpeg)}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file file with mandatory .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file<digits>(.jpg, .jpeg)' conversion when code with '/path/to/file<digits>(.jpg, .jpeg)' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file12(.jpg, .jpeg)}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file file 12 with mandatory .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/file1(.jpg, .jpeg) /path/to/file2(.jpg, .jpeg) ...' conversion when code with '/path/to/file1(.jpg, .jpeg) /path/to/file2(.jpg, .jpeg) ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/file1(.jpg, .jpeg) /path/to/file2(.jpg, .jpeg) ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* file with mandatory .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/path/to/<adjective>_file[.jpg, .jpeg]' conversion when code with '/path/to/<adjective>_file[.jpg, .jpeg]' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file[.jpg, .jpeg]}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file image file with optional .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file<digits>[.jpg, .jpeg]' conversion when code with '/path/to/<adjective>_file<digits>[.jpg, .jpeg]' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file12[.jpg, .jpeg]}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file image file 12 with optional .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file1[.jpg, .jpeg] /path/to/<adjective>_file2[.jpg, .jpeg] ...' conversion when code with '/path/to/<adjective>_file1[.jpg, .jpeg] /path/to/<adjective>_file2[.jpg, .jpeg] ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file1[.jpg, .jpeg] /path/to/image_file2[.jpg, .jpeg] ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* image file with optional .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/path/to/<adjective>_file(.jpg, .jpeg)' conversion when code with '/path/to/<adjective>_file(.jpg, .jpeg)' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file(.jpg, .jpeg)}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file image file with mandatory .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file<digits>(.jpg, .jpeg)' conversion when code with '/path/to/<adjective>_file<digits>(.jpg, .jpeg)' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file12(.jpg, .jpeg)}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file image file 12 with mandatory .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/path/to/<adjective>_file1(.jpg, .jpeg) /path/to/<adjective>_file2(.jpg, .jpeg) ...' conversion when code with '/path/to/<adjective>_file1(.jpg, .jpeg) /path/to/<adjective>_file2(.jpg, .jpeg) ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/path/to/image_file1(.jpg, .jpeg) /path/to/image_file2(.jpg, .jpeg) ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* image file with mandatory .jpg, .jpeg extensions}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
