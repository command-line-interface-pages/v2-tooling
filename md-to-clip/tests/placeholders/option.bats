#!/usr/bin/env bats

@test "expect 'option' conversion when code with 'option' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{option}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string option}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'option<digits>' conversion when code with 'option<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{option12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string option 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'options' conversion when code with 'options' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{options}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* option}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '<option>' conversion when code with '<option>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{--file}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string some description: --file}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<options>' conversion when code with '<options>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{--file source.tar --output /home/emilyseville7cfg/}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* some description: --file source.tar --output /home/emilyseville7cfg/}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
