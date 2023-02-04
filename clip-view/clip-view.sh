#!/usr/bin/env bash

# shellcheck disable=2016,2155,2115

declare -i SUCCESS=0
declare -i FAIL=1

# Cache options:
declare CACHE_DIRECTORY="${CACHE_DIRECTORY:-$HOME/.clip}"

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


# Help colors:
declare HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN="\e[40;97mT\e[107;30mxt$RESET_COLOR"
declare HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN="\e[41;97mR\e[107;32mg\e[34mb$RESET_COLOR"

declare HELP_HEADER_COLOR="\e[$(color_to_code blue)m"
declare HELP_TEXT_COLOR="\e[$(color_to_code black)m"
declare HELP_OPTION_COLOR="\e[$(color_to_code green)m"
declare HELP_PLACEHOLDER_COLOR="\e[$(color_to_code cyan)m"
declare HELP_PUNCTUATION_COLOR="\e[$(color_to_code gray)m"
declare HELP_ENVIRONMENT_VARIABLE_COLOR="\e[$(color_to_code cyan)m"


# Header options:
declare HEADER_COMMAND_PREFIX="${HEADER_COMMAND_PREFIX-Command: }"
declare HEADER_COMMAND_SUFFIX="${HEADER_COMMAND_SUFFIX-}"

declare HEADER_COMMAND_COLOR="$(color_to_code "${HEADER_COMMAND_COLOR-cyan}")"
declare HEADER_COMMAND_PREFIX_COLOR="$(color_to_code "${HEADER_COMMAND_PREFIX_COLOR-blue}")"
declare HEADER_COMMAND_SUFFIX_COLOR="$(color_to_code "${HEADER_COMMAND_SUFFIX_COLOR-blue}")"


# Summary options:
declare SUMMARY_DESCRIPTION_PREFIX="${SUMMARY_DESCRIPTION_PREFIX-Description: }"
declare SUMMARY_ALIASES_PREFIX="${SUMMARY_ALIASES_PREFIX-Aliases: }"
declare SUMMARY_SEE_ALSO_PREFIX="${SUMMARY_SEE_ALSO_PREFIX-Similar commands: }"
declare SUMMARY_MORE_INFORMATION_PREFIX="${SUMMARY_MORE_INFORMATION_PREFIX-Documentation: }"
declare SUMMARY_INTERNAL_PREFIX="${SUMMARY_INTERNAL_PREFIX-[!] }"
declare SUMMARY_DEPRECATED_PREFIX="${SUMMARY_DEPRECATED_PREFIX-[!] }"
declare SUMMARY_DESCRIPTION_SUFFIX="${SUMMARY_DESCRIPTION_SUFFIX-}"
declare SUMMARY_ALIASES_SUFFIX="${SUMMARY_ALIASES_SUFFIX-}"
declare SUMMARY_SEE_ALSO_SUFFIX="${SUMMARY_SEE_ALSO_SUFFIX-}"
declare SUMMARY_MORE_INFORMATION_SUFFIX="${SUMMARY_MORE_INFORMATION_SUFFIX-}"
declare SUMMARY_INTERNAL_SUFFIX="${SUMMARY_INTERNAL_SUFFIX-}"
declare SUMMARY_DEPRECATED_SUFFIX="${SUMMARY_DEPRECATED_SUFFIX-}"

declare SUMMARY_DESCRIPTION_COLOR="$(color_to_code "${SUMMARY_DESCRIPTION_COLOR-cyan}")"
declare SUMMARY_ALIASES_COLOR="$(color_to_code "${SUMMARY_ALIASES_COLOR-cyan}")"
declare SUMMARY_SEE_ALSO_COLOR="$(color_to_code "${SUMMARY_SEE_ALSO_COLOR-cyan}")"
declare SUMMARY_MORE_INFORMATION_COLOR="$(color_to_code "${SUMMARY_MORE_INFORMATION_COLOR-cyan}")"
declare SUMMARY_INTERNAL_COLOR="$(color_to_code "${SUMMARY_INTERNAL_COLOR-cyan}")"
declare SUMMARY_DEPRECATED_COLOR="$(color_to_code "${SUMMARY_DEPRECATED_COLOR-cyan}")"

declare SUMMARY_DESCRIPTION_PREFIX_COLOR="$(color_to_code "${SUMMARY_DESCRIPTION_PREFIX_COLOR-blue}")"
declare SUMMARY_ALIASES_PREFIX_COLOR="$(color_to_code "${SUMMARY_ALIASES_PREFIX_COLOR-blue}")"
declare SUMMARY_SEE_ALSO_PREFIX_COLOR="$(color_to_code "${SUMMARY_SEE_ALSO_PREFIX_COLOR-blue}")"
declare SUMMARY_MORE_INFORMATION_PREFIX_COLOR="$(color_to_code "${SUMMARY_MORE_INFORMATION_PREFIX_COLOR-blue}")"
declare SUMMARY_INTERNAL_PREFIX_COLOR="$(color_to_code "${SUMMARY_INTERNAL_PREFIX_COLOR-red}")"
declare SUMMARY_DEPRECATED_PREFIX_COLOR="$(color_to_code "${SUMMARY_DEPRECATED_PREFIX_COLOR-red}")"

declare SUMMARY_DESCRIPTION_SUFFIX_COLOR="$(color_to_code "${SUMMARY_DESCRIPTION_SUFFIX_COLOR-blue}")"
declare SUMMARY_ALIASES_SUFFIX_COLOR="$(color_to_code "${SUMMARY_ALIASES_SUFFIX_COLOR-blue}")"
declare SUMMARY_SEE_ALSO_SUFFIX_COLOR="$(color_to_code "${SUMMARY_SEE_ALSO_SUFFIX_COLOR-blue}")"
declare SUMMARY_MORE_INFORMATION_SUFFIX_COLOR="$(color_to_code "${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR-blue}")"
declare SUMMARY_INTERNAL_SUFFIX_COLOR="$(color_to_code "${SUMMARY_INTERNAL_SUFFIX_COLOR-red}")"
declare SUMMARY_DEPRECATED_SUFFIX_COLOR="$(color_to_code "${SUMMARY_DEPRECATED_SUFFIX_COLOR-red}")"


# Code description options:
declare CODE_DESCRIPTION_PREFIX="${CODE_DESCRIPTION_PREFIX-- }"
declare CODE_DESCRIPTION_SUFFIX="${CODE_DESCRIPTION_SUFFIX-}"

