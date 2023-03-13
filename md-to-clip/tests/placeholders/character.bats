#!/usr/bin/env bats

@test "expect 'character' conversion when code with 'character' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{character}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {char character}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'character<digits>' conversion when code with 'character<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{character12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {char character 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'character1 character2 ...' conversion when code with 'character1 character2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{character1 character2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {char* character}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<character-value>' conversion when code with '<character-value>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{a}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {char character: a}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '<adjective>_character' conversion when code with '<adjective>_character' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_character}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {char default character}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_character<digits>' conversion when code with '<adjective>_character<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_character12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {char default character 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<adjective>_character1 <adjective>_character2 ...' conversion when code with '<adjective>_character1 <adjective>_character2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{default_character1 default_character2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {char* default character}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
