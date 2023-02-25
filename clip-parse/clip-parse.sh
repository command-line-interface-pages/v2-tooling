#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i FAIL=1

declare -i INVALID_LAYOUT_FAIL=1
declare -i INVALID_SUMMARY_FAIL=10
declare -i INVALID_TAG_FAIL=11
declare -i INVALID_TAG_VALUE_FAIL=12
declare -i INVALID_EXAMPLE_INDEX_FAIL=20

declare PARSER_ERROR_PREFIX="${PARSER_ERROR_PREFIX:-$(basename "$0")}"

# parser_print_message <source> <message>
# Print message.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 always
parser_print_message() {
    declare source="$1"
    declare message="$2"

    echo -e "$PARSER_ERROR_PREFIX: $source: ${SUCCESS_COLOR}$message$RESET_COLOR" >&2
}

# parser_throw_error <source> <message>
# Output error message and fail.
#
# Output:
#   <empty-string>
#
# Return:
#   - $FAIL always
parser_throw_error() {
    declare source="$1"
    declare message="$2"

    echo -e "$PARSER_ERROR_PREFIX: $source: ${ERROR_COLOR}$message$RESET_COLOR" >&2
    exit "$FAIL"
}

# __parser_check_layout_correctness <page-content>
# Check whether a page content is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if page layout is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
__parser_check_layout_correctness() {
    declare page_content="$1"

    # shellcheck disable=2016
    sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$page_content"$'\n\n'
}

# parser_output_command_name_with_subcommands <page-content>
# Output command name with subcommands from a page content.
#
# Output:
#   <command-with-subcommands>
#
# Return:
#   - 0 if page layout is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_with_subcommands() {
    declare page_content="$1"

    __parser_check_layout_correctness "$page_content" || return "$INVALID_LAYOUT_FAIL"

    sed -nE '1 { s/^# +//; s/ +$//; s/ +/ /g; p; }' <<<"$page_content"
}

# __parser_check_command_summary_correctness <page-summary>
# Check whether a command summary is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if page summary is valid
#   - 1 otherwise
#
# Notes:
#   - page summary without trailing \n
__parser_check_command_summary_correctness() {
    declare page_summary="$1"

    # shellcheck disable=2016
    sed -nE ':x; N; $! bx; /^(> [^\n:]+\n){1,2}(> [^\n:]+:[^\n]+\n)+$/! Q1' <<<"$page_summary"$'\n'
}

# parser_output_command_description <page-content>
# Output command description from a page content.
#
# Output:
#   <command-description>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_description() {
    declare page_content="$1"

    __parser_check_layout_correctness "$page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2155
    declare command_summary="$(sed -nE '/^>/ p' <<<"$page_content")"
    __parser_check_command_summary_correctness "$command_summary" || return "$INVALID_SUMMARY_FAIL"

    sed -nE '/^> [^:]+$/ { s/^> +//; s/ +$//; s/  +/ /g; p; }' <<<"$command_summary"
}

# __parser_check_command_tag_correctness <command-tag>
# Check whether a command tag is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if command tag is valid
#   - 1 otherwise
__parser_check_command_tag_correctness() {
    declare command_tag="$1"

    [[ "$command_tag" =~ ^(More information|Internal|Deprecated|See also|Aliases|Syntax compatible|Help|Version|Structure compatible)$ ]]
}

# __parser_check_command_tag_value_correctness <command-tag> <command-tag-value>
# Check whether a command tag value is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if command tag value is valid
#   - 1 otherwise
__parser_check_command_tag_value_correctness() {
    declare command_tag="$1"
    declare command_tag_value="$2"

    if [[ "$command_tag" =~ ^(Internal|Deprecated)$ ]]; then
        [[ "$command_tag_value" =~ ^(true|false)$ ]]
    elif [[ "$command_tag" =~ ^(See also|Aliases|Syntax compatible|Structure compatible)$ ]]; then
        ! [[ "$command_tag_value" =~ ,, ]]
    else
        [[ "$command_tag" =~ ^(More information|Help|Version)$ ]]
    fi
}

# __parser_output_command_tag <page-content>
# Output command tags from a page content.
#
# Output:
#   <command-tags>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
__parser_output_command_tags() {
    declare page_content="$1"

    __parser_check_layout_correctness "$page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2155
    declare command_summary="$(sed -nE '/^>/ p' <<<"$page_content")"
    __parser_check_command_summary_correctness "$command_summary" || return "$INVALID_SUMMARY_FAIL"

    # shellcheck disable=2155
    declare output="$(sed -nE '/^> [^:]+:.+$/ { s/^> //; s/: +/\n/; p; }' <<<"$command_summary")"
    mapfile -t command_tags <<<"$output"

    declare -i index=0
    while ((index < "${#command_tags[@]}")); do
        declare tag="${command_tags[index]}"
        declare value="${command_tags[index + 1]}"
        __parser_check_command_tag_correctness "$tag" || return "$INVALID_TAG_FAIL"
        __parser_check_command_tag_value_correctness "$tag" "$value" || return "$INVALID_TAG_VALUE_FAIL"
        index+=2
    done

    echo -n "$output"
}

