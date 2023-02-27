#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i FAIL=1

declare -i INVALID_LAYOUT_FAIL=1
declare -i INVALID_SUMMARY_FAIL=10
declare -i INVALID_TAG_FAIL=11
declare -i INVALID_TAG_VALUE_FAIL=12
declare -i INVALID_EXAMPLE_INDEX_FAIL=20
declare -i INVALID_CONSTRUCT_FAIL=30

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
    declare in_source="$1"
    declare in_message="$2"

    echo -e "$PARSER_ERROR_PREFIX: $in_source: ${SUCCESS_COLOR}$in_message$RESET_COLOR" >&2
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
    declare in_source="$1"
    declare in_message="$2"

    echo -e "$PARSER_ERROR_PREFIX: $in_source: ${ERROR_COLOR}$in_message$RESET_COLOR" >&2
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
    declare in_page_content="$1"

    # shellcheck disable=2016
    sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$in_page_content"$'\n\n'
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
    declare in_page_content="$1"

    __parser_check_layout_correctness "$in_page_content" || return "$INVALID_LAYOUT_FAIL"

    sed -nE '1 { s/^# +//; s/ +$//; s/ +/ /g; p; }' <<<"$in_page_content"
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
    declare in_page_summary="$1"

    # shellcheck disable=2016
    sed -nE ':x; N; $! bx; /^(> [^\n:]+\n){1,2}(> [^\n:]+:[^\n]+\n)+$/! Q1' <<<"$in_page_summary"$'\n'
}

# parser_output_command_description <page-content>
# Output command description from a page content.
#
# Output:
#   <command-description>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_description() {
    declare in_page_content="$1"

    __parser_check_layout_correctness "$in_page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2155
    declare command_summary="$(sed -nE '/^>/ p' <<<"$in_page_content")"
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
    declare in_command_tag="$1"

    [[ "$in_command_tag" =~ ^(More information|Internal|Deprecated|See also|Aliases|Syntax compatible|Help|Version|Structure compatible)$ ]]
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
    declare in_command_tag="$1"
    declare in_command_tag_value="$2"

    if [[ "$in_command_tag" =~ ^(Internal|Deprecated)$ ]]; then
        [[ "$in_command_tag_value" =~ ^(true|false)$ ]]
    elif [[ "$in_command_tag" =~ ^(See also|Aliases|Syntax compatible|Structure compatible)$ ]]; then
        ! [[ "$in_command_tag_value" =~ ,, ]]
    else
        [[ "$in_command_tag" =~ ^(More information|Help|Version)$ ]]
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
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 11 if command tag is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
__parser_output_command_tags() {
    declare in_page_content="$1"

    __parser_check_layout_correctness "$in_page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2155
    declare command_summary="$(sed -nE '/^>/ p' <<<"$in_page_content")"
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
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 11 if command tag is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
__parser_output_command_tag_value() {
    declare in_page_content="$1"
    declare in_command_tag="$2"

    __parser_check_command_tag_correctness "$in_command_tag" || return "$INVALID_TAG_FAIL"

    declare output=
    output="$(__parser_output_command_tags "$in_page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"
    mapfile -t command_tags <<< "$output"

    declare -i index=0
    while ((index < "${#command_tags[@]}")); do
        declare tag="${command_tags[index]}"
        declare value="${command_tags[index + 1]}"
        
        [[ "$tag" == "$in_command_tag" ]] && {
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
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_more_information_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "More information"
}

# parser_output_command_internal_tag <page-content>
# Output "Internal" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_internal_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "Internal"
}

# parser_output_command_internal_tag_or_default <page-content>
# Output "Internal" tag from a page content or it's default when it's missing.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_internal_tag_value_or_default() {
    declare in_page_content="$1"

    declare output=
    output="$(parser_output_command_internal_tag_value "$in_page_content")"
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
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_deprecated_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "Deprecated"
}

# parser_output_command_deprecated_tag_or_default <page-content>
# Output "Deprecated" tag from a page content or it's default when it's missing.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_deprecated_tag_value_or_default() {
    declare in_page_content="$1"

    declare output=
    output="$(parser_output_command_deprecated_tag_value "$in_page_content")"
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
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_see_also_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "See also"
}

# parser_output_command_aliases_tag <page-content>
# Output "Aliases" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_aliases_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "Aliases"
}

