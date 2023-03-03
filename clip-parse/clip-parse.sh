#!/usr/bin/env bash

declare -i SUCCESS=0

# Page validation fails
declare -i INVALID_LAYOUT_FAIL=1

# Summary validation fails
declare -i INVALID_SUMMARY_FAIL=10
declare -i INVALID_TAG_FAIL=11
declare -i INVALID_TAG_VALUE_FAIL=12

# Example validation fails
declare -i INVALID_EXAMPLE_INDEX_FAIL=20
declare -i INVALID_CONSTRUCT_FAIL=21
declare -i INVALID_TOKEN_INDEX_FAIL=22
declare -i INVALID_TOKEN_VALUE_FAIL=23
declare -i INVALID_PLACEHOLDER_ALTERNATIVE_FAIL=24
declare -i INVALID_PLACEHOLDER_ALTERNATIVE_REPETITION_NOT_ALLOWED=25



declare -i PARSER_INVALID_CONTENT_CODE=1
declare -i PARSER_INVALID_SUMMARY_CODE=2
declare -i PARSER_INVALID_EXAMPLES_CODE=3
declare -i PARSER_INVALID_TOKENS_CODE=4



# __parser_string_join <separator> <strings>
# Output joined strings.
#
# Output:
#   <strings>
#
# Return:
#   - 0 always
#
# Notes:
#   - <string> should not contain trailing \n
__parser_string_join() {
  declare in_separator="$1"
  declare in_string="$2"

  if shift 2; then
    printf '%s' "$in_string" "${@/#/$in_separator}"
  fi
}

# __parser_string_unify <string>
# Output string without repeated comma-separated items.
#
# Output:
#   <string>
#
# Return:
#   - 0 always
#
# Notes:
#   - <string> should not contain trailing \n
__parser_string_unify() {
    declare string="$1"

    mapfile -t string_array < <(echo -n "$string" | sed -E 's/ +/ /g
    s/ *, */\n/g' | sort -r -u)

    __parser_string_join ", " "${string_array[@]}"
}



# __parser_check_content <content>
# Check whether a content is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <content> is valid
#   - $PARSER_INVALID_CONTENT_CODE otherwise
#
# Notes:
#   - <content> should not contain trailing \n
__parser_check_content() {
    declare in_content="$1"

    # shellcheck disable=2016
    sed -nE ':x
        N
        $! bx
        /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$in_content"$'\n\n' ||
        return "$PARSER_INVALID_CONTENT_CODE"
}

# parser_header <content>
# Output a header from a content.
#
# Output:
#   <header>
#
# Return:
#   - 0 if <content> is valid
#   - $PARSER_INVALID_CONTENT_CODE otherwise
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_header() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_content "$in_content" || return "$PARSER_INVALID_CONTENT_CODE"
    fi

    sed -nE '1 {
        s/^# +//
        s/ +$//
        s/ +/ /g
        p
    }' <<<"$in_content"
}



# __parser_check_summary <summary>
# Check whether a summary is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <summary> is valid
#   - $PARSER_INVALID_SUMMARY_CODE otherwise
#
# Notes:
#   - <summary> should not contain trailing \n
__parser_check_summary() {
    declare in_summary="$1"

    # shellcheck disable=2016
    sed -nE ':x
        N
        $! bx
        /^(> [^\n:]+\n){1,2}(> [^\n:]+:[^\n]+\n)+$/! Q1' <<<"$in_summary"$'\n' ||
        return "$PARSER_INVALID_SUMMARY_CODE"
}

# parser_summary_description <content>
# Output a description from a summary.
#
# Output:
#   <description>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_description() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_content "$in_content" || return "$?"
    fi
    
    # shellcheck disable=2155
    declare summary="$(sed -nE '/^>/ p' <<<"$in_content")"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_summary "$summary" || return "$?"
    fi

    sed -nE '/^> [^:]+$/ {
        s/^> +//
        s/\.$//
        s/ +$//
        s/  +/ /g
        p
    }' <<<"$summary"
}

# __parser_check_summary_tag <tag>
# Check whether a tag is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <tag> is valid
#   - $PARSER_INVALID_SUMMARY_CODE otherwise
#
# Notes:
#   - <tag> should not contain trailing \n
__parser_check_summary_tag() {
    declare in_tag="$1"

    [[ "$in_tag" =~ ^(More information|Internal|Deprecated|See also|Aliases\
|Syntax compatible|Help|Version|Structure compatible)$ ]] ||
        return "$PARSER_INVALID_SUMMARY_CODE"
}

