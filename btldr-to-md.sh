#!/usr/bin/env bash

# shellcheck disable=2016,2155

declare -i SUCCESS=0
declare -i FAIL=1

declare RESET_COLOR="\e[0m"
declare ERROR_COLOR="\e[31m"
declare SUCCESS_COLOR="\e[32m"

help() {
  echo "Converter from Better TlDr format to TlDr format.

Usage:
  $0 (--help|-h)
  $0 (--version|-v)
  $0 (--author|-a)
  $0 (--email|-e)
  $0 [(--output-directory|-od) <directory>] <file1.md file2.md ...>

Converters:
  - Placeholder conversion

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

convert() {
  declare page_file="$1"
  declare page_content="$(cat "$page_file")

"

  sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<< "$page_content" || {
    echo -e "$0: $page_file: ${ERROR_COLOR}valid page layout expected$RESET_COLOR" >&2
    return "$FAIL"
  }

  sed -E '/^>/ {
    s/$/./
    s/More +information: (.*)\.$/More information: <\1>./
  }
  
  /^`/ {
    # converting Better TlDr placeholders to TlDr placeholders
    s/\{bool +[^{}:]+\}/{{boolean}}/g
    s/\{bool +[^{}:]+: *([^,{}]+) +(,[^{}]+)?\}/{{\1}}/g
    s/\{bool +[^{}:]+: *([^,{}]+)(,[^{}]+)?\}/{{\1}}/g

    s/\{(int|float|char|string|command|string) +([^{}:]+)\}/{{\2}}/g
    s/\{(int|float|char|string|command|string) +[^{}:]+: *([^,{}]+) +(,[^{}]+)?\}/{{\2}}/g
    s/\{(int|float|char|string|command|string) +[^{}:]+: *([^,{}]+)(,[^{}]+)?\}/{{\2}}/g

    s/\{(\/?)(file|directory) +([^{}:]+)\}/{{\1path\/to\/\3_\2}}/g
    s/\{\/?(file|directory) +[^{}:]+: *([^,{}]+) +(,[^{}]+)?\}/{{\2}}/g
    s/\{\/?(file|directory) +[^{}:]+: *([^,{}]+)(,[^{}]+)?\}/{{\2}}/g

    s/\{(\/?)path +[^{}:]+\}/{{\1path\/to\/file_or_directory}}/g
    s/\{\/?path +[^{}:]+: *([^,{}]+) +(,[^{}]+)?\}/{{\1}}/g
    s/\{\/?path +[^{}:]+: *([^,{}]+)(,[^{}]+)?\}/{{\1}}/g

    s/\{(\/?)(file|directory)\* +([^{}:]+)\}/{{\1path\/to\/\3_\21 \1path\/to\/\3_\22 ...}}/g
    s/\{(\/?)(file|directory)\+ +([^{}:]+)\}/{{\1path\/to\/\3_\21}} {{\1path\/to\/\3_\22 \1path\/to\/\3_\23 ...}}/g

  }' <<< "$page_content"
}


if (($# == 0)); then
  help
fi

declare output_directory

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
  --output-directory | -od)
    [[ -z "$value" ]] && {
      echo -e "$0: --output-directory: ${ERROR_COLOR}directory expected$RESET_COLOR" >&2
      exit "$FAIL"
    }
    output_directory="$value"
    shift 2
    ;;
  *)
    declare btldr_file="$option"
    declare tldr_file="$(sed -E 's/.*\///; s/\.btldr$/.md/' <<< "$btldr_file")"
    if [[ -z "$output_directory" ]]; then
      tldr_file="$(dirname "$btldr_file")/$tldr_file"
    else
      tldr_file="$output_directory/$tldr_file"
    fi

    declare tldr_content
    tldr_content="$(convert "$btldr_file")"
    (($? != 0)) && exit "$FAIL"

    echo "$tldr_content" > "$tldr_file"

    echo -e "$0: $btldr_file: ${SUCCESS_COLOR}converted to $tldr_file$RESET_COLOR" >&2
    shift
    ;;
  esac
done

exit "$SUCCESS"