# __parser_output_command_tag <page-content> <tag>
# Output specific tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary, tag is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
__parser_output_command_tag_value() {
    declare page_content="$1"
    declare command_tag="$2"

    __parser_check_command_tag_correctness "$command_tag" || return "$INVALID_TAG_FAIL"

    declare output=
    output="$(__parser_output_command_tags "$page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"
    mapfile -t command_tags <<< "$output"

    declare -i index=0
    while ((index < "${#command_tags[@]}")); do
        declare tag="${command_tags[index]}"
        declare value="${command_tags[index + 1]}"
        
        [[ "$tag" == "$command_tag" ]] && {
            echo -n "$value"
            return "$SUCCESS"
        }

        index+=2
    done
}

# parser_output_command_more_information_tag <page-content>
# Output "More information" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_more_information_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "More information"
}

# parser_output_command_internal_tag <page-content>
# Output "Internal" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_internal_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "Internal"
}

# parser_output_command_internal_tag_or_default <page-content>
# Output "Internal" tag from a page content or it's default when it's missing.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_internal_tag_value_or_default() {
    declare page_content="$1"

    declare output=
    output="$(parser_output_command_internal_tag_value "$page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    [[ -z "$output" ]] && output=false
    echo -n "$output"
}

# parser_output_command_deprecated_tag <page-content>
# Output "Deprecated" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_deprecated_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "Deprecated"
}

# parser_output_command_deprecated_tag_or_default <page-content>
# Output "Deprecated" tag from a page content or it's default when it's missing.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_deprecated_tag_value_or_default() {
    declare page_content="$1"

    declare output=
    output="$(parser_output_command_deprecated_tag_value "$page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    [[ -z "$output" ]] && output=false
    echo -n "$output"
}

# parser_output_command_see_also_tag <page-content>
# Output "See also" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_see_also_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "See also"
}

# parser_output_command_aliases_tag <page-content>
# Output "Aliases" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_aliases_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "Aliases"
}

# parser_output_command_syntax_compatible_tag <page-content>
# Output "Syntax compatible" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_syntax_compatible_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "Syntax compatible"
}

# parser_output_command_help_tag <page-content>
# Output "Help" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_help_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "Help"
}

# parser_output_command_version_tag <page-content>
# Output "Version" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_version_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "Version"
}

# parser_output_command_structure_compatible_tag <page-content>
# Output "Structure compatible" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_structure_compatible_tag_value() {
    declare page_content="$1"

    __parser_output_command_tag_value "$page_content" "Structure compatible"
}

# __parser_output_command_examples <page-content>
# Output command examples from a page content.
#
# Output:
#   <command-examples>
#
# Return:
#   - 0 if page layout is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
__parser_output_command_examples() {
    declare page_content="$1"

    __parser_check_layout_correctness "$page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2016
    sed -nE '/^[-`]/ { s/^- +//; s/ *:$//; s/^` *//; s/ *`$//; p; }' <<<"$page_content"
}

# __parser_output_command_examples_count <page-content>
# Output command example count from a page content.
#
# Output:
#   <command-examples-count>
#
# Return:
#   - 0 if page layout is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
__parser_output_command_example_count() {
    declare page_content="$1"

    declare examples=
    examples="$(__parser_output_command_examples "$page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    # shellcheck disable=2155
    declare -i count="$(echo "$examples" | wc -l)"
    ((count % 2 == 0)) || ((count++))

    echo -n "$((count / 2))"
}

# parser_output_command_example_description <page-content> <index>
# Output command example description from a page content.
#
# Output:
#   <command-example-description>
#
# Return:
#   - 0 if page layout, index is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_example_description() {
    declare page_content="$1"
    declare -i index="$2"

    ((index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare examples=
    examples="$(__parser_output_command_examples "$page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    # shellcheck disable=2155
    declare -i count="$(__parser_output_command_example_count "$page_content")"
    ((index >= count)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    sed -nE "$((index * 2 + 1)) p" <<<"$examples"
}

# parser_output_command_example_code <page-content> <index>
# Output command example code from a page content.
#
# Output:
#   <command-example-code>
#
# Return:
#   - 0 if page layout, index is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_example_code() {
    declare page_content="$1"
    declare -i index="$2"

    ((index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare examples=
    examples="$(__parser_output_command_examples "$page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    # shellcheck disable=2155
    declare -i count="$(__parser_output_command_example_count "$page_content")"
    ((index >= count)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    sed -nE "$((index * 2 + 2)) p" <<<"$examples"
}