# __parser_check_summary_tag_value <tag> <tag-value>
# Check whether a tag value is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <tag-value> is valid
#   - $PARSER_INVALID_SUMMARY_CODE otherwise
#
# Notes:
#   - <tag> and <tag-value> should not contain trailing \n
__parser_check_summary_tag_value() {
    declare in_tag="$1"
    declare in_tag_value="$2"

    if [[ "$in_tag" =~ ^(Internal|Deprecated)$ ]]; then
        [[ "$in_tag_value" =~ ^(true|false)$ ]] || return "$PARSER_INVALID_SUMMARY_CODE"
    elif [[ "$in_tag" =~ ^(See also|Aliases|Syntax compatible|Structure compatible|Help|Version)$ ]]; then
        ! [[ "$in_tag_value" =~ ,, ]] || return "$PARSER_INVALID_SUMMARY_CODE"
    fi
}

# __parser_check_summary_tags_values <tags>
# Check whether tag values are valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <tag-value> is valid
#   - $PARSER_INVALID_SUMMARY_CODE otherwise
#
# Notes:
#   - <tag> and <tag-value> should not contain trailing \n
__parser_check_summary_tags_values() {
    declare in_tags="$1"

    mapfile -t tags_array <<<"$in_tags"

    declare -i index=0
    while ((index < "${#tags_array[@]}")); do
        declare tag="${tags_array[index]}"
        declare tag_value="${tags_array[index + 1]}"
        
        if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
            __parser_check_summary_tag "$tag" || return "$?"
            __parser_check_summary_tag_value "$tag" "$tag_value" || return "$?"
        fi
        index+=2
    done
}

# __parser_summary_tags <content>
# Output all tags from a summary.
#
# Output:
#   <tags>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
__parser_summary_tags() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_content "$in_content" || return "$?"
    fi
    
    # shellcheck disable=2155
    declare summary="$(sed -nE '/^>/ p' <<<"$in_content")"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_summary "$summary" || return "$?"
    fi

    # shellcheck disable=2155
    declare tags="$(sed -nE '/^> [^:]+:.+$/ {
        s/^> +//
        s/\.$//
        s/ +$//
        s/ +:$//
        s/ +/ /g
        s/: +/\n/
        p
    }' <<<"$summary")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_summary_tags_values "$tags" || return "$?"
    fi

    echo -n "$tags"
}

# __parser_summary_tag_value <content> <tag>
# Output a tag value from a summary.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
__parser_summary_tag_value() {
    declare in_content="$1"
    # shellcheck disable=2155
    declare in_tag="$(sed -E 's/^ +//
        s/ +$//
        s/ +/ /g' <<<"$2")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_summary_tag "$in_tag" || return "$?"
    fi

    declare tags=
    tags="$(__parser_summary_tags "$in_content")"
    declare -i status=$?
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$?"
    fi

    mapfile -t tags_array <<< "$tags"

    declare -i index=0
    while ((index < "${#tags_array[@]}")); do
        declare tag="${tags_array[index]}"
        declare value="${tags_array[index + 1]}"
        
        [[ "$tag" == "$in_tag" ]] && {
            echo -n "$value"
            return "$SUCCESS"
        }

        index+=2
    done
}

# parser_summary_more_information_value <content>
# Output "More information" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_more_information_value() {
    declare in_content="$1"

    __parser_summary_tag_value "$in_content" "More information"
}

# parser_summary_internal_value <content>
# Output "Internal" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_internal_value() {
    declare in_content="$1"

    __parser_summary_tag_value "$in_content" "Internal"
}

# parser_summary_internal_value_or_default <content>
# Output "Internal" tag value from a content or default.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_internal_value_or_default() {
    declare in_content="$1"

    declare tag_value=
    tag_value="$(parser_summary_internal_value "$in_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    [[ -z "$tag_value" ]] && tag_value=false
    echo -n "$tag_value"
}

# parser_summary_deprecated_value <content>
# Output "Deprecated" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_deprecated_value() {
    declare in_content="$1"

    __parser_summary_tag_value "$in_content" "Deprecated"
}

