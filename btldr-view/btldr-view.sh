#!/usr/bin/env bash

# shellcheck disable=2016,2155,2115

declare -i SUCCESS=0
declare -i FAIL=1

# Cache options:
declare CACHE_DIRECTORY="${CACHE_DIRECTORY:-$HOME/.btldr}"

# Error colors:
declare RESET_COLOR="\e[0m"
declare ERROR_COLOR="\e[31m"

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

# Header options:
declare HEADER_COMMAND_PREFIX="${HEADER_COMMAND_PREFIX:-Command: }"

declare HEADER_COMMAND_PREFIX_COLOR="$(color_to_code "${HEADER_COMMAND_PREFIX_COLOR:-blue}")"

declare HEADER_COMMAND_SUFFIX_COLOR="$(color_to_code "${HEADER_COMMAND_SUFFIX_COLOR:-cyan}")"

# Summary options:
declare SUMMARY_DESCRIPTION_PREFIX="${SUMMARY_DESCRIPTION_PREFIX:-Description: }"
declare SUMMARY_ALIASES_PREFIX="${SUMMARY_ALIASES_PREFIX:-Aliases: }"
declare SUMMARY_SEE_ALSO_PREFIX="${SUMMARY_SEE_ALSO_PREFIX:-Similar commands: }"
declare SUMMARY_MORE_INFORMATION_PREFIX="${SUMMARY_MORE_INFORMATION_PREFIX:-Documentation: }"

declare SUMMARY_DESCRIPTION_PREFIX_COLOR="$(color_to_code "${SUMMARY_DESCRIPTION_PREFIX_COLOR:-blue}")"
declare SUMMARY_ALIASES_PREFIX_COLOR="$(color_to_code "${SUMMARY_ALIASES_PREFIX_COLOR:-blue}")"
declare SUMMARY_SEE_ALSO_PREFIX_COLOR="$(color_to_code "${SUMMARY_SEE_ALSO_PREFIX_COLOR:-blue}")"
declare SUMMARY_MORE_INFORMATION_PREFIX_COLOR="$(color_to_code "${SUMMARY_MORE_INFORMATION_PREFIX_COLOR:-blue}")"

declare SUMMARY_DESCRIPTION_SUFFIX_COLOR="$(color_to_code "${SUMMARY_DESCRIPTION_SUFFIX_COLOR:-cyan}")"
declare SUMMARY_ALIASES_SUFFIX_COLOR="$(color_to_code "${SUMMARY_ALIASES_SUFFIX_COLOR:-cyan}")"
declare SUMMARY_SEE_ALSO_SUFFIX_COLOR="$(color_to_code "${SUMMARY_SEE_ALSO_SUFFIX_COLOR:-cyan}")"
declare SUMMARY_MORE_INFORMATION_SUFFIX_COLOR="$(color_to_code "${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR:-cyan}")"

# Code description options:
declare CODE_DESCRIPTION_PREFIX="${CODE_DESCRIPTION_PREFIX:-Code description: }"

declare CODE_DESCRIPTION_PREFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_PREFIX_COLOR:-green}")"

declare CODE_DESCRIPTION_SUFFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_SUFFIX_COLOR:-cyan}")"

# Code description mnemonic options:
declare CODE_DESCRIPTION_MNEMONIC_PREFIX="${CODE_DESCRIPTION_MNEMONIC_PREFIX:-}"

declare CODE_DESCRIPTION_MNEMONIC_SUFFIX="${CODE_DESCRIPTION_MNEMONIC_SUFFIX:-}"

declare CODE_DESCRIPTION_MNEMONIC_COLOR="$(color_to_code "${CODE_DESCRIPTION_MNEMONIC_COLOR:-red}")"

# Code description stream options:
declare CODE_DESCRIPTION_STREAM_PREFIX="${CODE_DESCRIPTION_STREAM_PREFIX:-\'}"

declare CODE_DESCRIPTION_STREAM_SUFFIX="${CODE_DESCRIPTION_STREAM_SUFFIX:-\'}"

declare CODE_DESCRIPTION_STREAM_COLOR="$(color_to_code "${CODE_DESCRIPTION_STREAM_COLOR:-red}")"

# Code example options:
declare CODE_EXAMPLE_PREFIX="${CODE_EXAMPLE_PREFIX:-Code example: }"

declare CODE_EXAMPLE_PREFIX_COLOR="$(color_to_code "${CODE_EXAMPLE_PREFIX_COLOR:-red}")"

declare CODE_EXAMPLE_SUFFIX_COLOR="$(color_to_code "${CODE_EXAMPLE_SUFFIX_COLOR:-gray}")"

# Code example placeholder options:
declare CODE_EXAMPLE_PLACEHOLDER_PREFIX="${CODE_EXAMPLE_PLACEHOLDER_PREFIX:-<}"

