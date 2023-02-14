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


# bats test_tags=example, code, placeholder, plural, relative, device
@test "expect no plural device keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{devices}} {{device_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file* device} {file* device}`' ]]
}

# bats test_tags=example, code, placeholder, plural, absolute, device
@test "expect no plural device keyword placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/devices}} {{/device_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/file* device} {/file* device}`' ]]
}

# bats test_tags=example, code, placeholder, singular, relative, device
@test "expect no singular device placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{device}} {{device_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file device} {file device}`' ]]
}

# bats test_tags=example, code, placeholder, plural, relative, device
@test "expect no plural device placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{device1 device2 ...}} {{device_name1 device_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {file* device} {file* device}`' ]]
}

# bats test_tags=example, code, placeholder, singular, absolute, device
@test "expect no singular device placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/device}} {{/device_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/file device} {/file device}`' ]]
}

# bats test_tags=example, code, placeholder, plural, absolute, device
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


# bats test_tags=example, code, placeholder, plural, user
@test "expect no plural user keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{users}} {{user_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* user} {string* user}`' ]]
}

# bats test_tags=example, code, placeholder, singular, user
@test "expect no singular user placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{user}} {{user_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string user} {string user}`' ]]
}

# bats test_tags=example, code, placeholder, plural, user
@test "expect no plural user placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{user1 user2 ...}} {{user_name1 user_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* user} {string* user}`' ]]
}


# bats test_tags=example, code, placeholder, plural, group
@test "expect no plural group keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{groups}} {{group_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* group} {string* group}`' ]]
}

# bats test_tags=example, code, placeholder, singular, group
@test "expect no singular group placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{group}} {{group_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string group} {string group}`' ]]
}

# bats test_tags=example, code, placeholder, plural, group
@test "expect no plural group placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{group1 group2 ...}} {{group_name1 group_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* group} {string* group}`' ]]
}


# bats test_tags=example, code, placeholder, plural, ip
@test "expect no plural ip keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{ips}} {{ip_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* ip} {string* ip}`' ]]
}

# bats test_tags=example, code, placeholder, singular, ip
@test "expect no singular ip placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{ip}} {{ip_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string ip} {string ip}`' ]]
}

# bats test_tags=example, code, placeholder, plural, ip
@test "expect no plural ip placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{ip1 ip2 ...}} {{ip_name1 ip_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* ip} {string* ip}`' ]]
}


# bats test_tags=example, code, placeholder, plural, database
@test "expect no plural database keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{databases}} {{database_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* database} {string* database}`' ]]
}

# bats test_tags=example, code, placeholder, singular, database
@test "expect no singular database placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{database}} {{database_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string database} {string database}`' ]]
}

# bats test_tags=example, code, placeholder, plural, database
@test "expect no plural database placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{database1 database2 ...}} {{database_name1 database_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* database} {string* database}`' ]]
}


# bats test_tags=example, code, placeholder, plural, argument
@test "expect no plural argument keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{arguments}} {{argument_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {any* argument} {any* argument}`' ]]
}

# bats test_tags=example, code, placeholder, singular, argument
@test "expect no singular argument placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{argument}} {{argument_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {any argument} {any argument}`' ]]
}

# bats test_tags=example, code, placeholder, plural, argument
@test "expect no plural argument placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{argument1 argument2 ...}} {{argument_name1 argument_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {any* argument} {any* argument}`' ]]
}


# bats test_tags=example, code, placeholder, plural, option
@test "expect no plural option keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{options}} {{option_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* option} {string* option}`' ]]
}

# bats test_tags=example, code, placeholder, singular, option
@test "expect no singular option placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{option}} {{option_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string option} {string option}`' ]]
}

# bats test_tags=example, code, placeholder, plural, option
@test "expect no plural option placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{option1 option2 ...}} {{option_name1 option_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* option} {string* option}`' ]]
}

# bats test_tags=example, code, placeholder, singular, option
@test "expect no singular example option placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{--version}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {option some description: --version}`' ]]
}

# bats test_tags=example, code, placeholder, singular, option
@test "expect no singular example option placeholder conversion error when valid page && value is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{--type jpeg}} {{--type=jpeg}} {{--type:jpeg}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {option some description: --type} {option some description: --type} {option some description: --type}`' ]]
}

# bats test_tags=example, code, placeholder, plural, option
@test "expect no plural example option placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{--type jpeg --resize=true --transparent}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {option* some description: --type jpeg --resize=true --transparent}`' ]]
}


# bats test_tags=example, code, placeholder, plural, setting
@test "expect no plural setting keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{settings}} {{setting_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* setting} {string* setting}`' ]]
}

# bats test_tags=example, code, placeholder, singular, setting
@test "expect no singular setting placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{setting}} {{setting_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string setting} {string setting}`' ]]
}

# bats test_tags=example, code, placeholder, plural, setting
@test "expect no plural setting placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{setting1 setting2 ...}} {{setting_name1 setting_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* setting} {string* setting}`' ]]
}


# bats test_tags=example, code, placeholder, plural, subcommand
@test "expect no plural subcommand keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{subcommands}} {{subcommand_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {command* subcommand} {command* subcommand}`' ]]
}

