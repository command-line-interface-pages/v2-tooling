#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i PARSER_INVALID_CONTENT_CODE=1
declare -i PARSER_INVALID_SUMMARY_CODE=2
# shellcheck disable=2034
declare -i PARSER_INVALID_EXAMPLES_CODE=3
declare -i PARSER_INVALID_TOKENS_CODE=4
declare -i PARSER_INVALID_ARGUMENT_CODE=5
declare -i PARSER_NOT_ALLOWED_CODE=6



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
    declare more_information_value="$(parser_summary_more_information_value "$in_content")"
    # shellcheck disable=2155
    declare internal_value="$(parser_summary_internal_value_or_default "$in_content")"
    # shellcheck disable=2155
    declare deprecated_value="$(parser_summary_deprecated_value_or_default "$in_content")"
    # shellcheck disable=2155
    declare see_also_value="$(parser_summary_see_also_value "$in_content")"
    # shellcheck disable=2155
    declare aliases_value="$(parser_summary_aliases_value "$in_content")"
    # shellcheck disable=2155
    declare syntax_compatible_value="$(parser_summary_syntax_compatible_value "$in_content")"
    # shellcheck disable=2155
    declare help_value="$(parser_summary_help_value "$in_content")"
    # shellcheck disable=2155
    declare version_value="$(parser_summary_version_value "$in_content")"
    # shellcheck disable=2155
    declare structure_compatible_value="$(parser_summary_structure_compatible_value "$in_content")"
    
    echo -n "> $description
$(__parser_summary_tag_definition "Internal" "$internal_value")
$(__parser_summary_tag_definition "Deprecated" "$deprecated_value")
$(__parser_summary_tag_definition "Help" "$help_value")
$(__parser_summary_tag_definition "Version" "$version_value")
$(__parser_summary_tag_definition "Syntax compatible" "$syntax_compatible_value")
$(__parser_summary_tag_definition "Structure compatible" "$structure_compatible_value")
$(__parser_summary_tag_definition "Aliases" "$aliases_value")
$(__parser_summary_tag_definition "See also" "$see_also_value")
$(__parser_summary_tag_definition "More information" "$more_information_value")" |
    sed -nE '/./ p'
}



# __parser_examples__all <content>
# Output examples.
#
# Output:
#   <examples>
#
# Return:
#   - 0 if <content> is valid
#   - $PARSER_INVALID_CONTENT_CODE otherwise
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
__parser_examples__all() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_content "$in_content" || return "$?"
    fi
    
    # shellcheck disable=2016
    sed -nE '/^[-`]/ {
        s/^- +//
        s/ *:$//
        s/^` *//
        s/ *`$//
        p
    }' <<<"$in_content"
}

# __parser_examples__all_count <content>
# Output an example count.
#
# Output:
#   <count>
#
# Return:
#   - 0 if <content> is valid
#   - $PARSER_INVALID_CONTENT_CODE otherwise
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
__parser_examples__all_count() {
    declare in_content="$1"

    declare examples=
    examples="$(__parser_examples__all "$in_content")"
    declare -i status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare -i count="$(echo "$examples" | wc -l)"
    ((count % 2 == 0)) || count+=1

    echo -n "$((count / 2))"
}

# parser_examples__description_at <content> <index>
# Output an example description.
#
# Output:
#   <description>
#
# Return:
#   - 0 if <content> is valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_ARGUMENT_CODE if <index> is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__description_at() {
    declare in_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare examples=
    examples="$(__parser_examples__all "$in_content")"
    declare -i status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare -i count="$(__parser_examples__all_count "$in_content")"
    ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    sed -nE "$((in_index * 2 + 1)) p" <<<"$examples"
}

# parser_examples__code_at <content> <index>
# Output an example code.
#
# Output:
#   <code>
#
# Return:
#   - 0 if <content> is valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_ARGUMENT_CODE if <index> is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__code_at() {
    declare in_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare examples=
    examples="$(__parser_examples__all "$in_content")"
    declare -i status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare -i count="$(__parser_examples__all_count "$in_content")"
    ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    sed -nE "$((in_index * 2 + 2)) p" <<<"$examples"
}

