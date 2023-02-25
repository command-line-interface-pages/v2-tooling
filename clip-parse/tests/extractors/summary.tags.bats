#!/usr/bin/env bats

# bats test_tags=invalid, external
@test "expect error when invalid layout passed" {
    source ./clip-parse.sh

    declare page_content='# some

> Some text.
> See also: other.
> More information: https://example.com.

- Some text:

`some`
'

    ! parser_output_command_aliases_tag_value "$page_content"
    ! parser_output_command_deprecated_tag_value "$page_content"
    ! parser_output_command_deprecated_tag_value_or_default "$page_content"
    ! parser_output_command_help_tag_value "$page_content"
    ! parser_output_command_internal_tag_value "$page_content"
    ! parser_output_command_internal_tag_value_or_default "$page_content"
    ! parser_output_command_more_information_tag_value "$page_content"
    ! parser_output_command_see_also_tag_value "$page_content"
    ! parser_output_command_structure_compatible_tag_value "$page_content"
    ! parser_output_command_syntax_compatible_tag_value "$page_content"
    ! parser_output_command_version_tag_value "$page_content"
}

# bats test_tags=invalid, external
@test "expect error when invalid summary passed" {
    source ./clip-parse.sh

    declare page_content='# some

> Some text.

- Some text:

`some`'

    ! parser_output_command_aliases_tag_value "$page_content"
    ! parser_output_command_deprecated_tag_value "$page_content"
    ! parser_output_command_deprecated_tag_value_or_default "$page_content"
    ! parser_output_command_help_tag_value "$page_content"
    ! parser_output_command_internal_tag_value "$page_content"
    ! parser_output_command_internal_tag_value_or_default "$page_content"
    ! parser_output_command_more_information_tag_value "$page_content"
    ! parser_output_command_see_also_tag_value "$page_content"
    ! parser_output_command_structure_compatible_tag_value "$page_content"
    ! parser_output_command_syntax_compatible_tag_value "$page_content"
    ! parser_output_command_version_tag_value "$page_content"
}

# bats test_tags=valid, summary, description
@test "expect no error when valid summary passed" {
    source ./clip-parse.sh

declare page_content='# some

> Some text.
> Aliases: egrep
> Deprecated: true
> Help: --help
> Internal: true
> More information: https://example.com
> See also: awk
> Structure compatible: /bin
> Syntax compatible: sh
> Version: --version

- Some text:

`some`'

    run parser_output_command_aliases_tag_value "$page_content"
    [[ "$output" == egrep ]]

    run parser_output_command_deprecated_tag_value "$page_content"
    [[ "$output" == true ]]

    run parser_output_command_deprecated_tag_value_or_default "$page_content"
    [[ "$output" == true ]]

    run parser_output_command_help_tag_value "$page_content"
    [[ "$output" == --help ]]

    run parser_output_command_internal_tag_value "$page_content"
    [[ "$output" == true ]]

    run parser_output_command_internal_tag_value_or_default "$page_content"
    [[ "$output" == true ]]

    run parser_output_command_more_information_tag_value "$page_content"
    [[ "$output" == "https://example.com" ]]

    run parser_output_command_see_also_tag_value "$page_content"
    [[ "$output" == awk ]]

    run parser_output_command_structure_compatible_tag_value "$page_content"
    [[ "$output" == "/bin" ]]

    run parser_output_command_syntax_compatible_tag_value "$page_content"
    [[ "$output" == sh ]]

    run parser_output_command_version_tag_value "$page_content"
    [[ "$output" == --version ]]
}
