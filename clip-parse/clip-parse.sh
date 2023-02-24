#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i FAIL=1

declare LIBRARY_NAME="$(basename "$0")"

color_to_code() {
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
declare RESET_COLOR="\e[$(color_to_code none)m"
declare ERROR_COLOR="\e[$(color_to_code red)m"
declare SUCCESS_COLOR="\e[$(color_to_code green)m"

print_message() {
    declare source="$1"
    declare message="$2"

    echo -e "$PROGRAM_NAME: $source: ${SUCCESS_COLOR}$message$RESET_COLOR" >&2
}

throw_error() {
    declare source="$1"
    declare message="$2"

    echo -e "$PROGRAM_NAME: $source: ${ERROR_COLOR}$message$RESET_COLOR" >&2
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
