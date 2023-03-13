#!/usr/bin/env bats

@test "expect '/device' conversion when code with '/device' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/device}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file device}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/dev/sda' conversion when code with '/dev/sda' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/dev/sda}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file device}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/device<digits>' conversion when code with '/device<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/device12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file device 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/dev/sda<digits>' conversion when code with '/dev/sda<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/dev/sda12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file device 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/device1 /device2 ...' conversion when code with '/device1 /device2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/device1 /device2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* device}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/dev/sda1 /dev/sda2 ...' conversion when code with '/dev/sda1 /dev/sda2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/dev/sda1 /dev/sda2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* device}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}



@test "expect '/<adjective>_device' conversion when code with '/<adjective>_device' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/usb_device}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file usb device}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/<adjective>_device<digits>' conversion when code with '/<adjective>_device<digits>' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/usb_device12}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file usb device 12}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect '/<adjective>_device1 /<adjective>_device2 ...' conversion when code with '/<adjective>_device1 /<adjective>_device2 ...' passed" {
    declare page="# command

> Some description.
> More information: <https://example.com>.

- Some description:

\\\`some code with {{/usb_device1 /usb_device2 ...}}\\\`"

    declare expected_output="> Some description
> More information: https://example.com

- Some description:

\`some code with {/file* usb device}\`"

    run bash -c "./md-to-clip.sh -spc placeholders.yaml -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}