# __parser_tokens__current <string> <index> <next-token-start>
# Output the current token.
#
# Output:
#   <current-token>
#
# Return:
#   - 0 if <index> is valid
#   - $PARSER_INVALID_ARGUMENT_CODE otherwise
#
# Return:
#   - <index> after traversal
__parser_tokens__current() {
    declare in_string="$1"
    declare -i in_index="$2"
    declare in_next_token_start="${3:0:1}"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare current_token=

    while ((in_index < ${#in_string})) && [[ "${in_string:in_index:1}" != "$in_next_token_start" ]]; do
        [[ "${in_string:in_index:1}" == \\ ]] && in_index+=1

        current_token+="${in_string:in_index:1}"
        in_index+=1
    done

    echo -n "$current_token"
    return "$in_index"
}

# __parser_tokens__all_balanced <string> <special-construct-start-and-end>
# Output all balanced tokens.
#
# Output:
#   <balanced-tokens>
#
# Return:
#   - 0 if <string> is valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <string> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
#   - token types:
#     - LITERAL
#     - CONSTRUCT
#   - token type precedes token value (which may be missing if token doesn't contain value)
#   - nested contructs are unsupported
__parser_tokens__all_balanced() {
    declare in_string="$1"
    declare in_construct_delimiters="${2:0:2}"

    declare -i index=0
    declare construct_start="${in_construct_delimiters:0:1}"
    declare construct_end="${in_construct_delimiters:1:1}"

    while ((index < ${#in_string})); do
        declare literal_token=
        literal_token="$(__parser_tokens__current "$in_string" "$index" "$construct_start")"
        index="$?"

        printf "%s\n%s\n" LITERAL "$literal_token"
        index+=1

        declare construct_token=
        construct_token="$(__parser_tokens__current "$in_string" "$index" "$construct_end")"
        index="$?"

        [[ -n "$construct_token" ]] && {
            if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
                [[ "${in_string:index:1}" == "$construct_end" ]] || return "$PARSER_INVALID_TOKENS_CODE"
            fi
            printf "%s\n%s\n" CONSTRUCT "$construct_token"
        }
        index+=1
    done
}

# __parser_tokens__all_unbalanced <string> <special-construct>
# Output all unbalanced tokens.
#
# Output:
#   <unbalanced-tokens>
#
# Return:
#   - 0 always
#
# Notes:
#   - <string> should not contain trailing \n
#   - token types:
#     - LITERAL
#     - CONSTRUCT
#   - token type precedes token value (which may be missing if token doesn't contain value)
__parser_tokens__all_unbalanced() {
    declare in_string="$1"
    declare in_construct_delimiter="${2:0:1}"

    declare -i index=0

    while ((index < ${#in_string})); do
        declare literal_token=
        literal_token="$(__parser_tokens__current "$in_string" "$index" "$in_construct_delimiter")"
        index="$?"

        [[ -n "$literal_token" ]] && printf "%s\n%s\n" CONSTRUCT "$literal_token"
        index+=1
    done
}

# __parser_tokens__count <tokens>
# Output token count.
#
# Output:
#   <count>
#
# Return:
#   - 0 always
__parser_tokens__count() {
    declare in_tokens="$1"

    # shellcheck disable=2155
    declare -i count="$(echo -n "$in_tokens" | wc -l)"
    ((count % 2 == 0)) || count+=1

    echo -n "$((count / 2))"
}

# __parser_tokens__value <tokens> <index>
# Output a token value.
#
# Output:
#   <token-value>
#
# Return:
#   - 0 <index> is valid
#   - $PARSER_INVALID_ARGUMENT_CODE otherwise
__parser_tokens__value() {
    declare in_tokens="$1"
    declare in_index="$2"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    # shellcheck disable=2155
    declare count="$(__parser_tokens__count "$in_tokens")"
    ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare -i line=0
    declare -i index=0

    mapfile -t tokens_array <<<"$in_tokens"

    while ((line < count * 2)) && ((index != in_index)); do
        line+=2
        index+=1
    done

    [[ -n "${tokens_array[line + 1]}" ]] && echo -n "${tokens_array[line + 1]}"
}

# __parser_tokens__type <tokens> <index>
# Output a token type.
#
# Output:
#   <token-type>
#
# Return:
#   - 0 <index> is valid
#   - $PARSER_INVALID_ARGUMENT_CODE otherwise
__parser_tokens__type() {
    declare in_tokens="$1"
    declare in_index="$2"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    # shellcheck disable=2155
    declare count="$(__parser_tokens__count "$in_tokens")"
    ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare -i line=0
    declare -i index=0

    mapfile -t tokens_array <<<"$in_tokens"

    while ((line < count * 2)) && ((index != in_index)); do
        line+=2
        index+=1
    done

    [[ -n "${tokens_array[line]}" ]] && echo -n "${tokens_array[line]}"
}

# parser_examples__description_alternative_tokens_at <content> <index>
# Output alternative and literal tokens.
#
# Output:
#   <alternative-tokens>
#
# Return:
#   - 0 if <content> and <index> are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_TOKENS_CODE if <content> is invalid
#   - $PARSER_INVALID_ARGUMENT_CODE if <index> is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
#   - alternative parsing is the first parsing stage
parser_examples__description_alternative_tokens_at() {
    declare in_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare description=
    description="$(parser_examples__description_at "$in_content" "$in_index")"
    declare -i status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == PARSER_INVALID_CONTENT_CODE)) && return "$status"
    fi

    declare tokens=
    tokens="$(__parser_tokens__all_balanced "$description" "()")"
    status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    echo -n "$tokens"
}

# __parser_check_examples__description_mnemonic_token_values <tokens>
# Check whether mnemonic values are valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <tokens> are valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <tokens> should not contain trailing \n
__parser_check_examples__description_mnemonic_token_values() {
    declare in_tokens="$1"

    # shellcheck disable=2155
    declare -i count="$(__parser_tokens__count "$in_tokens")"

    declare -i index=0

    # shellcheck disable=2155
    while ((index < count)); do
        declare token_type="$(__parser_tokens__type "$in_tokens" "$index")"
        declare token_value="$(__parser_tokens__value "$in_tokens" "$index")"

        if [[ "$token_type" == CONSTRUCT ]] && [[ "$token_value" =~ ' ' ]]; then
            return "$PARSER_INVALID_TOKENS_CODE"
        fi

        index+=1
    done
}

# parser_examples__description_mnemonic_tokens_at <content> <index>
# Output mnemonic and literal tokens.
#
# Output:
#   <mnemonic-tokens>
#
# Return:
#   - 0 if <content> and <index> are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_TOKENS_CODE if <content> is invalid
#   - $PARSER_INVALID_ARGUMENT_CODE if <index> is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
#   - alternatives should be already expanded before parsing mnemonics
parser_examples__description_mnemonic_tokens_at() {
    declare in_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare description=
    description="$(parser_examples__description_at "$in_content" "$in_index")"
    declare -i status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == PARSER_INVALID_CONTENT_CODE)) && return "$status"
    fi

    declare tokens=
    tokens="$(__parser_tokens__all_balanced "$description" "[]")"
    status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
        __parser_check_examples__description_mnemonic_token_values "$tokens" || return "$?"
    fi

    echo -n "$tokens"
}

# parser_examples__description_alternative_token_pieces <token>
# Output alternative pieces.
#
# Output:
#   <tokens>
#
# Return:
#   - 0 always
#
# Notes:
#   - <token> should not contain trailing \n
parser_examples__description_alternative_token_pieces() {
    declare in_alternative="$1"

    __parser_tokens__all_unbalanced "$in_alternative" "|"
}

# parser_examples__code_placeholder_tokens_at <content> <index>
# Output placeholder and literal tokens from a content.
#
# Output:
#   <alternative-tokens>
#
# Return:
#   - 0 if <content> and <index> are valid
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_INVALID_TOKENS_CODE if <content> is invalid
#   - $PARSER_INVALID_ARGUMENT_CODE if <index> is invalid
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__code_placeholder_tokens_at() {
    declare in_content="$1"
    declare -i in_index="$2"

    ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"

    declare code=
    code="$(parser_examples__code_at "$in_content" "$in_index")"
    declare -i status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == PARSER_INVALID_CONTENT_CODE)) && return "$status"
    fi

    declare tokens=
    tokens="$(__parser_tokens__all_balanced "$code" "{}")"
    status="$?"
    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    echo -n "$tokens"
}



# __parser_check_examples__code_placeholder_piece <piece>
# Check whether a placeholder piece (alternative) is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <piece> is valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <piece> should not contain trailing \n
#   - escaping is not checked
__parser_check_examples__code_placeholder_piece() {
    declare in_piece="$1"

    # shellcheck disable=2016
    sed -nE '/^(bool|int|float|char|string|command|option|(\/|\/\?)?file|(\/|\/\?)?directory|(\/|\/\?)?path|(\/|\/\?)?remote-file|(\/|\/\?)?remote-directory|(\/|\/\?)?remote-path|any|remote-any)([*+?]!?)? +[^{}]+$/! Q1' <<<"$in_piece" ||
        return "$PARSER_INVALID_TOKENS_CODE"
}

# parser_examples__code_placeholder_piece_type <piece>
# Output a placeholder piece (alternative) type.
#
# Output:
#   <type>
#
# Return:
#   - 0 if <piece> is valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <piece> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__code_placeholder_piece_type() {
    declare in_piece="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_examples__code_placeholder_piece "$in_piece" ||
            return "$PARSER_INVALID_TOKENS_CODE"
    fi

    sed -E 's/^((\/|\/\?)?[^ *+?]+).+$/\1/' <<<"$in_piece"
}

# parser_examples__code_placeholder_piece_quantifier <piece>
# Output a placeholder piece (alternative) quantifier.
#
# Output:
#   <quantifier>
#
# Return:
#   - 0 if <piece> is valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <piece> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__code_placeholder_piece_quantifier() {
    declare in_piece="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_examples__code_placeholder_piece "$in_piece" ||
            return "$PARSER_INVALID_TOKENS_CODE"
    fi

    declare beginning='(\/|\/\?)?[^ *+?]+([*+?]| +([[:digit:]]+\.\.[[:digit:]]+|[[:digit:]]+\.\.|\.\.[[:digit:]]+))'
    ! sed -nE "/^$beginning/! Q1" <<<"$in_piece" && return "$SUCCESS"

    sed -E "s/^$beginning.+$/\2/
s/^ +//" <<<"$in_piece"
}

# parser_check_examples__code_placeholder_piece_allows_repetitions <piece>
# Check whether a placeholder piece (alternative) allows repetitions.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <piece> is valid and repetition is allowed
#   - $PARSER_INVALID_TOKENS_CODE if <piece> is invalid
#   - $PARSER_NOT_ALLOWED_CODE if repetition is not allowed
#   
#
# Notes:
#   - <piece> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
#   - returns 0 for placeholder piece without repetition (it's allowed to repeat, but just once)
parser_check_examples__code_placeholder_piece_allows_repetitions() {
    declare in_piece="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_examples__code_placeholder_piece "$in_piece" ||
            return "$PARSER_INVALID_TOKENS_CODE"
    fi
    
    ! sed -nE '/^(\/|\/\?)?[^ *+?]+([*+?]| +([[:digit:]]+\.\.[[:digit:]]+|[[:digit:]]+\.\.|\.\.[[:digit:]]+))!/! Q1' <<<"$in_piece" ||
        return "$PARSER_NOT_ALLOWED_CODE"
}

# parser_examples__code_placeholder_piece_description <piece>
# Output a placeholder piece (alternative) description.
#
# Output:
#   <description>
#
# Return:
#   - 0 if <piece> is valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <piece> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__code_placeholder_piece_description() {
    declare in_piece="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_examples__code_placeholder_piece "$in_piece" ||
            return "$PARSER_INVALID_TOKENS_CODE"
    fi
    
    in_piece="$(sed -E 's/^(\/|\/\?)?[^ *+?]+([*+?]!?| +([[:digit:]]+\.\.[[:digit:]]+|[[:digit:]]+\.\.|\.\.[[:digit:]]+)!?)? +//' <<<"$in_piece")"
    
    echo -n "$(__parser_tokens__current "$in_piece" 0 ":")"
}

