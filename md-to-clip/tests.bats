#!/usr/bin/env bats

# bats test_tags=layout
@test "expect layout error when empty page is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/empty_page.md"
}

# bats test_tags=layout
@test "expect layout error when page without header is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_header.md"
}

# bats test_tags=layout
@test "expect layout error when page without summary is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_summary.md"
}

# bats test_tags=layout
@test "expect layout error when page without examples is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_examples.md"
}

# bats test_tags=layout
@test "expect no layout error when valid page is passed" {
  ./md-to-clip.sh "./tests/inputs/valid/page.md"
}


# bats test_tags=header
@test "expect no header conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page.md' | sed -n '1p'"
  [[ "$output" == "# am" ]]
}


# bats test_tags=summary, description
@test "expect no summary description conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page.md' | sed -nE '/^> [^:]+$/p'"
  [[ "$output" == "> Android activity manager" ]]
}

# bats test_tags=summary, more-information
@test "expect no summary 'More information' conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page_with_more_information.md' | sed -nE '/^> More +information:/p'"
  [[ "$output" == "> More information: https://some/documentation/url" ]]
}

# bats test_tags=summary, see-also
@test "expect no summary 'See also' conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page_with_see_also.md' | sed -nE '/^> See also:/p'"
  [[ "$output" == "> See also: command1, command2" ]]
}

# bats test_tags=example, description, stream, stdin
@test "expect no stdin stream conversion error when valid page && stream inside backticks passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- \`stdin\`:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdin:" ]]
}

# bats test_tags=example, description, stream, stdin
@test "expect no stdin stream conversion error when valid page && full stream name passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard input:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdin:" ]]
}

# bats test_tags=example, description, stream, stdin
@test "expect no stdin stream conversion error when valid page && full stream name && stream keyword passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard input stream:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdin:" ]]
}

# bats test_tags=example, description, stream, stdout
@test "expect no stdout stream conversion error when valid page && stream inside backticks passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- \`stdout\`:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdout:" ]]
}

# bats test_tags=example, description, stream, stdout
@test "expect no stdout stream conversion error when valid page && full stream name passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard output:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdout:" ]]
}

# bats test_tags=example, description, stream, stdout
@test "expect no stdout stream conversion error when valid page && full stream name && stream keyword passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard output stream:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdout:" ]]
}

# bats test_tags=example, description, stream, stderr
@test "expect no stderr stream conversion error when valid page && stream inside backticks passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- \`stderr\`:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stderr:" ]]
}

# bats test_tags=example, description, stream, stderr
@test "expect no stderr stream conversion error when valid page && full stream name passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard error:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stderr:" ]]
}

# bats test_tags=example, description, stream, stderr
@test "expect no stderr stream conversion error when valid page && full stream name && stream keyword passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard error stream:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stderr:" ]]
}


# bats test_tags=example, code, placeholder, ellipsis
@test "expect no ellipsis removal error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some `' ]]
}

# bats test_tags=example, code, placeholder, ellipsis
@test "expect no ellipsis placeholder removal error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some `' ]]
}


# bats test_tags=example, code, placeholder, expandable, singular, relative, device
@test "expect no plural device keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{devices}} {{device_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file* device} {file* device}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, singular, relative, device
@test "expect no plural device keyword placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/devices}} {{/device_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/file* device} {/file* device}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, singular, relative, device
@test "expect no singular device placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{device}} {{device_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file device} {file device}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, plural, relative, device
@test "expect no plural device placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{device1 device2 ...}} {{device_name1 device_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file* device} {file* device}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, singular, absolute, device
@test "expect no singular device placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/device}} {{/device_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/file device} {/file device}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, plural, absolute, device
@test "expect no plural device placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/device1 /device2 ...}} {{/device_name1 /device_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/file* device} {/file* device}`' ]]
}

# bats test_tags=example, code, placeholder, singular, relative, device
@test "expect no singular device placeholder conversion error when valid page && dev prefix is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{dev/sda}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file device}`' ]]
}

# bats test_tags=example, code, placeholder, plural, relative, device
@test "expect no plural device placeholder conversion error when valid page && dev prefix is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{dev/sda1 dev/sda2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file* device}`' ]]
}

# bats test_tags=example, code, placeholder, singular, absolute, device
@test "expect no singular device placeholder conversion error when valid page && dev prefix && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/dev/sda}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/file device}`' ]]
}

# bats test_tags=example, code, placeholder, plural, absolute, device
@test "expect no plural device placeholder conversion error when valid page && dev prefix && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/dev/sda1 /dev/sda2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/file* device}`' ]]
}


@test "expect no plural user keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{users}} {{user_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* user} {string* user}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, singular, relative, user
@test "expect no singular user placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{user}} {{user_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string user} {string user}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, plural, relative, user
@test "expect no plural user placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{user1 user2 ...}} {{user_name1 user_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* user} {string* user}`' ]]
}


@test "expect no plural group keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{groups}} {{group_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* group} {string* group}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, singular, relative, group
@test "expect no singular group placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{group}} {{group_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string group} {string group}`' ]]
}

# bats test_tags=example, code, placeholder, expandable, plural, relative, group
@test "expect no plural group placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{group1 group2 ...}} {{group_name1 group_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* group} {string* group}`' ]]
}