declare CODE_DESCRIPTION_COLOR="$(color_to_code "${CODE_DESCRIPTION_COLOR-blue}")"
declare CODE_DESCRIPTION_PREFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_PREFIX_COLOR-magenta}")"
declare CODE_DESCRIPTION_SUFFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_SUFFIX_COLOR-magenta}")"


# Code description mnemonic options:
declare CODE_DESCRIPTION_MNEMONIC_PREFIX="${CODE_DESCRIPTION_MNEMONIC_PREFIX-}"
declare CODE_DESCRIPTION_MNEMONIC_SUFFIX="${CODE_DESCRIPTION_MNEMONIC_SUFFIX-}"

declare CODE_DESCRIPTION_MNEMONIC_COLOR="$(color_to_code "${CODE_DESCRIPTION_MNEMONIC_COLOR-light-red}")"
declare CODE_DESCRIPTION_MNEMONIC_PREFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_MNEMONIC_PREFIX_COLOR-red}")"
declare CODE_DESCRIPTION_MNEMONIC_SUFFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_MNEMONIC_SUFFIX_COLOR-red}")"


# Code description stream options:
declare CODE_DESCRIPTION_STREAM_PREFIX="${CODE_DESCRIPTION_STREAM_PREFIX-}"
declare CODE_DESCRIPTION_STREAM_SUFFIX="${CODE_DESCRIPTION_STREAM_SUFFIX-}"

declare CODE_DESCRIPTION_STREAM_COLOR="$(color_to_code "${CODE_DESCRIPTION_STREAM_COLOR-light-cyan}")"
declare CODE_DESCRIPTION_STREAM_PREFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_STREAM_PREFIX_COLOR-red}")"
declare CODE_DESCRIPTION_STREAM_SUFFIX_COLOR="$(color_to_code "${CODE_DESCRIPTION_STREAM_SUFFIX_COLOR-red}")"


# Code example options:
declare CODE_EXAMPLE_PREFIX="${CODE_EXAMPLE_PREFIX-  }"
declare CODE_EXAMPLE_SUFFIX="${CODE_EXAMPLE_SUFFIX-}"

declare CODE_EXAMPLE_COLOR="$(color_to_code "${CODE_EXAMPLE_COLOR-gray}")"
declare CODE_EXAMPLE_PREFIX_COLOR="$(color_to_code "${CODE_EXAMPLE_PREFIX_COLOR-magenta}")"
declare CODE_EXAMPLE_SUFFIX_COLOR="$(color_to_code "${CODE_EXAMPLE_SUFFIX_COLOR-magenta}")"


# Code example placeholder options:
declare CODE_EXAMPLE_PLACEHOLDER_PREFIX="${CODE_EXAMPLE_PLACEHOLDER_PREFIX-<}"
declare CODE_EXAMPLE_PLACEHOLDER_SUFFIX="${CODE_EXAMPLE_PLACEHOLDER_SUFFIX->}"

declare CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR-black}")"
declare CODE_EXAMPLE_PLACEHOLDER_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_COLOR-black}")"
declare CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR-black}")"


# Code example placeholder keyword options:
declare CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR-red}")"
declare CODE_EXAMPLE_PLACEHOLDER_OPTIONAL_KEYWORD_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_OPTIONAL_KEYWORD_COLOR-green}")"
declare CODE_EXAMPLE_PLACEHOLDER_REPEATED_REQUIRED_KEYWORD_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_REPEATED_REQUIRED_KEYWORD_COLOR-blue}")" # + quantifier or range beginning with non 0
declare CODE_EXAMPLE_PLACEHOLDER_REPEATED_OPTIONAL_KEYWORD_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_REPEATED_OPTIONAL_KEYWORD_COLOR-yellow}")" # * quantifier or range beginning with 0


# Code example placeholder examples options:
declare CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR="$(color_to_code "${CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR-cyan}")"


help() {
  declare program_name="$(basename "$0")"

  echo -e "${HELP_TEXT_COLOR}Render for Command Line Interface Pages pages.

${HELP_HEADER_COLOR}Usage:$HELP_TEXT_COLOR
  $program_name $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--help$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-h$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $program_name $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--version$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-v$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $program_name $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--author$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-a$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $program_name $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--email$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-e$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $program_name $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--clear-cache$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-cc$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $program_name ${HELP_PUNCTUATION_COLOR}[($HELP_OPTION_COLOR--operating-system$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-os$HELP_PUNCTUATION_COLOR) $HELP_PLACEHOLDER_COLOR<android|linux|osx|sunos|windows>$HELP_PUNCTUATION_COLOR] [($HELP_OPTION_COLOR--render$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-r$HELP_PUNCTUATION_COLOR) $HELP_PLACEHOLDER_COLOR<tldr|tldr-colorful|docopt|docopt-colorful>$HELP_PUNCTUATION_COLOR] [($HELP_OPTION_COLOR--update-page$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-up$HELP_PUNCTUATION_COLOR)] ($HELP_PLACEHOLDER_COLOR<local-file.md>$HELP_PUNCTUATION_COLOR|$HELP_PLACEHOLDER_COLOR<remote-page>$HELP_PUNCTUATION_COLOR)...

${HELP_HEADER_COLOR}Environment variables:$HELP_TEXT_COLOR
${HELP_HEADER_COLOR}  Header:$HELP_TEXT_COLOR
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}HEADER_COMMAND_PREFIX ${HELP_TEXT_COLOR}everything before a command name
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}HEADER_COMMAND_SUFFIX ${HELP_TEXT_COLOR}everything after the last subcommand or a command name

    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}HEADER_COMMAND_COLOR ${HELP_TEXT_COLOR}color for a command and subcommand names
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}HEADER_COMMAND_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before a command name
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}HEADER_COMMAND_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for command name and everything after it