declare CODE_EXAMPLE_PLACEHOLDER_SUFFIX="${CODE_EXAMPLE_PLACEHOLDER_SUFFIX:->}"

declare CODE_EXAMPLE_PLACEHOLDER_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_COLOR:-black}")"
declare CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR="$(color_to_code "${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR:-red}")"
declare CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR="$(color_to_code "${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR:-cyan}")"
declare CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR:-yellow}")"
declare CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR:-green}")"

help() {
  echo "Render for Better TlDr pages.

Usage:
  $0 (--help|-h)
  $0 (--version|-v)
  $0 (--author|-a)
  $0 (--email|-e)
  $0 (--clear-cache|-cc)
  $0 [(--operating-system|-os) <android|linux|osx|sunos|windows>] [(--update-page|-up)] (<local-file.md>|<remote-page>)...

Environment variables:
  - HEADER_COMMAND_PREFIX
    - HEADER_COMMAND_PREFIX_COLOR
    - HEADER_COMMAND_SUFFIX_COLOR
  - SUMMARY_DESCRIPTION_PREFIX, SUMMARY_ALIASES_PREFIX, SUMMARY_SEE_ALSO_PREFIX,
    SUMMARY_MORE_INFORMATION_PREFIX
    - SUMMARY_DESCRIPTION_PREFIX_COLOR, SUMMARY_ALIASES_PREFIX_COLOR, SUMMARY_SEE_ALSO_PREFIX_COLOR,
      SUMMARY_MORE_INFORMATION_PREFIX_COLOR
    - SUMMARY_DESCRIPTION_SUFFIX_COLOR, SUMMARY_ALIASES_SUFFIX_COLOR, SUMMARY_SEE_ALSO_SUFFIX_COLOR,
      SUMMARY_MORE_INFORMATION_SUFFIX_COLOR
  - CODE_DESCRIPTION_PREFIX
    - CODE_DESCRIPTION_PREFIX_COLOR
    - CODE_DESCRIPTION_SUFFIX_COLOR
  - CODE_DESCRIPTION_MNEMONIC_PREFIX, CODE_DESCRIPTION_MNEMONIC_SUFFIX
    - CODE_DESCRIPTION_MNEMONIC_COLOR
  - CODE_DESCRIPTION_STREAM_PREFIX, CODE_DESCRIPTION_STREAM_SUFFIX
    - CODE_DESCRIPTION_STREAM_COLOR
  - CODE_EXAMPLE_PREFIX
    - CODE_EXAMPLE_PREFIX_COLOR
    - CODE_EXAMPLE_SUFFIX_COLOR
  - CODE_EXAMPLE_PLACEHOLDER_PREFIX, CODE_EXAMPLE_PLACEHOLDER_SUFFIX
    - CODE_EXAMPLE_PLACEHOLDER_COLOR, CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR,
      CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR, CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR,
      CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR

Notes:
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

render() {
  declare page_file="$1"
  declare page_content="$(cat "$page_file")

"

  sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$page_content" || {
    echo -e "$0: $page_file: ${ERROR_COLOR}valid page layout expected$RESET_COLOR" >&2
    return "$FAIL"
  }

  echo -e "$(sed -E "/^#/ {
    s/^# (.*)$/\\\\e[${HEADER_COMMAND_PREFIX_COLOR}m$HEADER_COMMAND_PREFIX\\\\e[${HEADER_COMMAND_SUFFIX_COLOR}m\1\\\\e[0m/
  }
  
  /^>/ {
    s/^> Aliases: (.*)$/\\\\e[${SUMMARY_ALIASES_PREFIX_COLOR}m$SUMMARY_ALIASES_PREFIX\\\\e[${SUMMARY_ALIASES_SUFFIX_COLOR}m\1\\\\e[0m/
    s/^> See also: (.*)$/\\\\e[${SUMMARY_SEE_ALSO_PREFIX_COLOR}m$SUMMARY_SEE_ALSO_PREFIX\\\\e[${SUMMARY_SEE_ALSO_SUFFIX_COLOR}m\1\\\\e[0m/
    s/^> More information: (.*)$/\\\\e[${SUMMARY_MORE_INFORMATION_PREFIX_COLOR}m$SUMMARY_MORE_INFORMATION_PREFIX\\\\e[${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR}m\1\\\\e[0m/
    /^> (Aliases|See also|More information):/! s/^> (.*)$/\\\\e[${SUMMARY_DESCRIPTION_PREFIX_COLOR}m$SUMMARY_DESCRIPTION_PREFIX\\\\e[${SUMMARY_DESCRIPTION_SUFFIX_COLOR}m\1\\\\e[0m/
  }
  
  /^- / {
    s/^- (.*):$/\\\\e[${CODE_DESCRIPTION_PREFIX_COLOR}m$CODE_DESCRIPTION_PREFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m\1\\\\e[0m/
    s/\[([^ ]+)\]/\\\\e[${CODE_DESCRIPTION_MNEMONIC_COLOR}m$CODE_DESCRIPTION_MNEMONIC_PREFIX\1$CODE_DESCRIPTION_MNEMONIC_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/
    s/\<(std(in|out|err))\>/\\\\e[${CODE_DESCRIPTION_STREAM_COLOR}m$CODE_DESCRIPTION_STREAM_PREFIX\1$CODE_DESCRIPTION_STREAM_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/
  }
  
  /^\`/ {
    s/\`(.*)\`/\\\\e[${CODE_EXAMPLE_PREFIX_COLOR}m$CODE_EXAMPLE_PREFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m\1\\\\e[0m/


    # placeholders without examples and without quantifiers
    s/\{(bool|int|float|char|string|command) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\1 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
  
    # placeholders without examples and with ? quantifier
    s/\{(bool|int|float|char|string|command)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\1 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # placeholders without examples and with * quantifier
    s/\{(bool|int|float|char|string|command)\* +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(0..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\* +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(0..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any\* +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\1 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(0..more, anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # placeholders without examples and with + quantifier
    s/\{(bool|int|float|char|string|command)\+ +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(1..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\+ +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(1..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any\+ +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\1 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(1..more, anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g


    # placeholders with examples and without quantifiers
    s/\{(bool|int|float|char|string|command) +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path) +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\1\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # placeholders with examples and with ? quantifier
    s/\{(bool|int|float|char|string|command)\? +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\? +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any\? +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\1\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # placeholders with examples and with * quantifier
    s/\{(bool|int|float|char|string|command)\* +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(0..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\* +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(0..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any\* +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_OPTIONAL_PLACEHOLDER_CONTENT_COLOR}m\1\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(0..more, anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # placeholders with examples and with + quantifier
    s/\{(bool|int|float|char|string|command)\+ +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(1..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\+ +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\3 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(1..more)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{any\+ +([^{}:]+): +([^{}]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}m\1\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m, like: \\\\e[${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR}m\2 \\\\e[${CODE_EXAMPLE_PLACEHOLDER_QUANTIFIER_COLOR}m(1..more, anything)\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # broken placeholders
    s/\{[^ {}]+[^{}]*\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}munsupported placeholder\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
  }" <<<"$page_content")"
}

if (($# == 0)); then
  help
fi

declare operating_system=common
declare -i update_cache=1

while [[ -n "$1" ]]; do
  declare option="$1"
  declare value="$2"

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
  --operating-system | -os)
    [[ -z "$value" ]] && {
        echo -e "$0: $option: ${ERROR_COLOR}option value expected$RESET_COLOR" >&2
        exit "$FAIL"
    }
    operating_system="$value"
    shift 2
    ;;
  --clear-cache | -cc)
    rm -rf "$CACHE_DIRECTORY/$page_path"
    exit
    ;;
  --update-cache | -uc)
    update_cache=0
    shift 2
    ;;
  *)
    declare local_file_or_remote_page="$option"
    declare is_local=1

    file_to_render="$(mktemp "/tmp/btldr.XXXXXX")"
    [[ "$local_file_or_remote_page" =~ .btldr$ ]] && is_local=0

    declare file_to_render
    if ((is_local == 0)); then
      [[ -f "$local_file_or_remote_page" ]] || {
        echo -e "$0: $page_file: ${ERROR_COLOR}existing page expected$RESET_COLOR" >&2
        exit "$FAIL"
      }
      cat "$local_file_or_remote_page" > "$file_to_render"
    else
      declare page_path="$operating_system/$local_file_or_remote_page.btldr"

      ((update_cache == 0)) && rm -rf "$CACHE_DIRECTORY/$page_path"

      if [[ ! -f "$CACHE_DIRECTORY/$page_path" ]]; then
        wget "https://raw.githubusercontent.com/emilyseville7cfg-better-tldr/cli-pages/main/$page_path" -O "$file_to_render" 2> /dev/null || {
          echo -e "$0: $page_path: ${ERROR_COLOR}existing remote page expected$RESET_COLOR" >&2
          exit "$FAIL"
        }

        mkdir -p "$(dirname "$CACHE_DIRECTORY/$page_path")"
        cat "$file_to_render" > "$CACHE_DIRECTORY/$page_path"
      else
        cat "$CACHE_DIRECTORY/$page_path" > "$file_to_render"
      fi
    fi

    render "$file_to_render" || {
      rm "$file_to_render"
      exit "$FAIL"
    }
    rm "$file_to_render"
    shift
    ;;
  esac
done

exit "$SUCCESS"
