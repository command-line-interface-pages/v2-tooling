#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i FAIL=1

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

    parser_check_layout_correctness "$page_content" || return "$FAIL"

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
    sed -nE ':x; N; $! bx; /^(> [^\n:]+\n){1,2}(> [^\n:]+:[^\n:]+\n)$/! Q1' <<<"$page_summary"$'\n'
}

# parser_output_command_description <page-content>
# Output command description from a page content.
#
# Output:
#   <command-description>
#
# Return:
#   - 0 if page layout/command summary is valid
#   - 1 otherwise
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_description() {
    declare page_content="$1"

    parser_check_layout_correctness "$page_content" || return "$FAIL"
    
    # shellcheck disable=2155
    declare command_summary="$(sed -nE '/^>/ p' <<<"$page_content")"
    parser_check_command_summary_correctness "$command_summary" || return "$FAIL"

    sed -nE '/^> [^:]+$/ s/^> //p' <<<"$command_summary"
}