${HELP_HEADER_COLOR}  Description:$HELP_TEXT_COLOR
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DESCRIPTION_PREFIX ${HELP_TEXT_COLOR}everything before a command description
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_ALIASES_PREFIX ${HELP_TEXT_COLOR}everything before 'Aliases' tag
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_SEE_ALSO_PREFIX ${HELP_TEXT_COLOR}everything before 'See also' tag
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_MORE_INFORMATION_PREFIX ${HELP_TEXT_COLOR}everything before 'More information' tag
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_INTERNAL_PREFIX ${HELP_TEXT_COLOR}everything before 'Internal' tag
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DEPRECATED_PREFIX ${HELP_TEXT_COLOR}everything before 'Deprecated' tag
    
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_ALIASES_SUFFIX ${HELP_TEXT_COLOR}everything after 'Aliases' tag value
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_SEE_ALSO_SUFFIX ${HELP_TEXT_COLOR}everything after 'See also' tag value
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_MORE_INFORMATION_SUFFIX ${HELP_TEXT_COLOR}everything after 'More information' tag value
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_INTERNAL_SUFFIX ${HELP_TEXT_COLOR}everything after 'Internal' tag value
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DEPRECATED_SUFFIX ${HELP_TEXT_COLOR}everything after 'Deprecated' tag value

    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DESCRIPTION_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before a command description
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_ALIASES_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before 'Aliases' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_SEE_ALSO_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before 'See also' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_MORE_INFORMATION_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before 'More information' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_INTERNAL_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before 'Internal' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DEPRECATED_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before 'Deprecated' tag value

    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DESCRIPTION_COLOR ${HELP_TEXT_COLOR}color for a command description
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_ALIASES_COLOR ${HELP_TEXT_COLOR}color for 'Aliases' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_SEE_ALSO_COLOR ${HELP_TEXT_COLOR}color for 'See also' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_MORE_INFORMATION_COLOR ${HELP_TEXT_COLOR}color for 'More information' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_INTERNAL_COLOR ${HELP_TEXT_COLOR}color for 'Internal' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DEPRECATED_COLOR ${HELP_TEXT_COLOR}color for 'Deprecated' tag value
    
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DESCRIPTION_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after a command description
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_ALIASES_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after 'Aliases' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_SEE_ALSO_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after 'See also' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_MORE_INFORMATION_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after 'More information' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_INTERNAL_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after 'Internal' tag value
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}SUMMARY_DEPRECATED_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after 'Deprecated' tag value

${HELP_HEADER_COLOR}  Code description:$HELP_TEXT_COLOR
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_PREFIX ${HELP_TEXT_COLOR}everything before a code description
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_SUFFIX ${HELP_TEXT_COLOR}everything after a code description

    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_COLOR ${HELP_TEXT_COLOR}color for a code description
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before a code description
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after a code description

${HELP_HEADER_COLOR}    Code description mnemonics:$HELP_TEXT_COLOR
      $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_MNEMONIC_PREFIX ${HELP_TEXT_COLOR}everything before a code description mnemonic
      $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_MNEMONIC_SUFFIX ${HELP_TEXT_COLOR}everything after a code description mnemonic

      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_MNEMONIC_COLOR ${HELP_TEXT_COLOR}color for a code description mnemonic
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_MNEMONIC_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before a code description mnemonic
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_MNEMONIC_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after a code description mnemonic

${HELP_HEADER_COLOR}    Code description I/O streams:$HELP_TEXT_COLOR
      $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_STREAM_PREFIX ${HELP_TEXT_COLOR}everything before a code description I/O stream
      $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_STREAM_SUFFIX ${HELP_TEXT_COLOR}everything after a code description I/O stream

      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_STREAM_COLOR ${HELP_TEXT_COLOR}color for a code description I/O stream
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_STREAM_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before a code description I/O stream
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_STREAM_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after a code description I/O stream

${HELP_HEADER_COLOR}  Code example:$HELP_TEXT_COLOR
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PREFIX ${HELP_TEXT_COLOR}everything before a code example
    $HELP_TEXT_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_SUFFIX ${HELP_TEXT_COLOR}everything after a code example

    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_COLOR ${HELP_TEXT_COLOR}color for a code example
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PREFIX_COLOR ${HELP_TEXT_COLOR}color for everything before a code example
    $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_SUFFIX_COLOR ${HELP_TEXT_COLOR}color for everything after a code example

${HELP_HEADER_COLOR}    Code example keyword:$HELP_TEXT_COLOR
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR ${HELP_TEXT_COLOR}color for a code example placeholder keyword which doesn't have any quantifier
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PLACEHOLDER_OPTIONAL_KEYWORD_COLOR ${HELP_TEXT_COLOR}color for a code example placeholder keyword which has '?' quantifier
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PLACEHOLDER_REPEATED_REQUIRED_KEYWORD_COLOR ${HELP_TEXT_COLOR}color for a code example placeholder keyword which has '+' quantifier
        or range quantifier with <from> greater than 0
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PLACEHOLDER_REPEATED_OPTIONAL_KEYWORD_COLOR ${HELP_TEXT_COLOR}color for a code example placeholder keyword which has '*' quantifier
        or range quantifier with <from> greater or equal to 0

