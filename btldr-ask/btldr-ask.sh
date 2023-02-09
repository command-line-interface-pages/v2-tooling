#!/usr/bin/env bash

# shellcheck disable=2016,2155,2181

declare -i SUCCESS=0
declare -i FAIL=1

declare RESET_COLOR="\e[0m"
declare ERROR_COLOR="\e[31m"
declare SUCCESS_COLOR="\e[32m"

help() {
    echo "Placeholder explanator for Better TlDr.

Usage:
  $0 (--help|-h)
  $0 (--version|-v)
  $0 (--author|-a)
  $0 (--email|-e)
  $0 <placeholder>

Notes:
  Omit placeholder curly braces when passing placeholders.
  Escaping and placeholders with alternatives are not recognized and treated literally."
}

version() {
    echo "1.0" >&2
}

author() {
    echo "Emily Grace Seville" >&2
}

email() {
    echo "EmilySeville7cfg@gmail.com" >&2
}

explain() {
    declare placeholder="$1"

    sed -nE '/^[^{}].+[^{}]$/! Q1' <<<"$placeholder" || {
        echo -e "$0: $placeholder: ${ERROR_COLOR}no curly braces expected$RESET_COLOR" >&2
        return "$FAIL"
    }

    if [[ "$placeholder" =~ ^(/?)([^ {}:*+?]+)([*+?]?)\ +([^{}:]+) ]]; then
        declare placeholder_leading_slash="${BASH_REMATCH[1]}"
        declare placeholder_type="${BASH_REMATCH[2]}"
        declare placeholder_quantifier="${BASH_REMATCH[3]}"
        declare placeholder_description="${BASH_REMATCH[4]}"

        if [[ -n "$placeholder_leading_slash" ]] && [[ ! "$placeholder_type" =~ ^(file|directory|path)$ ]]; then
            echo -e "$0: $placeholder: ${ERROR_COLOR}no leading slash expected$RESET_COLOR" >&2
            return "$FAIL"
        fi

        declare placeholder_readable_type
        case "$placeholder_type" in
            bool)
                placeholder_readable_type="Boolean"
            ;;
            int)
                placeholder_readable_type="Integer"
            ;;
            float)
                placeholder_readable_type="Float"
            ;;
            char)
                placeholder_readable_type="Character"
            ;;
            string)
                placeholder_readable_type="Text"
            ;;
            command)
                placeholder_readable_type="Command or subcommand"
            ;;
            file)
                placeholder_readable_type="Regular file, pipe or device"
            ;;
            directory)
                placeholder_readable_type="Directory"
            ;;
            path)
                placeholder_readable_type="Regular file, pipe, device or directory"
            ;;
            any)
                placeholder_readable_type="Anything"
            ;;
        esac

        echo "- $placeholder_readable_type expected to be used instead of this placeholder."
        
        [[ "$placeholder_type" =~ ^(file|directory|path)$ ]] && {
            if [[ -n "$placeholder_leading_slash" ]]; then
                echo "- Absolute path expected."
            else
                echo "- Relative path expected."
            fi
        }

        declare placeholder_readable_quantifier
        case "$placeholder_quantifier" in
            "?")
                placeholder_readable_quantifier="Zero or one"
            ;;
            "*")
                placeholder_readable_quantifier="Zero or more"
            ;;
            "+")
                placeholder_readable_quantifier="One or more"
            ;;
        esac

        [[ -n "$placeholder_quantifier" ]] && echo "- $placeholder_readable_quantifier values can be substituted instead of this placeholder."

        echo "- Placeholder can be described as $placeholder_description."
    else
        echo -e "'$placeholder': ${ERROR_COLOR}valid placeholder expected$RESET_COLOR" >&2
        return "$FAIL"
    fi
}

if (($# == 0)); then
    help
fi

while [[ -n "$1" ]]; do
    declare option="$1"

    case "$option" in
    --help | -h)
        help
        exit
        ;;
    --version | -v)
        version
        exit
        ;;
    --author | -a)
        author
        exit
        ;;
    --email | -e)
        email
        exit
        ;;
    *)
        declare placeholder="$option"
        declare explanation
        explanation="$(explain "$placeholder")"
        (($? == 0)) && {
            echo -e "$placeholder: ${SUCCESS_COLOR}explained:$RESET_COLOR" >&2
            echo "$explanation"
        }
        shift
        ;;
    esac
done

exit "$SUCCESS"