# parser_output_command_syntax_compatible_tag <page-content>
# Output "Syntax compatible" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_syntax_compatible_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "Syntax compatible"
}

# parser_output_command_help_tag <page-content>
# Output "Help" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_help_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "Help"
}

# parser_output_command_version_tag <page-content>
# Output "Version" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_version_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "Version"
}

# parser_output_command_structure_compatible_tag <page-content>
# Output "Structure compatible" tag from a page content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if page layout, command summary is valid
#   - 1 if page layout is invalid
#   - 10 if command summary is invalid
#   - 12 if tag value is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_structure_compatible_tag_value() {
    declare in_page_content="$1"

    __parser_output_command_tag_value "$in_page_content" "Structure compatible"
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
    declare in_page_content="$1"

    __parser_check_layout_correctness "$in_page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2016
    sed -nE '/^[-`]/ { s/^- +//; s/ *:$//; s/^` *//; s/ *`$//; p; }' <<<"$in_page_content"
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
    declare in_page_content="$1"

    declare examples=
    examples="$(__parser_output_command_examples "$in_page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    # shellcheck disable=2155
    declare -i count="$(echo "$examples" | wc -l)"
    ((count % 2 == 0)) || count+=1

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
#   - 1 if page layout is invalid
#   - 20 if index is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_example_description() {
    declare in_page_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare examples=
    examples="$(__parser_output_command_examples "$in_page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    # shellcheck disable=2155
    declare -i count="$(__parser_output_command_example_count "$in_page_content")"
    ((in_index >= count)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    sed -nE "$((in_index * 2 + 1)) p" <<<"$examples"
}

# parser_output_command_example_code <page-content> <index>
# Output command example code from a page content.
#
# Output:
#   <command-example-code>
#
# Return:
#   - 0 if page layout, index is valid
#   - 1 if page layout is invalid
#   - 20 if index is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_example_code() {
    declare in_page_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare examples=
    examples="$(__parser_output_command_examples "$in_page_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    # shellcheck disable=2155
    declare -i count="$(__parser_output_command_example_count "$in_page_content")"
    ((in_index >= count)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    sed -nE "$((in_index * 2 + 2)) p" <<<"$examples"
}