# parser_examples__code_placeholder_piece_examples <piece>
# Output placeholder piece (alternative) examples.
#
# Output:
#   <examples>
#
# Return:
#   - 0 if <piece> is valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <piece> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__code_placeholder_piece_examples() {
    declare in_piece="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_examples__code_placeholder_piece "$in_piece" ||
            return "$PARSER_INVALID_TOKENS_CODE"
    fi
    
    # shellcheck disable=2155
    declare description="$(__parser_tokens__current "$in_piece" 0 ":")"
    declare -i description_length="${#description} + 1"
    echo -n "$(sed -E 's/^ +//' <<< "${in_placeholder_piece:description_length}")"
}


CHECK=0 parser_examples__code_placeholder_tokens_at '# am

> Android activity manager
> More information: https://developer.android.com/studio/command-line/adb#am

- Start a specific activity:

`am start -n {string activity: com.android.settings/.Settings}`

- Start an activity and pass [d]ata to it:

`am start -a {string activity: android.intent.action.VIEW} -d {string data: tel:123}`

- Start an activity matching a specific action and [c]ategory:

`am start -a {string activity: android.intent.action.MAIN} -c {string category: android.intent.category.HOME}`

- Convert an intent to a URI:

`am to-uri -a {string activity: android.intent.action.VIEW} -d {string data: tel:123}`' 1
echo "STATUS = $?"