${HELP_HEADER_COLOR}    Code example sample:$HELP_TEXT_COLOR
      $HELP_COLOR_ENVIRONMENT_VARIABLE_SIGN $HELP_PUNCTUATION_COLOR\$${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PLACEHOLDER_EXAMPLE_COLOR ${HELP_TEXT_COLOR}color for a code example placeholder sample

${HELP_HEADER_COLOR}Examples:$HELP_TEXT_COLOR
  * $program_name ${HELP_PLACEHOLDER_COLOR}sed$HELP_TEXT_COLOR view 'sed' command examples
    Cached version is used if it's already here.
  * $program_name ${HELP_PUNCTUATION_COLOR}($HELP_OPTION_COLOR--operating-system$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-os$HELP_PUNCTUATION_COLOR) ${HELP_PLACEHOLDER_COLOR}android$HELP_PUNCTUATION_COLOR ${HELP_PLACEHOLDER_COLOR}am$HELP_TEXT_COLOR view 'am' Android command examples
  * $program_name ${HELP_PUNCTUATION_COLOR}($HELP_OPTION_COLOR--update-page$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-up$HELP_PUNCTUATION_COLOR) ${HELP_PLACEHOLDER_COLOR}sed$HELP_TEXT_COLOR view the latest 'sed' command examples
  * ${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_MNEMONIC_PREFIX$HELP_TEXT_COLOR=[ ${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_DESCRIPTION_MNEMONIC_SUFFIX$HELP_TEXT_COLOR=] $program_name ${HELP_PLACEHOLDER_COLOR}mkdir$HELP_TEXT_COLOR view 'mkdir' command examples with TlDr-like mnemonics
  * ${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PLACEHOLDER_PREFIX$HELP_TEXT_COLOR= ${HELP_ENVIRONMENT_VARIABLE_COLOR}CODE_EXAMPLE_PLACEHOLDER_SUFFIX$HELP_TEXT_COLOR= $program_name ${HELP_PLACEHOLDER_COLOR}mkdir$HELP_TEXT_COLOR view 'mkdir' command examples with TlDr-like placeholders"
  
}

version() {
  echo "1.1" >&2
}

author() {
  echo "Emily Grace Seville" >&2
}

email() {
  echo "EmilySeville7cfg@gmail.com" >&2
}


# Page layout is already checked in `render` function.
# Empty lines are already removed.
header_awk_parsable_name() {
  declare page_content="$1"
  sed -nE '1 { s/^# +//; s/ +$//; p }' <<< "$page_content"
}

# Page layout is already checked in `render` function.
# Empty lines are already removed.
summary_awk_parsable_description() {
  declare page_content="$1"
  sed -nE '/^> [^:]+$/ { s/^> +//; s/ +$//; p }' <<< "$page_content"
}

# Page layout is already checked in `render` function.
# Empty lines are already removed.
summary_awk_parsable_tags() {
  declare page_content="$1"
  sed -nE '/^> .+:/ {
    s/^> +//
    s/ +$//
    s/: +/::/
    s/^(.+):/\L\1:/
    s/^more +information/more_information/
    s/^see +also/see_also/
    p
  }' <<< "$page_content"
}

# Page layout is already checked in `render` function.
# Empty lines are already removed.
examples_awk_parsable_example() {
  declare page_content="$1"
  declare -i example_number="$2"

  page_content="$(sed -E ':x; N; $! bx; s/\n- +([^\n]+) *:\n` *([^\n]+) *`/\n\1::\2\n/g' <<< "$page_content")"
  page_content="$(sed -nE '/^[#>]/!p' <<< "$page_content" | sed -n '/^$/!p')"

  # 10 is used as 2 auto generated examples can appear here
  (( example_number < 1 || example_number > 10 )) && return

  sed -n "${example_number}p" <<< "$page_content"
}

term_with_mnemonic() {
  declare term="$1"
  declare option="$2"

  option="$(sed -E 's/^-*//' <<< "$option")"
  sed -E "s/($option)/[\1]/" <<< "$term"
}

better_tldr_render() {
  declare page_content="$1"

  page_content="$(sed -nE '/^$/!p' <<< "$page_content")"

  declare command_name="$(header_awk_parsable_name "$page_content")"
  declare command_description="$(summary_awk_parsable_description "$page_content" | sed '1! s/^/  /')"

  echo -e "\e[${HEADER_COMMAND_PREFIX_COLOR}m$HEADER_COMMAND_PREFIX\e[${HEADER_COMMAND_COLOR}m$command_name\e[${HEADER_COMMAND_SUFFIX_COLOR}m$HEADER_COMMAND_SUFFIX"
  echo -e "\e[${SUMMARY_DESCRIPTION_PREFIX_COLOR}m$SUMMARY_DESCRIPTION_PREFIX\e[${SUMMARY_DESCRIPTION_COLOR}m$command_description\e[${SUMMARY_DESCRIPTION_SUFFIX_COLOR}m$SUMMARY_DESCRIPTION_SUFFIX"

  declare tags="$(summary_awk_parsable_tags "$page_content")"
  declare more_information_tag_value="$(sed -n 's/^more_information:://p'<<< "$tags")"
  declare help_tag_value="$(awk -F :: '/^help/ { print $2 }'<<< "$tags")"
  declare version_tag_value="$(awk -F :: '/^version/ { print $2 }'<<< "$tags")"
  declare internal_tag_value="$(awk -F :: '/^internal/ { print $2 }'<<< "$tags")"
  declare deprecated_tag_value="$(awk -F :: '/^deprecated/ { print $2 }'<<< "$tags")"
  declare see_also_tag_value="$(awk -F :: '/^see_also/ { print $2 }'<<< "$tags")"
  declare aliases_tag_value="$(awk -F :: '/^aliases/ { print $2 }'<<< "$tags")"

  declare internal_tag_message=""
  [[ "$internal_tag_value" == true ]] &&
    internal_tag_message="This command should not be called directly"

  declare deprecated_tag_message=""
  [[ "$deprecated_tag_value" == true ]] &&
    deprecated_tag_message="This command is deprecated and should not be used"

  declare printed_tags=""
  
  [[ -n "$see_also_tag_value" ]] &&
    printed_tags+="\e[${SUMMARY_SEE_ALSO_PREFIX_COLOR}m$SUMMARY_SEE_ALSO_PREFIX\e[${SUMMARY_SEE_ALSO_COLOR}m$see_also_tag_value\e[${SUMMARY_SEE_ALSO_SUFFIX_COLOR}m$SUMMARY_SEE_ALSO_SUFFIX\n"
  [[ -n "$aliases_tag_value" ]] &&
    printed_tags+="\e[${SUMMARY_ALIASES_PREFIX_COLOR}m$SUMMARY_ALIASES_PREFIX\e[${SUMMARY_ALIASES_COLOR}m$aliases_tag_value\e[${SUMMARY_ALIASES_SUFFIX_COLOR}m$SUMMARY_ALIASES_SUFFIX\n"
  [[ -n "$more_information_tag_value" ]] &&
    printed_tags+="\e[${SUMMARY_MORE_INFORMATION_PREFIX_COLOR}m$SUMMARY_MORE_INFORMATION_PREFIX\e[${SUMMARY_MORE_INFORMATION_COLOR}m$more_information_tag_value\e[${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR}m$SUMMARY_MORE_INFORMATION_SUFFIX\n"
  [[ -n "$internal_tag_message" ]] &&
    printed_tags+="\e[${SUMMARY_INTERNAL_PREFIX_COLOR}m$SUMMARY_INTERNAL_PREFIX\e[${SUMMARY_INTERNAL_COLOR}m$internal_tag_message\e[${SUMMARY_INTERNAL_SUFFIX_COLOR}m$SUMMARY_INTERNAL_SUFFIX\n"
  [[ -n "$deprecated_tag_message" ]] &&
    printed_tags+="\e[${SUMMARY_DEPRECATED_PREFIX_COLOR}m$SUMMARY_DEPRECATED_PREFIX\e[${SUMMARY_DEPRECATED_COLOR}m$deprecated_tag_message\e[${SUMMARY_DEPRECATED_SUFFIX_COLOR}m$SUMMARY_DEPRECATED_SUFFIX\n"
  
  printed_tags="$(sed -E ':x; N; $! bx; s/\n+/\n/g' <<< "$printed_tags")"
  echo -e "$printed_tags"

  [[ -n "$help_tag_value" ]] && {
    declare help_term="help"

    page_content="$page_content
- Display a $(term_with_mnemonic "$help_term" "$help_tag_value"):
\`$command_name $help_tag_value\`"
  }

  [[ -n "$version_tag_value" ]] && {
    declare version_term="version"

    page_content="$page_content
- Display a $(term_with_mnemonic "$version_term" "$version_tag_value"):
\`$command_name $version_tag_value\`"
  }

  for example_number in {1..10}; do
    declare example="$(examples_awk_parsable_example "$page_content" "$example_number")"
    [[ -z "$example" ]] && return
    declare description="$(awk -F :: '{ print $1 }'<<< "$example")"
    declare code="$(awk -F :: '{ print $2 }'<<< "$example")"

    declare -i index=0

    # colorizing mnemonics
    declare colorized_description=""

    while ((index < ${#description})); do
      declare string_between_mnemonics=""
      declare mnemonic=""
      declare is_last_mnemonic_closed=true

      while [[ "$index" -lt "${#description}" && "${description:index:1}" != "["  ]]; do
        declare character="${description:index:1}"
        declare next_character="${description:index + 1:1}"
        if [[ "$character" == "\\" && "$next_character" =~ \[|\] ]]; then
          index+=1
          string_between_mnemonics+="$next_character"
        else
          string_between_mnemonics+="$character"
        fi
        ((index++))
      done
      ((index++))
      while [[ "$index" -lt "${#description}" && "${description:index:1}" != "]" ]]; do
        declare character="${description:index:1}"
        declare next_character="${description:index + 1:1}"

        [[ "$character" =~ [\ /] ]] && {
          ((index--))
          break
        }

        if [[ "$character" == "\\" && "$next_character" =~ \[|\] ]]; then
          ((index++))
          mnemonic+="$next_character"
        else
          mnemonic+="$character"
        fi
        
        ((index++))
        
        if [[ "$index" -eq "${#description}" && "$character" != "]" ]]; then
          is_last_mnemonic_closed=false
        fi
      done
      ((index++))

      ((${#string_between_mnemonics} != 0)) && colorized_description+="\e[${CODE_DESCRIPTION_COLOR}m$string_between_mnemonics"
      ((${#mnemonic} != 0)) && {
        if [[ "$is_last_mnemonic_closed" == true ]]; then
          colorized_description+="\e[${CODE_DESCRIPTION_MNEMONIC_PREFIX_COLOR}m$CODE_DESCRIPTION_MNEMONIC_PREFIX\e[${CODE_DESCRIPTION_MNEMONIC_COLOR}m$mnemonic\e[${CODE_DESCRIPTION_MNEMONIC_SUFFIX_COLOR}m$CODE_DESCRIPTION_MNEMONIC_SUFFIX"
        else
          colorized_description+="$mnemonic"
        fi
      }
    done

    colorized_description="$(sed -E "s/\<(std(in|out|err))\>/\\\\e[${CODE_DESCRIPTION_STREAM_PREFIX_COLOR}m$CODE_DESCRIPTION_STREAM_PREFIX\\\\e[${CODE_DESCRIPTION_STREAM_COLOR}m\1\\\\e[${CODE_DESCRIPTION_STREAM_SUFFIX_COLOR}m$CODE_DESCRIPTION_STREAM_SUFFIX/g" <<< "$colorized_description")"

    echo -e "\e[${CODE_DESCRIPTION_MNEMONIC_PREFIX_COLOR}m$CODE_DESCRIPTION_PREFIX\e[${CODE_DESCRIPTION_COLOR}m$colorized_description\e[${CODE_DESCRIPTION_MNEMONIC_SUFFIX_COLOR}m$CODE_DESCRIPTION_SUFFIX"
  done

  return

  echo -e "$(sed -nE "
  /^\`/ {
    s/\`(.*)\`/\\\\e[${CODE_EXAMPLE_PREFIX_COLOR}m$CODE_EXAMPLE_PREFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m\1\\\\e[0m\n/


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
    p
  }" <<<"$page_content")"
}

tldr_render() {
  declare page_content="$1"
  
  page_content="$(sed -E '/^`/ {
    s/\{([^ {}]+ +[^{}:]+):[^{}]+\}/{\1}/g
  }' <<< "$page_content")"

  echo -e "$(sed -E "/^#/ {
    s/^# (.*)$/\\\\e[${HEADER_COMMAND_PREFIX_COLOR}m$HEADER_COMMAND_PREFIX\\\\e[${HEADER_COMMAND_COLOR}m\1\\\\e[${HEADER_COMMAND_SUFFIX_COLOR}m$HEADER_COMMAND_SUFFIX/
  }
  
  /^>/ {
    s/^> Aliases: (.*)$/\\\\e[${SUMMARY_ALIASES_PREFIX_COLOR}m$SUMMARY_ALIASES_PREFIX\\\\e[${SUMMARY_ALIASES_COLOR}m\1\\\\e[${SUMMARY_ALIASES_SUFFIX_COLOR}m$SUMMARY_ALIASES_SUFFIX/
    s/^> See also: (.*)$/\\\\e[${SUMMARY_SEE_ALSO_PREFIX_COLOR}m$SUMMARY_SEE_ALSO_PREFIX\\\\e[${SUMMARY_SEE_ALSO_COLOR}m\1\\\\e[${SUMMARY_SEE_ALSO_SUFFIX_COLOR}m$SUMMARY_SEE_ALSO_SUFFIX/
    s/^> More information: (.*)$/\\\\e[${SUMMARY_MORE_INFORMATION_PREFIX_COLOR}m$SUMMARY_MORE_INFORMATION_PREFIX\\\\e[${SUMMARY_MORE_INFORMATION_COLOR}m\1\\\\e[${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR}m$SUMMARY_MORE_INFORMATION_SUFFIX/
    /^> (Aliases|See also|More information|Help|Version|Internal|Deprecated):/! s/^> (.*)$/\\\\e[${SUMMARY_DESCRIPTION_PREFIX_COLOR}m$SUMMARY_DESCRIPTION_PREFIX\\\\e[${SUMMARY_DESCRIPTION_COLOR}m\1\\\\e[${SUMMARY_DESCRIPTION_SUFFIX_COLOR}m$SUMMARY_DESCRIPTION_SUFFIX/
  }

  /^- / {
    s/^- (.*):$/\\\\e[${CODE_DESCRIPTION_PREFIX_COLOR}m$CODE_DESCRIPTION_PREFIX\\\\e[${CODE_DESCRIPTION_COLOR}m\1\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m$CODE_DESCRIPTION_SUFFIX/
    s/\[([^ /]+)\]/\\\\e[${CODE_DESCRIPTION_MNEMONIC_PREFIX_COLOR}m$CODE_DESCRIPTION_MNEMONIC_PREFIX\\\\e[${CODE_DESCRIPTION_MNEMONIC_COLOR}m\1\\\\e[${CODE_DESCRIPTION_MNEMONIC_SUFFIX_COLOR}m$CODE_DESCRIPTION_MNEMONIC_SUFFIX\\\\e[${CODE_DESCRIPTION_COLOR}m/g
    s/\<(std(in|out|err))\>/\\\\e[${CODE_DESCRIPTION_STREAM_COLOR}m$CODE_DESCRIPTION_STREAM_PREFIX\1$CODE_DESCRIPTION_STREAM_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/
  }
  
  /^\`/ {
    s/\`(.*)\`/\\\\e[${CODE_EXAMPLE_PREFIX_COLOR}m$CODE_EXAMPLE_PREFIX\\\\e[${CODE_EXAMPLE_COLOR}m\1\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m$CODE_EXAMPLE_SUFFIX/

    # placeholders
    s/\{(bool|int|float|char|string|command|any)[?*+]? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g
    s/\{(file|directory|path)[?*+]? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g

    # broken placeholders
    s/\{[^ {}]+[^{}]*\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR}munsupported placeholder\\\\e[${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g
  }" <<<"$page_content")"
}

tldr_render_colorful() {
  declare page_content="$1"
  
  page_content="$(sed -E '/^`/ {
    s/\{([^ {}]+ +[^{}:]+):[^{}]+\}/{\1}/g
  }' <<< "$page_content")"

  echo -e "$(sed -E "/^#/ {
    s/^# (.*)$/\\\\e[${HEADER_COMMAND_PREFIX_COLOR}m$HEADER_COMMAND_PREFIX\\\\e[${HEADER_COMMAND_COLOR}m\1\\\\e[${HEADER_COMMAND_SUFFIX_COLOR}m$HEADER_COMMAND_SUFFIX/
  }
  
  /^>/ {
    s/^> Aliases: (.*)$/\\\\e[${SUMMARY_ALIASES_PREFIX_COLOR}m$SUMMARY_ALIASES_PREFIX\\\\e[${SUMMARY_ALIASES_COLOR}m\1\\\\e[${SUMMARY_ALIASES_SUFFIX_COLOR}m$SUMMARY_ALIASES_SUFFIX/
    s/^> See also: (.*)$/\\\\e[${SUMMARY_SEE_ALSO_PREFIX_COLOR}m$SUMMARY_SEE_ALSO_PREFIX\\\\e[${SUMMARY_SEE_ALSO_COLOR}m\1\\\\e[${SUMMARY_SEE_ALSO_SUFFIX_COLOR}m$SUMMARY_SEE_ALSO_SUFFIX/
    s/^> More information: (.*)$/\\\\e[${SUMMARY_MORE_INFORMATION_PREFIX_COLOR}m$SUMMARY_MORE_INFORMATION_PREFIX\\\\e[${SUMMARY_MORE_INFORMATION_COLOR}m\1\\\\e[${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR}m$SUMMARY_MORE_INFORMATION_SUFFIX/
    /^> (Aliases|See also|More information|Help|Version|Internal|Deprecated):/! s/^> (.*)$/\\\\e[${SUMMARY_DESCRIPTION_PREFIX_COLOR}m$SUMMARY_DESCRIPTION_PREFIX\\\\e[${SUMMARY_DESCRIPTION_COLOR}m\1\\\\e[${SUMMARY_DESCRIPTION_SUFFIX_COLOR}m$SUMMARY_DESCRIPTION_SUFFIX/
  }

  /^- / {
    s/^- (.*):$/\\\\e[${CODE_DESCRIPTION_PREFIX_COLOR}m$CODE_DESCRIPTION_PREFIX\\\\e[${CODE_DESCRIPTION_COLOR}m\1\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m$CODE_DESCRIPTION_SUFFIX/
    s/\[([^ /]+)\]/\\\\e[${CODE_DESCRIPTION_MNEMONIC_PREFIX_COLOR}m$CODE_DESCRIPTION_MNEMONIC_PREFIX\\\\e[${CODE_DESCRIPTION_MNEMONIC_COLOR}m\1\\\\e[${CODE_DESCRIPTION_MNEMONIC_SUFFIX_COLOR}m$CODE_DESCRIPTION_MNEMONIC_SUFFIX\\\\e[${CODE_DESCRIPTION_COLOR}m/g
    s/\<(std(in|out|err))\>/\\\\e[${CODE_DESCRIPTION_STREAM_COLOR}m$CODE_DESCRIPTION_STREAM_PREFIX\1$CODE_DESCRIPTION_STREAM_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/
  }
  
  /^\`/ {
    s/\`(.*)\`/\\\\e[${CODE_EXAMPLE_PREFIX_COLOR}m$CODE_EXAMPLE_PREFIX\\\\e[${CODE_EXAMPLE_COLOR}m\1\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m$CODE_EXAMPLE_SUFFIX/

    # placeholders without quantifiers
    s/\{(bool|int|float|char|string|command|any) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g
    s/\{(file|directory|path) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g

    # placeholders with '?' quantifier
    s/\{(bool|int|float|char|string|command|any)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_OPTIONAL_KEYWORD_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g
    s/\{(file|directory|path)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_OPTIONAL_KEYWORD_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g

    # placeholders with '+' quantifier
    s/\{(bool|int|float|char|string|command|any)\+ +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REPEATED_REQUIRED_KEYWORD_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g
    s/\{(file|directory|path)\+ +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REPEATED_REQUIRED_KEYWORD_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g

    # placeholders with '*' quantifier
    s/\{(bool|int|float|char|string|command|any)\* +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REPEATED_OPTIONAL_KEYWORD_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g
    s/\{(file|directory|path)\* +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REPEATED_OPTIONAL_KEYWORD_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g

    # broken placeholders
    s/\{[^ {}]+[^{}]*\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_PREFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_PLACEHOLDER_REQUIRED_KEYWORD_COLOR}munsupported placeholder\\\\e[${CODE_EXAMPLE_PLACEHOLDER_SUFFIX_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_COLOR}m/g
  }" <<<"$page_content")"

}

docopt_render() {
  declare page_content="$1"
  
  page_content="$(sed -E '/^`/ {
    s/\{([^ {}]+ +[^{}:]+):[^{}]+\}/{\1}/g
  }' <<< "$page_content")"

  echo -e "$(sed -E "/^#/ {
    s/^# (.*)$/\\\\e[${HEADER_COMMAND_PREFIX_COLOR}m$HEADER_COMMAND_PREFIX\\\\e[${HEADER_COMMAND_COLOR}m\1\\\\e[${HEADER_COMMAND_SUFFIX_COLOR}m$HEADER_COMMAND_SUFFIX/
  }
  
  /^>/ {
    s/^> Aliases: (.*)$/\\\\e[${SUMMARY_ALIASES_PREFIX_COLOR}m$SUMMARY_ALIASES_PREFIX\\\\e[${SUMMARY_ALIASES_SUFFIX_COLOR}m\1\\\\e[0m/
    s/^> See also: (.*)$/\\\\e[${SUMMARY_SEE_ALSO_PREFIX_COLOR}m$SUMMARY_SEE_ALSO_PREFIX\\\\e[${SUMMARY_SEE_ALSO_SUFFIX_COLOR}m\1\\\\e[0m/
    s/^> More information: (.*)$/\\\\e[${SUMMARY_MORE_INFORMATION_PREFIX_COLOR}m$SUMMARY_MORE_INFORMATION_PREFIX\\\\e[${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR}m\1\\\\e[0m/
    /^> (Aliases|See also|More information):/! s/^> (.*)$/\\\\e[${SUMMARY_DESCRIPTION_PREFIX_COLOR}m$SUMMARY_DESCRIPTION_PREFIX\\\\e[${SUMMARY_DESCRIPTION_SUFFIX_COLOR}m\1\\\\e[0m/
  }

  /^- / {
    s/\[([^ /]+)\]/\\\\e[${CODE_DESCRIPTION_MNEMONIC_COLOR}m$CODE_DESCRIPTION_MNEMONIC_PREFIX\1$CODE_DESCRIPTION_MNEMONIC_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/g
    s/^- (.*):$/\\\\e[${CODE_DESCRIPTION_PREFIX_COLOR}m$CODE_DESCRIPTION_PREFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m\1\\\\e[0m/
    s/\<(std(in|out|err))\>/\\\\e[${CODE_DESCRIPTION_STREAM_COLOR}m$CODE_DESCRIPTION_STREAM_PREFIX\1$CODE_DESCRIPTION_STREAM_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/
  }
  
  /^\`/ {
    s/\`(.*)\`/\\\\e[${CODE_EXAMPLE_PREFIX_COLOR}m$CODE_EXAMPLE_PREFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m\1\\\\e[0m/

    # placeholders without examples
    s/\{(bool|int|float|char|string|command|any) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g


    # placeholders without examples and with ? quantifier
    s/\{(bool|int|float|char|string|command|any)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}m[\2]\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}m[path\/to\/\2]\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g


    # placeholders without examples and with * or + quantifier
    s/\{(bool|int|float|char|string|command|any)[*+] +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}m\2...\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)[*+] +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}mpath\/to\/\2...\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g


    # broken placeholders
    s/\{[^ {}]+[^{}]*\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}munsupported placeholder\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
  }" <<<"$page_content")"
}

docopt_render_colorful() {
  declare page_content="$1"
  
  page_content="$(sed -E '/^`/ {
    s/\{([^ {}]+ +[^{}:]+):[^{}]+\}/{\1}/g
  }' <<< "$page_content")"

  echo -e "$(sed -E "/^#/ {
    s/^# (.*)$/\\\\e[${HEADER_COMMAND_PREFIX_COLOR}m$HEADER_COMMAND_PREFIX\\\\e[${HEADER_COMMAND_COLOR}m\1\\\\e[${HEADER_COMMAND_SUFFIX_COLOR}m$HEADER_COMMAND_SUFFIX/
  }
  
  /^>/ {
    s/^> Aliases: (.*)$/\\\\e[${SUMMARY_ALIASES_PREFIX_COLOR}m$SUMMARY_ALIASES_PREFIX\\\\e[${SUMMARY_ALIASES_SUFFIX_COLOR}m\1\\\\e[0m/
    s/^> See also: (.*)$/\\\\e[${SUMMARY_SEE_ALSO_PREFIX_COLOR}m$SUMMARY_SEE_ALSO_PREFIX\\\\e[${SUMMARY_SEE_ALSO_SUFFIX_COLOR}m\1\\\\e[0m/
    s/^> More information: (.*)$/\\\\e[${SUMMARY_MORE_INFORMATION_PREFIX_COLOR}m$SUMMARY_MORE_INFORMATION_PREFIX\\\\e[${SUMMARY_MORE_INFORMATION_SUFFIX_COLOR}m\1\\\\e[0m/
    /^> (Aliases|See also|More information):/! s/^> (.*)$/\\\\e[${SUMMARY_DESCRIPTION_PREFIX_COLOR}m$SUMMARY_DESCRIPTION_PREFIX\\\\e[${SUMMARY_DESCRIPTION_SUFFIX_COLOR}m\1\\\\e[0m/
  }

  /^- / {
    s/\[([^ /]+)\]/\\\\e[${CODE_DESCRIPTION_MNEMONIC_COLOR}m$CODE_DESCRIPTION_MNEMONIC_PREFIX\1$CODE_DESCRIPTION_MNEMONIC_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/g
    s/^- (.*):$/\\\\e[${CODE_DESCRIPTION_PREFIX_COLOR}m$CODE_DESCRIPTION_PREFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m\1\\\\e[0m/
    s/\<(std(in|out|err))\>/\\\\e[${CODE_DESCRIPTION_STREAM_COLOR}m$CODE_DESCRIPTION_STREAM_PREFIX\1$CODE_DESCRIPTION_STREAM_SUFFIX\\\\e[${CODE_DESCRIPTION_SUFFIX_COLOR}m/
  }
  
  /^\`/ {
    s/\`(.*)\`/\\\\e[${CODE_EXAMPLE_PREFIX_COLOR}m$CODE_EXAMPLE_PREFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m\1\\\\e[0m/

    # placeholders without examples and without quantifiers
    s/\{(bool|int|float|char|string|command|any) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}m\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path) +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REQUIRED_PLACEHOLDER_COLOR}mpath\/to\/\2\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
  
    # placeholders without examples and with ? quantifier
    s/\{(bool|int|float|char|string|command|any)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_OPTIONAL_PLACEHOLDER_COLOR}m[\2]\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\? +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_OPTIONAL_PLACEHOLDER_COLOR}m[path\/to\/\2]\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # placeholders without examples and with * quantifier
    s/\{(bool|int|float|char|string|command|any)\* +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REPEATED_ZERO_OR_MORE_PLACEHOLDER_COLOR}m\2...\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\* +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REPEATED_ZERO_OR_MORE_PLACEHOLDER_COLOR}mpath\/to\/\2...\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # placeholders without examples and with + quantifier
    s/\{(bool|int|float|char|string|command|any)\+ +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REPEATED_ONE_OR_MORE_PLACEHOLDER_COLOR}m\2...\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
    s/\{(file|directory|path)\+ +([^{}:]+)\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_TLDR_REPEATED_ONE_OR_MORE_PLACEHOLDER_COLOR}mpath\/to\/\2...\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g

    # broken placeholders
    s/\{[^ {}]+[^{}]*\}/\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_PREFIX\\\\e[${CODE_EXAMPLE_REQUIRED_PLACEHOLDER_CONTENT_COLOR}munsupported placeholder\\\\e[${CODE_EXAMPLE_PLACEHOLDER_COLOR}m$CODE_EXAMPLE_PLACEHOLDER_SUFFIX\\\\e[${CODE_EXAMPLE_SUFFIX_COLOR}m/g
  }" <<<"$page_content")"
}

is_layout_valid() {
  declare page_content="$1"

  sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$page_content"
}

render() {
  declare page_file="$1"
  declare render="$2"
  declare page_content="$(cat "$page_file")

"

  is_layout_valid "$page_content" || {
    echo -e "$0: $page_file: ${ERROR_COLOR}valid page layout expected$RESET_COLOR" >&2
    return "$FAIL"
  }

  case "$render" in
    better-tldr)
      better_tldr_render "$page_content"
      ;;
    tldr)
      tldr_render "$page_content"
      ;;
    tldr-colorful)
      tldr_render_colorful "$page_content"
      ;;
    docopt)
      docopt_render "$page_content"
      ;;
    docopt-colorful)
      docopt_render_colorful "$page_content"
      ;;
  esac
}

if (($# == 0)); then
  help
  exit "$SUCCESS"
fi

declare operating_system=common
declare render=better-tldr
declare -i update_cache=1

while [[ -n "$1" ]]; do
  declare option="$1"
  declare value="$2"

  case "$option" in
  --help | -h)
    help
    exit "$SUCCESS"
    ;;
  --version | -v)
    version
    exit "$SUCCESS"
    ;;
  --author | -a)
    author
    exit "$SUCCESS"
    ;;
  --email | -e)
    email
    exit "$SUCCESS"
    ;;
  --operating-system | -os)
    [[ -z "$value" ]] && {
        echo -e "$0: $option: ${ERROR_COLOR}option value expected$RESET_COLOR" >&2
        exit "$FAIL"
    }
    operating_system="$value"
    shift 2
    ;;
  --render | -r)
    [[ -z "$value" ]] && {
        echo -e "$0: $option: ${ERROR_COLOR}option value expected$RESET_COLOR" >&2
        exit "$FAIL"
    }
    [[ "$value" =~ ^(tldr|tldr-colorful|docopt|docopt-colorful)$ ]] || {
        echo -e "$0: $option: ${ERROR_COLOR}valid option value expected$RESET_COLOR" >&2
        exit "$FAIL"
    }
    render="$value"

    case "$render" in
      tldr*)
        HEADER_COMMAND_PREFIX=""
        HEADER_COMMAND_SUFFIX=""
        
        SUMMARY_DESCRIPTION_PREFIX=""
        SUMMARY_DESCRIPTION_SUFFIX=""

        SUMMARY_SEE_ALSO_PREFIX="See also: "
        SUMMARY_SEE_ALSO_SUFFIX=""

        SUMMARY_ALIASES_PREFIX="Aliases: "
        SUMMARY_ALIASES_SUFFIX=""

        SUMMARY_MORE_INFORMATION_PREFIX="More information: "
        SUMMARY_MORE_INFORMATION_SUFFIX=""

        CODE_DESCRIPTION_PREFIX="- "
        CODE_DESCRIPTION_SUFFIX=""

        CODE_EXAMPLE_PREFIX="  "
        CODE_EXAMPLE_SUFFIX=""

        CODE_DESCRIPTION_MNEMONIC_PREFIX="["
        CODE_DESCRIPTION_MNEMONIC_SUFFIX="]"

        CODE_EXAMPLE_PLACEHOLDER_PREFIX=""
        CODE_EXAMPLE_PLACEHOLDER_SUFFIX=""
        ;;
      docopt*)
        HEADER_COMMAND_PREFIX=""
        HEADER_COMMAND_SUFFIX=""
        
        CODE_EXAMPLE_PLACEHOLDER_PREFIX="<"
        CODE_EXAMPLE_PLACEHOLDER_SUFFIX=">"

        CODE_DESCRIPTION_PREFIX="- "
        CODE_DESCRIPTION_MNEMONIC_PREFIX="["
        CODE_DESCRIPTION_MNEMONIC_SUFFIX="]"

        CODE_EXAMPLE_PREFIX="  "
        ;;
    esac

    shift 2
    ;;
  --clear-cache | -cc)
    rm -rf "$CACHE_DIRECTORY/$page_path"
    exit "$SUCCESS"
    ;;
  --update-page | -up)
    update_cache=0
    shift
    ;;
  *)
    declare local_file_or_remote_page="$option"
    declare is_local=1

    file_to_render="$(mktemp "/tmp/clip-XXXXXX")"
    [[ "$local_file_or_remote_page" =~ .clip$ ]] && is_local=0

    declare file_to_render
    if ((is_local == 0)); then
      [[ -f "$local_file_or_remote_page" ]] || {
        echo -e "$0: $page_file: ${ERROR_COLOR}existing page expected$RESET_COLOR" >&2
        exit "$FAIL"
      }
      cat "$local_file_or_remote_page" > "$file_to_render"
    else
      declare page_path="$operating_system/$local_file_or_remote_page.clip"

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

    render "$file_to_render" "$render" || {
      rm "$file_to_render"
      exit "$FAIL"
    }
    rm "$file_to_render"

    declare next_argument="$2"
    [[ -n "$next_argument" ]] && [[ ! "$next_argument" =~ --?.+ ]] && { 
      echo
      printf "%.0s- " {1..10}
      echo
      echo
    }

    shift
    ;;
  esac
done

exit "$SUCCESS"
