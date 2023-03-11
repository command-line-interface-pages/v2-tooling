#!/usr/bin/env bats

@test "expect trailing dot and backtick removal when correct summary passed" {
    declare page="# sed

> Edit text in a scriptable manner.
> See also: \\\`awk\\\`, \\\`ed\\\`.
> More information: <https://keith.github.io/xcode-man-pages/sed.1.html>.

- Replace all \\\`apple\\\` (basic regex) occurrences with \\\`mango\\\` (basic regex) in all input lines and print the result to \\\`stdout\\\`:

\\\`{{command}} | sed 's/apple/mango/g'\\\`"

    declare expected_output="> Edit text in a scriptable manner
> See also: awk, ed
> More information: https://keith.github.io/xcode-man-pages/sed.1.html"

    run bash -c "./md-to-clip.sh -nfs <(echo \"$page\") | sed -nE '/^>/ p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect multiple consecutive comma replacement when 'See also' tag value with multiple consecutive commas passed" {
    declare page="# sed

> Edit text in a scriptable manner.
> See also: \\\`awk\\\`,, \\\`ed\\\`.
> More information: <https://keith.github.io/xcode-man-pages/sed.1.html>.

- Replace all \\\`apple\\\` (basic regex) occurrences with \\\`mango\\\` (basic regex) in all input lines and print the result to \\\`stdout\\\`:

\\\`{{command}} | sed 's/apple/mango/g'\\\`"

    declare expected_output="> Edit text in a scriptable manner
> See also: awk, ed
> More information: https://keith.github.io/xcode-man-pages/sed.1.html"

    run bash -c "./md-to-clip.sh -nfs <(echo \"$page\") | sed -nE '/^>/ p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'or' keyword removal when 'See also' tag value with 'or' keyword passed" {
    declare page="# sed

> Edit text in a scriptable manner.
> See also: \\\`awk\\\`, or \\\`ed\\\`.
> More information: <https://keith.github.io/xcode-man-pages/sed.1.html>.

- Replace all \\\`apple\\\` (basic regex) occurrences with \\\`mango\\\` (basic regex) in all input lines and print the result to \\\`stdout\\\`:

\\\`{{command}} | sed 's/apple/mango/g'\\\`"

    declare expected_output="> Edit text in a scriptable manner
> See also: awk, ed
> More information: https://keith.github.io/xcode-man-pages/sed.1.html"

    run bash -c "./md-to-clip.sh -nfs <(echo \"$page\") | sed -nE '/^>/ p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect --help example removal when --help example passed" {
    declare page="# sed

> Edit text in a scriptable manner.
> See also: \\\`awk\\\`, \\\`ed\\\`.
> More information: <https://keith.github.io/xcode-man-pages/sed.1.html>.

- Replace all \\\`apple\\\` (basic regex) occurrences with \\\`mango\\\` (basic regex) in all input lines and print the result to \\\`stdout\\\`:

\\\`{{command}} | sed 's/apple/mango/g'\\\`

- Display a help:

\\\`sed --help\\\`"

    declare expected_output="> Edit text in a scriptable manner
> See also: awk, ed
> Help: --help
> More information: https://keith.github.io/xcode-man-pages/sed.1.html

- Replace all \`apple\` (basic regex) occurrences with \`mango\` (basic regex) in all input lines and print the result to stdout:

\`{string some description: command} | sed 's/apple/mango/g'\`"

    run bash -c "./md-to-clip.sh -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect --version example removal when --version example passed" {
    declare page="# sed

> Edit text in a scriptable manner.
> See also: \\\`awk\\\`, \\\`ed\\\`.
> More information: <https://keith.github.io/xcode-man-pages/sed.1.html>.

- Replace all \\\`apple\\\` (basic regex) occurrences with \\\`mango\\\` (basic regex) in all input lines and print the result to \\\`stdout\\\`:

\\\`{{command}} | sed 's/apple/mango/g'\\\`

- Display a version:

\\\`sed --version\\\`"

    declare expected_output="> Edit text in a scriptable manner
> See also: awk, ed
> Version: --version
> More information: https://keith.github.io/xcode-man-pages/sed.1.html

- Replace all \`apple\` (basic regex) occurrences with \`mango\` (basic regex) in all input lines and print the result to stdout:

\`{string some description: command} | sed 's/apple/mango/g'\`"

    run bash -c "./md-to-clip.sh -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}

@test "expect 'Help' tag to be before 'Version' tag when both --help and --version examples passed" {
    declare page="# sed

> Edit text in a scriptable manner.
> See also: \\\`awk\\\`, \\\`ed\\\`.
> More information: <https://keith.github.io/xcode-man-pages/sed.1.html>.

- Replace all \\\`apple\\\` (basic regex) occurrences with \\\`mango\\\` (basic regex) in all input lines and print the result to \\\`stdout\\\`:

\\\`{{command}} | sed 's/apple/mango/g'\\\`

- Display a help:

\\\`sed --help\\\`

- Display a version:

\\\`sed --version\\\`"

    declare expected_output="> Edit text in a scriptable manner
> See also: awk, ed
> Help: --help
> Version: --version
> More information: https://keith.github.io/xcode-man-pages/sed.1.html

- Replace all \`apple\` (basic regex) occurrences with \`mango\` (basic regex) in all input lines and print the result to stdout:

\`{string some description: command} | sed 's/apple/mango/g'\`"

    run bash -c "./md-to-clip.sh -nfs <(echo \"$page\") | sed -nE '1,2! p'"
    [[ "$output" == "$expected_output" ]]
}