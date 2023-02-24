#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i FAIL=1

declare -i INVALID_LAYOUT_FAIL=1
declare -i INVALID_SUMMARY_FAIL=2
declare -i INVALID_TAG_FAIL=3
declare -i INVALID_TAG_VALUE_FAIL=4

declare PARSER_ERROR_PREFIX="${PARSER_ERROR_PREFIX:-$(basename "$0")}"

parser_color_to_code() {
    declare color="$1"

    case "$color" in
    red)
        echo -n 31
        ;;
    green)
        echo -n 32
        ;;
    yellow)
        echo -n 33
        ;;
    blue)
        echo -n 34
        ;;
    magenta)
        echo -n 35
        ;;
    cyan)
        echo -n 36
        ;;
    light-gray)
        echo -n 37
        ;;
    gray)
        echo -n 90
        ;;
    light-red)
        echo -n 91
        ;;
    light-green)
        echo -n 92
        ;;
    light-yellow)
        echo -n 93
        ;;
    light-blue)
        echo -n 94
        ;;
    light-magenta)
        echo -n 95
        ;;
    light-cyan)
        echo -n 96
        ;;
    white)
        echo -n 97
        ;;
    *)
        echo -n 0
        ;;
    esac
}

# Error colors:
declare RESET_COLOR="\e[$(parser_color_to_code none)m"
declare ERROR_COLOR="\e[$(parser_color_to_code red)m"
declare SUCCESS_COLOR="\e[$(parser_color_to_code green)m"

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

# parser_check_layout_correctness <page-content>
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
parser_check_layout_correctness() {
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

    parser_check_layout_correctness "$page_content" || return "$INVALID_LAYOUT_FAIL"

    sed -nE '1 { s/^# +//; s/ +$//; s/ +/ /g; p; }' <<<"$page_content"
}

# parser_check_summary_correctness <page-summary>
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
parser_check_command_summary_correctness() {
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

    parser_check_layout_correctness "$page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2155
    declare command_summary="$(sed -nE '/^>/ p' <<<"$page_content")"
    parser_check_command_summary_correctness "$command_summary" || return "$INVALID_SUMMARY_FAIL"

    sed -nE '/^> [^:]+$/ { s/^> +//; s/ +$//; p; }' <<<"$command_summary"
}

# parser_check_command_tag_correctness <command-tag>
# Check whether a command tag is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if command tag is valid
#   - 1 otherwise
parser_check_command_tag_correctness() {
    declare command_tag="$1"

    [[ "$command_tag" =~ ^(More information|Internal|Deprecated|See also|Aliases|Syntax compatible|Help|Version|Structure compatible)$ ]]
}

# parser_output_command_tag <page-content>
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
parser_output_command_tags() {
    declare page_content="$1"

    parser_check_layout_correctness "$page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2155
    declare command_summary="$(sed -nE '/^>/ p' <<<"$page_content")"
    parser_check_command_summary_correctness "$command_summary" || return "$INVALID_SUMMARY_FAIL"

    # shellcheck disable=2155
    declare output="$(sed -nE '/^> [^:]+:.+$/ { s/^> //; s/: +/\n/; p; }' <<<"$command_summary")"
    mapfile -t command_tags <<<"$output"

    declare -i index=0
    while ((index < "${#command_tags[@]}")); do
        declare tag="${command_tags[index]}"
        parser_check_command_tag_correctness "$tag" || return "$INVALID_TAG_FAIL"
        index+=2
    done

    echo -n "$output"
}

# parser_output_command_tag <page-content> <tag>
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
parser_output_command_tag() {
    declare page_content="$1"
    declare command_tag="$2"

    parser_check_command_tag_correctness "$command_tag" || return "$INVALID_TAG_FAIL"

    declare output=
    output="$(parser_output_command_tags "$page_content")"
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
parser_output_command_more_information_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "More information"
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
parser_output_command_internal_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "Internal"
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
parser_output_command_internal_tag_or_default() {
    declare page_content="$1"

    declare output=
    output="$(parser_output_command_internal_tag "$page_content")"
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
parser_output_command_deprecated_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "Deprecated"
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
parser_output_command_deprecated_tag_or_default() {
    declare page_content="$1"

    declare output=
    output="$(parser_output_command_deprecated_tag "$page_content")"
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
parser_output_command_see_also_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "See also"
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
parser_output_command_aliases_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "Aliases"
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
parser_output_command_syntax_compatible_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "Syntax compatible"
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
parser_output_command_help_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "Help"
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
parser_output_command_version_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "Version"
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
parser_output_command_structure_compatible_tag() {
    declare page_content="$1"

    parser_output_command_tag "$page_content" "Structure compatible"
}