# parser_summary_deprecated_value_or_default <content>
# Output "Deprecated" tag value from a content or default.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_deprecated_value_or_default() {
    declare in_content="$1"

    declare output=
    output="$(parser_summary_deprecated_value "$in_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    [[ -z "$output" ]] && output=false
    echo -n "$output"
}

# parser_summary_see_also_value <content>
# Output "See also" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_see_also_value() {
    declare in_content="$1"

    echo -n "$(__parser_string_unify "$(__parser_summary_tag_value "$in_content" "See also")")"
}

# parser_summary_aliases_value <content>
# Output "Aliases" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_aliases_value() {
    declare in_content="$1"

    echo -n "$(__parser_string_unify "$(__parser_summary_tag_value "$in_content" "Aliases")")"
}

# parser_summary_syntax_compatible_value <content>
# Output "Syntax compatible" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_syntax_compatible_value() {
    declare in_content="$1"

    echo -n "$(__parser_string_unify "$(__parser_summary_tag_value "$in_content" "Syntax compatible")")"
}

# parser_summary_help_value <content>
# Output "Help" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_help_value() {
    declare in_content="$1"

    echo -n "$(__parser_string_unify "$(__parser_summary_tag_value "$in_content" "Help")")"
}

# parser_summary_version_value <content>
# Output "Version" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_version_value() {
    declare in_content="$1"

    echo -n "$(__parser_string_unify "$(__parser_summary_tag_value "$in_content" "Version")")"
}

# parser_summary_structure_compatible_value <content>
# Output "Structure compatible" tag value from a content.
#
# Output:
#   <tag-value>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_structure_compatible_value() {
    declare in_page_content="$1"

    echo -n "$(__parser_string_unify "$(__parser_summary_tag_value "$in_content" "Structure compatible")")"
}

# __parser_summary_tag_definition <tag> <tag-value>
# Output a tag definition.
#
# Output:
#   <tag-definition>
#
# Return:
#   - 0 always
#
# Notes:
#   - <tag> and <tag-value> should not contain trailing \n
__parser_summary_tag_definition() {
    declare in_tag="$1"
    declare in_tag_value="$2"

    [[ -z "$in_tag" || -z "$in_tag_value" ]] && return "$SUCCESS"

    [[ "$in_tag" =~ ^(Internal|Deprecated)$ && "$in_tag_value" == false ]] && return "$SUCCESS"

    echo -n "> $in_tag: $in_tag_value"
}

# parser_summary_cleaned_up <content>
# Output summary with sorted tags and applied spacing and punctuation fixes.
#
# Output:
#   <summary>
#
# Return:
#   - 0 if <content> and it's summary are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_SUMMARY_CODE if <content> summary is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_summary_cleaned_up() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_summary_tags "$in_content" > /dev/null || return "$PARSER_INVALID_SUMMARY_CODE"
    fi

    CHECK= # as we already checked input there is no need to do it in each data request

    # shellcheck disable=2155
    declare description="$(parser_summary_description "$in_content")"
    # shellcheck disable=2155
    declare more_information="$(parser_summary_more_information_value "$in_content")"
    # shellcheck disable=2155
    declare internal="$(parser_summary_internal_value_or_default "$in_content")"
    # shellcheck disable=2155
    declare deprecated="$(parser_summary_deprecated_value_or_default "$in_content")"
    # shellcheck disable=2155
    declare see_also="$(parser_summary_see_also_value "$in_content")"
    # shellcheck disable=2155
    declare aliases="$(parser_summary_aliases_value "$in_content")"
    # shellcheck disable=2155
    declare syntax_compatible="$(parser_summary_syntax_compatible_value "$in_content")"
    # shellcheck disable=2155
    declare help="$(parser_summary_help_value "$in_content")"
    # shellcheck disable=2155
    declare version="$(parser_summary_version_value "$in_content")"
    # shellcheck disable=2155
    declare structure_compatible="$(parser_summary_structure_compatible_value "$in_content")"
    
    echo -n "> $description