# bats test_tags=example, code, placeholder, singular, subcommand
@test "expect no singular subcommand placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{subcommand}} {{subcommand_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {command subcommand} {command subcommand}`' ]]
}

# bats test_tags=example, code, placeholder, plural, subcommand
@test "expect no plural subcommand placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{subcommand1 subcommand2 ...}} {{subcommand_name1 subcommand_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {command* subcommand} {command* subcommand}`' ]]
}


# bats test_tags=example, code, placeholder, plural, extension
@test "expect no plural extension keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{extensions}} {{extension_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* extension} {string* extension}`' ]]
}

# bats test_tags=example, code, placeholder, singular, extension
@test "expect no singular extension placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{extension}} {{extension_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string extension} {string extension}`' ]]
}

# bats test_tags=example, code, placeholder, plural, extension
@test "expect no plural extension placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{extension1 extension2 ...}} {{extension_name1 extension_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {string* extension} {string* extension}`' ]]
}


# bats test_tags=example, code, placeholder, plural, relative, file_or_directory
@test "expect no plural file_or_directory keyword placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{files_or_directories}} {{file_names_or_directories}} {{files_or_directory_names}} {{file_names_or_directory_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {path* some description} {path* some description} {path* some description} {path* some description}`' ]]
}

# bats test_tags=example, code, placeholder, plural, absolute, file_or_directory
@test "expect no plural file_or_directory keyword placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/files_or_directories}} {{/file_names_or_directories}} {{/files_or_directory_names}} {{/file_names_or_directory_names}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/path* some description} {/path* some description} {/path* some description} {/path* some description}`' ]]
}

# bats test_tags=example, code, placeholder, singular, relative, file_or_directory
@test "expect no singular file_or_directory placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{file_or_directory}} {{file_name_or_directory}} {{file_or_directory_name}} {{file_name_or_directory_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {path some description} {path some description} {path some description} {path some description}`' ]]
}

# bats test_tags=example, code, placeholder, plural, relative, file_or_directory
@test "expect no plural file_or_directory placeholder conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{file_or_directory1 file_or_directory2 ...}} {{file_name_or_directory1 file_name_or_directory2 ...}} {{file_or_directory_name1 file_or_directory_name2 ...}} {{file_name_or_directory_name1 file_name_or_directory_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {path* some description} {path* some description} {path* some description} {path* some description}`' ]]
}

# bats test_tags=example, code, placeholder, singular, absolute, file_or_directory
@test "expect no singular file_or_directory placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/file_or_directory}} {{/file_name_or_directory}} {{/file_or_directory_name}} {{/file_name_or_directory_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/path some description} {/path some description} {/path some description} {/path some description}`' ]]
}

# bats test_tags=example, code, placeholder, plural, absolute, file_or_directory
@test "expect no plural file_or_directory placeholder conversion error when valid page && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/file_or_directory1 /file_or_directory2 ...}} {{/file_name_or_directory1 /file_name_or_directory2 ...}} {{/file_or_directory_name1 /file_or_directory_name2 ...}} {{/file_name_or_directory_name1 /file_name_or_directory_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/path* some description} {/path* some description} {/path* some description} {/path* some description}`' ]]
}

# bats test_tags=example, code, placeholder, singular, relative, file_or_directory
@test "expect no singular file_or_directory placeholder conversion error when valid page && path/to prefix is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{path/to/file_or_directory}} {{path/to/file_name_or_directory}} {{path/to/file_or_directory_name}} {{path/to/file_name_or_directory_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {path some description} {path some description} {path some description} {path some description}`' ]]
}

# bats test_tags=example, code, placeholder, plural, relative, file_or_directory
@test "expect no plural file_or_directory placeholder conversion error when valid page && path/to prefix is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{path/to/file_or_directory1 path/to/file_or_directory2 ...}} {{path/to/file_name_or_directory1 path/to/file_name_or_directory2 ...}} {{path/to/file_or_directory_name1 path/to/file_or_directory_name2 ...}} {{path/to/file_name_or_directory_name1 path/to/file_name_or_directory_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {path* some description} {path* some description} {path* some description} {path* some description}`' ]]
}

# bats test_tags=example, code, placeholder, singular, absolute, file_or_directory
@test "expect no singular file_or_directory placeholder conversion error when valid page && path/to prefix && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/path/to/file_or_directory}} {{/path/to/file_name_or_directory}} {{/path/to/file_or_directory_name}} {{/path/to/file_name_or_directory_name}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/path some description} {/path some description} {/path some description} {/path some description}`' ]]
}

# bats test_tags=example, code, placeholder, plural, absolute, file_or_directory
@test "expect no plural file_or_directory placeholder conversion error when valid page && path/to prefix && forward slash is passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- Some text:

\`some {{/path/to/file_or_directory1 /path/to/file_or_directory2 ...}} {{/path/to/file_name_or_directory1 /path/to/file_name_or_directory2 ...}} {{/path/to/file_or_directory_name1 /path/to/file_or_directory_name2 ...}} {{/path/to/file_name_or_directory_name1 /path/to/file_name_or_directory_name2 ...}}\`') | sed -nE '/^\`/p'"
  [[ "$output" == '`some {/path* some description} {/path* some description} {/path* some description} {/path* some description}`' ]]
}