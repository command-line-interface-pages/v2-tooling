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

@test "expect 'option1 option2 ...' conversion when code with 'option1 option2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{option1 option2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* option}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<option-value>' conversion when code with '<option-value>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{--file}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string option: --file}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<option-values>' conversion when code with '<option-values>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{--file source.tar --output /home/emilyseville7cfg/}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string* option: --file source.tar --output /home/emilyseville7cfg/}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '<option-value><operator><value>' conversion when code with '<option-value><operator><value>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{--file source.tar}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {string option: --file}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