# __parser_output_current_token <string> <index> <next-token-start>
# Output current token from a string.
#
# Output:
#   <string-token>
#
# Return:
#   - index after traversal
__parser_output_current_token() {
    declare in_string="$1"
    declare -i in_index="$2"
    declare in_next_token_start="${3:0:1}"

    declare current_token=

    while ((in_index < ${#in_string})) && [[ "${in_string:in_index:1}" != "$in_next_token_start" ]]; do
        [[ "${in_string:in_index:1}" == \\ ]] && in_index+=1

        current_token+="${in_string:in_index:1}"
        in_index+=1
    done

    echo -n "$current_token"

    return "$in_index"
}

# __parser_output_tokenized_by_balanced_tokens <string> <special-construct-start-and-end>
# Output tokens from a string.
#
# Output:
#   <string-tokens>
#
# Return:
#   - 0 if string is valid
#   - 1 otherwise
#
# Notes:
#   - string without trailing \n
#   - token types:
#     - LITERAL
#     - CONSTRUCT
#   - token type precedes token value (which may be missing if token doesn't contain value)
#   - nested contructs are unsupported
__parser_output_tokenized_by_balanced_tokens() {
    declare in_string="$1"
    declare in_construct_delimiters="${2:0:2}"

    declare -i index=0
    declare construct_start="${in_construct_delimiters:0:1}"
    declare construct_end="${in_construct_delimiters:1:1}"

    while ((index < ${#in_string})); do
        declare literal_token=
        literal_token="$(__parser_output_current_token "$in_string" "$index" "$construct_start")"
        index="$?"

        printf "%s\n%s\n" LITERAL "$literal_token"
        index+=1

        declare construct_token=
        construct_token="$(__parser_output_current_token "$in_string" "$index" "$construct_end")"
        index="$?"

        [[ -n "$construct_token" ]] && {
            [[ "${in_string:index:1}" != "$construct_end" ]] && return "$INVALID_CONSTRUCT_FAIL"
            printf "%s\n%s\n" CONSTRUCT "$construct_token"
        }
        index+=1
    done
}

# __parser_output_tokenized_by_unbalanced_tokens <string> <special-construct>
# Output tokens from a string.
#
# Output:
#   <string-tokens>
#
# Return:
#   - 0 if string is valid
#   - 1 otherwise
#
# Notes:
#   - string without trailing \n
#   - token types:
#     - LITERAL
#     - CONSTRUCT
#   - token type precedes token value (which may be missing if token doesn't contain value)
__parser_output_tokenized_by_unbalanced_tokens() {
    declare in_string="$1"
    declare in_construct_delimiter="${2:0:1}"

    declare -i index=0

    while ((index < ${#in_string})); do
        declare literal_token=
        literal_token="$(__parser_output_current_token "$in_string" "$index" "$in_construct_delimiter")"
        index="$?"

        [[ -n "$literal_token" ]] && printf "%s\n%s\n" CONSTRUCT "$literal_token"
        index+=1
    done
}

# __parser_output_token_count <tokens>
# Output token count from a token list.
#
# Output:
#   <token-count>
#
# Return:
#   - 0 always
__parser_output_token_count() {
    declare in_tokens="$1"

    # shellcheck disable=2155
    declare -i count="$(echo -n "$in_tokens" | wc -l)"
    ((count % 2 == 0)) || count+=1

    echo -n "$((count / 2))"
}

# __parser_output_token_value <tokens> <index>
# Output token value from a token list.
#
# Output:
#   <token-value>
#
# Return:
#   - 0 always
__parser_output_token_value() {
    declare in_tokens="$1"
    declare in_index="$2"

    # shellcheck disable=2155
    declare count="$(__parser_output_token_count "$in_tokens")"
    declare -i line=0
    declare -i current_index=0

    mapfile -t tokens <<<"$in_tokens"

    while ((line < count * 2)) && ((current_index != in_index)); do
        line+=2
        current_index+=1
    done

    [[ -n "${tokens[line + 1]}" ]] && echo -n "${tokens[line + 1]}"
}

# __parser_output_token_type <tokens> <index>
# Output token type from a token list.
#
# Output:
#   <token-type>
#
# Return:
#   - 0 always
__parser_output_token_type() {
    declare in_tokens="$1"
    declare in_index="$2"

    # shellcheck disable=2155
    declare count="$(__parser_output_token_count "$in_tokens")"
    declare -i line=0
    declare -i current_index=0

    mapfile -t tokens <<<"$in_tokens"

    while ((line < count * 2)) && ((current_index != in_index)); do
        line+=2
        current_index+=1
    done

    [[ -n "${tokens[line]}" ]] && echo -n "${tokens[line]}"
}

# parser_output_command_example_description_tokens <page-content> <index>
# Output command example description tokens for alternatives and literals from a page content.
#
# Output:
#   <command-example-description>
#
# Return:
#   - 0 if page layout, index is valid
#   - 1 if page layout is invalid
#   - 20 if index is invalid
#
# Notes:
#   - .clip page content without trailing \n
#   - alternative parsing is the first parsing stage
#   - mnemonics are considered to be nested inside alternatives or literals
parser_output_command_example_description_tokens() {
    declare in_page_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare description=
    description="$(parser_output_command_example_description "$in_page_content" "$in_index")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    declare tokens=
    tokens="$(__parser_output_tokenized_by_balanced_tokens "$description" "()")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    echo -n "$tokens"
}

# parser_output_command_example_description_mnemonic_tokens <page-content> <index>
# Output command example description tokens for mnemonics and literals from a page content.
#
# Output:
#   <command-example-description>
#
# Return:
#   - 0 if page layout, index is valid
#   - 1 if page layout is invalid
#   - 20 if index is invalid
#
# Notes:
#   - .clip page content without trailing \n
#   - mnemonic parsing is the second parsing stage
#   - alternatives should be already expanded before parsing mnemonics
parser_output_command_example_description_mnemonic_tokens() {
    declare in_page_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare description=
    description="$(parser_output_command_example_description "$in_page_content" "$in_index")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    declare tokens=
    tokens="$(__parser_output_tokenized_by_balanced_tokens "$description" "[]")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    echo -n "$tokens"
}

# parser_output_command_example_description_alternative_tokens <alternative>
# Output tokens from an alternative.
#
# Output:
#   <alternative-tokens>
#
# Return:
#   - 0 if page layout, index is valid
#   - 1 if page layout is invalid
#   - 20 if index is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_example_description_alternative_tokens() {
    declare in_alternative="$1"

    __parser_output_tokenized_by_unbalanced_tokens "$in_alternative" "|"
}