$(__parser_summary_tag_definition "Internal" "$internal")
$(__parser_summary_tag_definition "Deprecated" "$deprecated")
$(__parser_summary_tag_definition "Help" "$help")
$(__parser_summary_tag_definition "Version" "$version")
$(__parser_summary_tag_definition "Syntax compatible" "$syntax_compatible")
$(__parser_summary_tag_definition "Structure compatible" "$structure_compatible")
$(__parser_summary_tag_definition "Aliases" "$aliases")
$(__parser_summary_tag_definition "See also" "$see_also")
$(__parser_summary_tag_definition "More information" "$more_information")" |
    sed -nE '/./ p'
}



# __parser_output_command_examples <page-content>
# Output command examples from a specific page content.
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

    __parser_check_content "$in_page_content" || return "$INVALID_LAYOUT_FAIL"
    
    # shellcheck disable=2016
    sed -nE '/^[-`]/ { s/^- +//; s/ *:$//; s/^` *//; s/ *`$//; p; }' <<<"$in_page_content"
}

# __parser_output_command_example_count <page-content>
# Output an example count from a specific page content.
#
# Output:
#   <examples-count>
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
# Output a specific example description from a page content.
#
# Output:
#   <example-description>
#
# Return:
#   - 0 if page layout && index are valid
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
# Output a specific example code from a page content.
#
# Output:
#   <example-code>
#
# Return:
#   - 0 if page layout && index are valid
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
# Output the current token from a specific string.
#
# Output:
#   <token>
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
# Output all tokens from a specific string.
#
# Output:
#   <tokens>
#
# Return:
#   - 0 if string is valid
#   - 21 otherwise
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
# Output all tokens from a specific string.
#
# Output:
#   <tokens>
#
# Return:
#   - 0 if string is valid
#   - 21 otherwise
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
# Output token count from a specific token list.
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
# Output a specific token value from a token list.
#
# Output:
#   <token-value>
#
# Return:
#   - 0 index is valid
#   - 22 otherwise
__parser_output_token_value() {
    declare in_tokens="$1"
    declare in_index="$2"

    ((in_index < 0)) && return "$INVALID_TOKEN_INDEX_FAIL"

    # shellcheck disable=2155
    declare count="$(__parser_output_token_count "$in_tokens")"
    ((in_index >= count)) && return "$INVALID_TOKEN_INDEX_FAIL"

    declare -i line=0
    declare -i index=0

    mapfile -t tokens <<<"$in_tokens"

    while ((line < count * 2)) && ((index != in_index)); do
        line+=2
        index+=1
    done

    [[ -n "${tokens[line + 1]}" ]] && echo -n "${tokens[line + 1]}"
}

# __parser_output_token_type <tokens> <index>
# Output a specific token type from a token list.
#
# Output:
#   <token-type>
#
# Return:
#   - 0 index is valid
#   - 22 otherwise
__parser_output_token_type() {
    declare in_tokens="$1"
    declare in_index="$2"

    ((in_index < 0)) && return "$INVALID_TOKEN_INDEX_FAIL"

    # shellcheck disable=2155
    declare count="$(__parser_output_token_count "$in_tokens")"
    ((in_index >= count)) && return "$INVALID_TOKEN_INDEX_FAIL"

    declare -i line=0
    declare -i index=0

    mapfile -t tokens <<<"$in_tokens"

    while ((line < count * 2)) && ((index != in_index)); do
        line+=2
        index+=1
    done

    [[ -n "${tokens[line]}" ]] && echo -n "${tokens[line]}"
}

# parser_output_command_example_description_tokens <page-content> <example-index>
# Output description tokens for alternatives and literals from a specific page content.
#
# Output:
#   <description-tokens>
#
# Return:
#   - 0 if page layout && example index is valid
#   - 1 if page layout is invalid
#   - 20 if example index is invalid
#   - 21 if example description is invalid
#
# Notes:
#   - .clip page content without trailing \n
#   - alternative parsing is the first parsing stage
#   - mnemonics are considered to be nested inside alternatives or literals
parser_output_command_example_description_tokens() {
    declare in_page_content="$1"
    declare -i in_example_index="$2"

    ((in_index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare description=
    description="$(parser_output_command_example_description "$in_page_content" "$in_example_index")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    declare tokens=
    tokens="$(__parser_output_tokenized_by_balanced_tokens "$description" "()")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    echo -n "$tokens"
}

# parser_output_command_example_description_mnemonic_tokens <page-content> <example-index>
# Output description tokens for mnemonics and literals from a specific page content.
#
# Output:
#   <description-tokens>
#
# Return:
#   - 0 if page layout && example index is valid
#   - 1 if page layout is invalid
#   - 20 if example index is invalid
#   - 21 if example description is invalid
#   - 23 if description mnemonic is invalid
#
# Notes:
#   - .clip page content without trailing \n
#   - mnemonic parsing is the second parsing stage
#   - alternatives should be already expanded before parsing mnemonics
parser_output_command_example_description_mnemonic_tokens() {
    declare in_page_content="$1"
    declare -i in_example_index="$2"

    ((in_index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare description=
    description="$(parser_output_command_example_description "$in_page_content" "$in_example_index")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    declare tokens=
    tokens="$(__parser_output_tokenized_by_balanced_tokens "$description" "[]")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    # shellcheck disable=2155
    declare -i count="$(__parser_output_token_count "$tokens")"

    declare -i index=0

    # shellcheck disable=2155
    while ((index < count)); do
        declare token_type="$(__parser_output_token_type "$tokens" "$index")"
        declare token_value="$(__parser_output_token_value "$tokens" "$index")"

        if [[ "$token_type" == CONSTRUCT ]] && [[ "$token_value" =~ ' ' ]]; then
            return "$INVALID_TOKEN_VALUE_FAIL"
        fi

        index+=1
    done

    echo -n "$tokens"
}

# parser_output_command_example_description_alternative_tokens <alternative>
# Output tokens from a specific alternative.
#
# Output:
#   <alternative-tokens>
#
# Return:
#   - 0 if alternative is valid
#   - 21 if alternative is invalid
#
# Notes:
#   - .clip page content without trailing \n
parser_output_command_example_description_alternative_tokens() {
    declare in_alternative="$1"

    __parser_output_tokenized_by_unbalanced_tokens "$in_alternative" "|"
}

# parser_output_command_example_code_tokens <page-content> <example-index>
# Output code tokens for placeholders and literals from a specific page content.
#
# Output:
#   <code-tokens>
#
# Return:
#   - 0 if page layout && example index is valid
#   - 1 if page layout is invalid
#   - 20 if example index is invalid
#   - 21 if example description is invalid
#
# Notes:
#   - .clip page content without trailing \n
#   - alternative parsing is the first parsing stage
#   - mnemonics are considered to be nested inside alternatives or literals
parser_output_command_example_code_tokens() {
    declare in_page_content="$1"
    declare -i in_example_index="$2"

    ((in_index < 0)) && return "$INVALID_EXAMPLE_INDEX_FAIL"

    declare code=
    code="$(parser_output_command_example_code "$in_page_content" "$in_example_index")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    declare tokens=
    tokens="$(__parser_output_tokenized_by_balanced_tokens "$code" "{}")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"

    echo -n "$tokens"
}

# __parser_check_command_example_code_placeholder_alternative_correctness <placeholder-alternative>
# Check whether a specific placeholder alternative is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if placeholder alternative is valid
#   - 1 otherwise
#
# Notes:
#   - placeholder without trailing \n
#   - escaping is not checked
__parser_check_command_example_code_placeholder_alternative_correctness() {
    declare in_placeholder_alternative_content="$1"

    # shellcheck disable=2016
    sed -nE '/^(bool|int|float|char|string|command|option|(\/|\/\?)?file|(\/|\/\?)?directory|(\/|\/\?)?path|(\/|\/\?)?remote-file|(\/|\/\?)?remote-directory|(\/|\/\?)?remote-path|any|remote-any)([*+?]!?)? +[^{}]+$/! Q1' <<<"$in_placeholder_alternative_content"
}

# parser_output_command_example_code_placeholder_alternative_type <page-content> <placeholder-alternative>
# Output an alternative type for a specific placeholder alternative.
#
# Output:
#   <alternative-type>
#
# Return:
#   - 0 if placeholder alternative is valid
#   - 24 otherwise
#
# Notes:
#   - placeholder without trailing \n
parser_output_command_example_code_placeholder_alternative_type() {
    declare in_placeholder_alternative_content="$1"

    __parser_check_command_example_code_placeholder_alternative_correctness "$in_placeholder_alternative_content" ||
        return "$INVALID_PLACEHOLDER_ALTERNATIVE_FAIL"

    sed -E 's/^((\/|\/\?)?[^ *+?]+).+$/\1/' <<<"$in_placeholder_alternative_content"
}

# parser_output_command_example_code_placeholder_alternative_quantifier <page-content> <placeholder-alternative>
# Output an quantifier type for a specific placeholder alternative.
#
# Output:
#   <quantifier-type>
#
# Return:
#   - 0 if placeholder alternative is valid
#   - 24 otherwise
#
# Notes:
#   - placeholder without trailing \n
parser_output_command_example_code_placeholder_alternative_quantifier() {
    declare in_placeholder_alternative_content="$1"

    __parser_check_command_example_code_placeholder_alternative_correctness "$in_placeholder_alternative_content" ||
        return "$INVALID_PLACEHOLDER_ALTERNATIVE_FAIL"

    declare beginning='(\/|\/\?)?[^ *+?]+([*+?]| +([[:digit:]]+\.\.[[:digit:]]+|[[:digit:]]+\.\.|\.\.[[:digit:]]+))'
    ! sed -nE "/^$beginning/! Q1" <<<"$in_placeholder_alternative_content" && return "$SUCCESS"

    sed -E "s/^$beginning.+$/\2/
s/^ +//" <<<"$in_placeholder_alternative_content"
}

# parser_check_command_example_code_placeholder_alternative_allow_repetitions <placeholder-alternative>
# Check whether a specific placeholder alternative allows repetitions.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if placeholder alternative is valid && repetition is allowed
#   - 24 if placeholder alternative is invalid
#   - 25 if repetition is not allowed
#
# Notes:
#   - placeholder without trailing \n
#   - returns 0 for placeholder alternatives without repetition (it's allowed to repeat, but just once)
parser_check_command_example_code_placeholder_alternative_allow_repetitions() {
    declare in_placeholder_alternative_content="$1"

    __parser_check_command_example_code_placeholder_alternative_correctness "$in_placeholder_alternative_content" ||
        return "$INVALID_PLACEHOLDER_ALTERNATIVE_FAIL"
    
    ! sed -nE '/^(\/|\/\?)?[^ *+?]+([*+?]| +([[:digit:]]+\.\.[[:digit:]]+|[[:digit:]]+\.\.|\.\.[[:digit:]]+))!/! Q1' <<<"$in_placeholder_alternative_content" ||
        return "$INVALID_PLACEHOLDER_ALTERNATIVE_REPETITION_NOT_ALLOWED"
}

# parser_output_command_example_code_placeholder_alternative_description <placeholder-alternative>
# Output an alternative description for a specific placeholder alternative.
#
# Output:
#   <alternative-description>
#
# Return:
#   - 0 if placeholder alternative is valid
#   - 24 otherwise
#
# Notes:
#   - placeholder without trailing \n
parser_output_command_example_code_placeholder_alternative_description() {
    declare in_alternative_content="$1"

    __parser_check_command_example_code_placeholder_alternative_correctness "$in_alternative_content" ||
        return "$INVALID_PLACEHOLDER_ALTERNATIVE_FAIL"
    
    in_alternative_content="$(sed -E 's/^(\/|\/\?)?[^ *+?]+([*+?]!?| +([[:digit:]]+\.\.[[:digit:]]+|[[:digit:]]+\.\.|\.\.[[:digit:]]+)!?)? +//' <<<"$in_alternative_content")"
    
    echo -n "$(__parser_output_current_token "$in_alternative_content" 0 ":")"
}

# parser_output_command_example_code_placeholder_alternative_description <placeholder-alternative>
# Output an alternative description for a specific placeholder alternative.
#
# Output:
#   <alternative-description>
#
# Return:
#   - 0 if placeholder alternative is valid
#   - 24 otherwise
#
# Notes:
#   - placeholder without trailing \n
parser_output_command_example_code_placeholder_alternative_examples() {
    declare in_alternative_content="$1"

    __parser_check_command_example_code_placeholder_alternative_correctness "$in_alternative_content" ||
        return "$INVALID_PLACEHOLDER_ALTERNATIVE_FAIL"
    
    # shellcheck disable=2155
    declare alternative_description="$(__parser_output_current_token "$in_alternative_content" 0 ":")"
    declare -i description_length="${#alternative_description} + 1"
    echo -n "$(sed -E 's/^ +//' <<< "${in_alternative_content:description_length}")"
}
