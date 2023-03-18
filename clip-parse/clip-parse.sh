#!/usr/bin/env bash

shopt -s extglob

declare -i SUCCESS=0
declare -i PARSER_INVALID_CONTENT_CODE=1
declare -i PARSER_INVALID_SUMMARY_CODE=2
# shellcheck disable=2034
declare -i PARSER_INVALID_EXAMPLES_CODE=3
declare -i PARSER_INVALID_TOKENS_CODE=4
declare -i PARSER_INVALID_ARGUMENT_CODE=5
declare -i PARSER_NOT_ALLOWED_CODE=6
declare -i PARSER_TYPE_CODE=7



# parser__version
# Output a parser version.
#
# Output:
#   <version>
#
# Return:
#   - 0 always
parser__version() {
    echo "1.3.0"
    return "$SUCCESS"
}



# __parser_string__join <separator> <strings>
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
__parser_string__join() {
  declare in_separator="$1"
  declare in_string="$2"

  if shift 2; then
    printf '%s' "$in_string" "${@/#/$in_separator}"
  fi

  return "$SUCCESS"
}

# __parser_string__unify <string>
# Output a string without repeated comma-separated items.
#
# Output:
#   <string>
#
# Return:
#   - 0 always
#
# Notes:
#   - <string> should not contain trailing \n
__parser_string__unify() {
    declare in_string="$1"

    mapfile -t string_array < <(echo -n "$in_string" | sed -E 's/ +/ /g
    s/ *, */\n/g' | sort -r -u)

    __parser_string__join ", " "${string_array[@]}"
    return "$SUCCESS"
}



# __parser_check__content <content>
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
__parser_check__content() {
    declare in_content="$1"

    # shellcheck disable=2016
    sed -nE ':x
        N
        $! bx
        /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$in_content"$'\n\n' ||
        return "$PARSER_INVALID_CONTENT_CODE"
    
    return "$SUCCESS"
}

# parser__header <content>
# Output a header.
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
parser__header() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check__content "$in_content" || return "$PARSER_INVALID_CONTENT_CODE"
    fi

    sed -nE '1 {
        s/^# +//
        s/ +$//
        s/ +/ /g
        p
    }' <<<"$in_content"

    return "$SUCCESS"
}



# __parser_check__summary <summary>
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
__parser_check__summary() {
    declare in_summary="$1"

    # shellcheck disable=2016
    sed -nE ':x
        N
        $! bx
        /^(> [^\n:]+\n){1,2}(> [^\n:]+:[^\n]+\n)+$/! Q1' <<<"$in_summary"$'\n' ||
        return "$PARSER_INVALID_SUMMARY_CODE"

    return "$SUCCESS"
}

# parser_summary__description <content>
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
parser_summary__description() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check__content "$in_content" || return "$?"
    fi
    
    # shellcheck disable=2155
    declare summary="$(sed -nE '/^>/ p' <<<"$in_content")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check__summary "$summary" || return "$?"
    fi

    sed -nE '/^> [^:]+$/ {
        s/^> +//
        s/\.$//
        s/ +$//
        s/  +/ /g
        p
    }' <<<"$summary"

    return "$SUCCESS"
}

# __parser_type__simple_value <value>
# Output a value simple type.
#
# Output:
#   <type>
#
# Return:
#   - 0 always
#
# Notes:
#   - <value> should not contain trailing \n
#   - possible simple types: boolean, integer, string
__parser_type__simple_value() {
    declare in_value="$1"

    in_value="$(sed -E 's/^ +//
        s/ +$//' <<<"$in_value")"

    case "$in_value" in
        true|false)
            echo -n boolean
        ;;
        ?(+|-)+([[:digit:]]))
            echo -n integer
        ;;
        *)
            echo -n string
        ;;
    esac
}

# __parser_type__compound_value <value>
# Output a value compound type.
#
# Output:
#   <type>
#
# Return:
#   - 0 if <value> contains items of one type
#   - $PARSER_TYPE_CODE otherwise
#
# Notes:
#   - <value> should not contain trailing \n
#   - possible compound types: boolean-array, integer-array, string-array
__parser_type__compound_value() {
    declare in_value="$1"

    mapfile -t items < <(sed -E 's/,/\n/g' <<<"$in_value")

    # shellcheck disable=2155
    declare first_item_type="$(__parser_type__simple_value "${items[0]}")"
    declare -i index=1

    # shellcheck disable=2155
    while ((index < ${#items[@]})); do
        declare item_type="$(__parser_type__simple_value "${items[index]}")"
        [[ "$first_item_type" != "$item_type" ]] && return "$PARSER_TYPE_CODE"
        index+=1
    done

    echo -n "${first_item_type}-array"
    return "$SUCCESS"
}

# __parser_type__value <value>
# Output a value type.
#
# Output:
#   <type>
#
# Return:
#   - 0 if <value> contains items of one type
#   - $PARSER_TYPE_CODE otherwise
#
# Notes:
#   - <value> should not contain trailing \n
#   - possible simple types: boolean, integer, string
__parser_type__value() {
    declare in_value="$1"

    if [[ "$in_value" =~ , ]]; then
        __parser_type__compound_value "$in_value" ||
            return "$PARSER_TYPE_CODE"
    else
        __parser_type__simple_value "$in_value"
    fi

    return "$SUCCESS"
}

# __parser_check_summary__tag_value <tag> <tag-value>
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
__parser_check_summary__tag_value() {
    declare in_tag="$1"
    declare in_tag_value="$2"

    declare -A valid_tag_types=(
        ["More information"]=string
        [Internal]=boolean
        [Deprecated]=boolean
        ["See also"]=string/string-array
        [Aliases]=string/string-array
        ["Syntax compatible"]=string/string-array
        [Help]=string/string-array
        [Version]=string/string-array
        ["Structure compatible"]=string/string-array
    )
    
    [[ -v "valid_tag_types[$in_tag]" ]] || return "$PARSER_INVALID_SUMMARY_CODE"
    mapfile -t types < <(sed -E 's|/|\n|g' <<<"${valid_tag_types[$in_tag]}")
    # shellcheck disable=2155
    declare tag_value_type="$(__parser_type__value "$in_tag_value")"

    for type in "${types[@]}"; do
        [[ "$type" == "$tag_value_type" ]] && return "$SUCCESS"
    done

    return "$PARSER_INVALID_SUMMARY_CODE"
}

# __parser_check_summary__tag_values <tags>
# Check whether all tag values are valid.
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
__parser_check_summary__tag_values() {
    declare in_tags="$1"

    mapfile -t tags_array <<<"$in_tags"

    declare -i index=0

    while ((index < "${#tags_array[@]}")); do
        declare tag="${tags_array[index]}"
        declare tag_value="${tags_array[index + 1]}"
        
        if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
            __parser_check_summary__tag_value "$tag" "$tag_value" || return "$?"
        fi

        index+=2
    done

    return "$SUCCESS"
}

# __parser_summary__tags <content>
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
__parser_summary__tags() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check__content "$in_content" || return "$?"
    fi
    
    # shellcheck disable=2155
    declare summary="$(sed -nE '/^>/ p' <<<"$in_content")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check__summary "$summary" || return "$?"
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
        __parser_check_summary__tag_values "$tags" || return "$?"
    fi

    echo -n "$tags"
    return "$SUCCESS"
}

# __parser_summary__tag_value <content> <tag>
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
__parser_summary__tag_value() {
    declare in_content="$1"
    # shellcheck disable=2155
    declare in_tag="$(sed -E 's/^ +//
        s/ +$//
        s/ +/ /g' <<<"$2")"

    declare tags=
    tags="$(__parser_summary__tags "$in_content")"
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

    return "$SUCCESS"
}

# parser_summary__more_information_value <content>
# Output "More information" tag value from a summary.
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
parser_summary__more_information_value() {
    declare in_content="$1"

    __parser_summary__tag_value "$in_content" "More information" || return "$?"
    return "$SUCCESS"
}

# parser_summary__internal_value <content>
# Output "Internal" tag value from a summary.
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
parser_summary__internal_value() {
    declare in_content="$1"

    __parser_summary__tag_value "$in_content" "Internal" || return "$?"
    return "$SUCCESS"
}

# parser_summary__internal_value_or_default <content>
# Output "Internal" tag value from a summary or default.
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
parser_summary__internal_value_or_default() {
    declare in_content="$1"

    declare tag_value=
    tag_value="$(parser_summary__internal_value "$in_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"
    [[ -z "$tag_value" ]] && tag_value=false
    echo -n "$tag_value"
    return "$SUCCESS"
}

# parser_summary__deprecated_value <content>
# Output "Deprecated" tag value from a summary.
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
parser_summary__deprecated_value() {
    declare in_content="$1"

    __parser_summary__tag_value "$in_content" "Deprecated" || return "$?"
    return "$SUCCESS"
}

# parser_summary__deprecated_value_or_default <content>
# Output "Deprecated" tag value from a summary or default.
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
parser_summary__deprecated_value_or_default() {
    declare in_content="$1"

    declare output=
    output="$(parser_summary__deprecated_value "$in_content")"
    # shellcheck disable=2181
    (($? == 0)) || return "$?"
    [[ -z "$output" ]] && output=false
    echo -n "$output"
    return "$SUCCESS"
}

# parser_summary__see_also_value <content>
# Output "See also" tag value from a summary.
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
parser_summary__see_also_value() {
    declare in_content="$1"

    echo -n "$(__parser_string__unify "$(__parser_summary__tag_value "$in_content" "See also")")"
    return "$SUCCESS"
}

# parser_summary__aliases_value <content>
# Output "Aliases" tag value from a summary.
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
parser_summary__aliases_value() {
    declare in_content="$1"

    echo -n "$(__parser_string__unify "$(__parser_summary__tag_value "$in_content" "Aliases")")"
    return "$SUCCESS"
}

# parser_summary__syntax_compatible_value <content>
# Output "Syntax compatible" tag value from a summary.
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
parser_summary__syntax_compatible_value() {
    declare in_content="$1"

    echo -n "$(__parser_string__unify "$(__parser_summary__tag_value "$in_content" "Syntax compatible")")"
    return "$SUCCESS"
}

# parser_summary__help_value <content>
# Output "Help" tag value from a summary.
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
parser_summary__help_value() {
    declare in_content="$1"

    echo -n "$(__parser_string__unify "$(__parser_summary__tag_value "$in_content" "Help")")"
    return "$SUCCESS"
}

# parser_summary__version_value <content>
# Output "Version" tag value from a summary.
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
parser_summary__version_value() {
    declare in_content="$1"

    echo -n "$(__parser_string__unify "$(__parser_summary__tag_value "$in_content" "Version")")"
    return "$SUCCESS"
}

# parser_summary__structure_compatible_value <content>
# Output "Structure compatible" tag value from a summary.
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
parser_summary__structure_compatible_value() {
    declare in_content="$1"

    echo -n "$(__parser_string__unify "$(__parser_summary__tag_value "$in_content" "Structure compatible")")"
    return "$SUCCESS"
}

# __parser_summary__tag_definition <tag> <tag-value>
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
__parser_summary__tag_definition() {
    declare in_tag="$1"
    declare in_tag_value="$2"

    [[ -z "$in_tag" || -z "$in_tag_value" ]] && return "$SUCCESS"
    [[ "$in_tag" =~ ^(Internal|Deprecated)$ && "$in_tag_value" == false ]] && return "$SUCCESS"
    echo -n "> $in_tag: $in_tag_value"
    return "$SUCCESS"
}

# parser_summary__cleaned_up <content>
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
parser_summary__cleaned_up() {
    declare in_content="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_summary__tags "$in_content" > /dev/null || return "$PARSER_INVALID_SUMMARY_CODE"
    fi

    CHECK= # as we already checked input there is no need to do it in each data request
    # shellcheck disable=2155
    declare description="$(parser_summary__description "$in_content")"
    # shellcheck disable=2155
    declare more_information_value="$(parser_summary__more_information_value "$in_content")"
    # shellcheck disable=2155
    declare internal_value="$(parser_summary__internal_value_or_default "$in_content")"
    # shellcheck disable=2155
    declare deprecated_value="$(parser_summary__deprecated_value_or_default "$in_content")"
    # shellcheck disable=2155
    declare see_also_value="$(parser_summary__see_also_value "$in_content")"
    # shellcheck disable=2155
    declare aliases_value="$(parser_summary__aliases_value "$in_content")"
    # shellcheck disable=2155
    declare syntax_compatible_value="$(parser_summary__syntax_compatible_value "$in_content")"
    # shellcheck disable=2155
    declare help_value="$(parser_summary__help_value "$in_content")"
    # shellcheck disable=2155
    declare version_value="$(parser_summary__version_value "$in_content")"
    # shellcheck disable=2155
    declare structure_compatible_value="$(parser_summary__structure_compatible_value "$in_content")"
    
    echo -n "$(sed -E 's/^/> /' <<<"$description")
$(__parser_summary__tag_definition "Internal" "$internal_value")
$(__parser_summary__tag_definition "Deprecated" "$deprecated_value")
$(__parser_summary__tag_definition "Help" "$help_value")
$(__parser_summary__tag_definition "Version" "$version_value")
$(__parser_summary__tag_definition "Syntax compatible" "$syntax_compatible_value")
$(__parser_summary__tag_definition "Structure compatible" "$structure_compatible_value")
$(__parser_summary__tag_definition "Aliases" "$aliases_value")
$(__parser_summary__tag_definition "See also" "$see_also_value")
$(__parser_summary__tag_definition "More information" "$more_information_value")" |
    sed -nE '/./ p'

    return "$SUCCESS"
}



# __parser_examples__all <content>
# Output all examples.
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
        __parser_check__content "$in_content" || return "$?"
    fi
    
    # shellcheck disable=2016
    sed -nE '/^-/ {
        s/^- +//
        s/ *:$//
        p
    }
    /^`/ {
        s/^` *//
        s/ *`$//
        p
    }' <<<"$in_content"

    return "$SUCCESS"
}

# parser_examples__count <content>
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
parser_examples__count() {
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
    return "$SUCCESS"
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

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare examples=
    examples="$(__parser_examples__all "$in_content")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare -i count="$(parser_examples__count "$in_content")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    sed -nE "$((in_index * 2 + 1)) p" <<<"$examples"
    return "$SUCCESS"
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

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare examples=
    examples="$(__parser_examples__all "$in_content")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare -i count="$(parser_examples__count "$in_content")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    sed -nE "$((in_index * 2 + 2)) p" <<<"$examples"
    return "$SUCCESS"
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

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare current_token=

    while ((in_index < ${#in_string})) && [[ "${in_string:in_index:1}" != "$in_next_token_start" ]]; do
        if [[ "${in_string:in_index:1}" == \\ && "${in_string:in_index + 1:1}" == "$in_next_token_start" ]]; then
            in_index+=1
        fi

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

# parser_tokens__count <tokens>
# Output token count.
#
# Output:
#   <count>
#
# Return:
#   - 0 always
parser_tokens__count() {
    declare in_tokens="$1"

    # shellcheck disable=2155
    declare -i count="$(echo -n "$in_tokens" | wc -l)"
    ((count % 2 == 0)) || count+=1
    echo -n "$((count / 2))"
    return "$SUCCESS"
}

# parser_tokens__value <tokens> <index>
# Output a token value.
#
# Output:
#   <token-value>
#
# Return:
#   - 0 <index> is valid
#   - $PARSER_INVALID_ARGUMENT_CODE otherwise
parser_tokens__value() {
    declare in_tokens="$1"
    declare in_index="$2"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    # shellcheck disable=2155
    declare count="$(parser_tokens__count "$in_tokens")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare -i line=0
    declare -i index=0
    mapfile -t tokens_array <<<"$in_tokens"

    while ((line < count * 2)) && ((index != in_index)); do
        line+=2
        index+=1
    done

    [[ -n "${tokens_array[line + 1]}" ]] && echo -n "${tokens_array[line + 1]}"
    return "$SUCCESS"
}

# parser_tokens__type <tokens> <index>
# Output a token type.
#
# Output:
#   <token-type>
#
# Return:
#   - 0 <index> is valid
#   - $PARSER_INVALID_ARGUMENT_CODE otherwise
parser_tokens__type() {
    declare in_tokens="$1"
    declare in_index="$2"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    # shellcheck disable=2155
    declare count="$(parser_tokens__count "$in_tokens")"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index >= count)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare -i line=0
    declare -i index=0
    mapfile -t tokens_array <<<"$in_tokens"

    while ((line < count * 2)) && ((index != in_index)); do
        line+=2
        index+=1
    done

    [[ -n "${tokens_array[line]}" ]] && echo -n "${tokens_array[line]}"
    return "$SUCCESS"
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

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare description=
    description="$(parser_examples__description_at "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    declare tokens=
    tokens="$(__parser_tokens__all_balanced "$description" "()")"
    status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    echo -n "$tokens"
    return "$SUCCESS"
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
    declare -i count="$(parser_tokens__count "$in_tokens")"
    declare -i index=0

    # shellcheck disable=2155
    while ((index < count)); do
        declare token_type="$(parser_tokens__type "$in_tokens" "$index")"
        declare token_value="$(parser_tokens__value "$in_tokens" "$index")"

        if [[ "$token_type" == CONSTRUCT ]] && [[ "$token_value" =~ ' ' ]]; then
            return "$PARSER_INVALID_TOKENS_CODE"
        fi

        index+=1
    done

    return "$SUCCESS"
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

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare description=
    description="$(parser_examples__description_at "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    declare tokens=
    tokens="$(__parser_tokens__all_balanced "$description" "[]")"
    status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
        __parser_check_examples__description_mnemonic_token_values "$tokens" || return "$?"
    fi

    echo -n "$tokens"
    return "$SUCCESS"
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
    return "$SUCCESS"
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

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((in_index < 0)) && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare code=
    code="$(parser_examples__code_at "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    declare tokens=
    tokens="$(__parser_tokens__all_balanced "$code" "{}")"
    status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    echo -n "$tokens"
    return "$SUCCESS"
}

# parser_examples__code_placeholder_token_pieces <placeholder>
# Output placeholder pieces.
#
# Output:
#   <tokens>
#
# Return:
#   - 0 always
#
# Notes:
#   - <placeholder> should not contain trailing \n
parser_examples__code_placeholder_token_pieces() {
    declare in_placeholder="$1"

    __parser_tokens__all_unbalanced "$in_placeholder" "|"
    return "$SUCCESS"
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
    
    return "$SUCCESS"
}

# __parser_check_examples__code_placeholder <placeholder>
# Check whether a placeholder is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <piece> is valid
#   - $PARSER_INVALID_TOKENS_CODE otherwise
#
# Notes:
#   - <placeholder> should not contain trailing \n
#   - escaping is not checked
__parser_check_examples__code_placeholder() {
    declare in_placeholder="$1"

    # shellcheck disable=2155
    declare pieces="$(__parser_tokens__all_unbalanced "$in_placeholder" "|")"
    # shellcheck disable=2155
    declare piece_count="$(parser_tokens__count "$pieces")"
    declare -i index=0

    # shellcheck disable=2155
    while ((index < piece_count)); do
        declare piece="$(parser_tokens__value "$pieces" "$index")"
        __parser_check_examples__code_placeholder_piece "$piece" || return "$PARSER_INVALID_TOKENS_CODE"
        index+=1
    done

    return "$SUCCESS"
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
    return "$SUCCESS"
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

    return "$SUCCESS"
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
    
    return "$SUCCESS"
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
    return "$SUCCESS"
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
    echo -n "$(sed -E 's/^ +//' <<< "${in_piece:description_length}")"
    return "$SUCCESS"
}

# parser_check_examples__allows_alternative_expansion <content> <index>
# Check whether an example allows expansion.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <content> is valid and expansion is allowed
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_NOT_ALLOWED_CODE if repetition is not allowed
#   
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_check_examples__allows_alternative_expansion() {
    declare in_content="$1"
    declare -i in_index="$2"

    declare description_tokens=
    declare code_tokens=
    description_tokens="$(parser_examples__description_alternative_tokens_at "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    code_tokens="$(parser_examples__code_placeholder_tokens_at "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare -i description_tokens_count="$(parser_tokens__count "$description_tokens")"
    # shellcheck disable=2155
    declare -i code_tokens_count="$(parser_tokens__count "$code_tokens")"
    declare -i index=0
    declare -i alternative_count=0
    declare description_alternative=
    
    while ((index < description_tokens_count && alternative_count < 1)); do
        [[ "$(parser_tokens__type "$description_tokens" "$index")" == CONSTRUCT ]] && {
            description_alternative="$(parser_tokens__value "$description_tokens" "$index")"
            alternative_count+=1
        }
        index+=1
    done

    ((alternative_count == 1)) || return "$PARSER_NOT_ALLOWED_CODE"
    # shellcheck disable=2155
    declare alternative_pieces="$(__parser_tokens__all_unbalanced "$description_alternative" "|")"
    (("$(parser_tokens__count "$alternative_pieces")" < 2)) && return "$PARSER_INVALID_TOKENS_CODE"
    # shellcheck disable=2155
    declare -i alternative_piece_count="$(parser_tokens__count "$(parser_examples__description_alternative_token_pieces "$description_alternative")")"
    index=0
    declare -i conforming_placeholder_count=0

    # shellcheck disable=2155
    while ((index < code_tokens_count && conforming_placeholder_count < 1)); do
        declare token_type="$(parser_tokens__type "$code_tokens" "$index")"
        declare token_value="$(parser_tokens__value "$code_tokens" "$index")"
        declare -i token_piece_count="$(parser_tokens__count "$(parser_examples__code_placeholder_token_pieces "$token_value")")"

        if [[ "$token_type" == CONSTRUCT ]] && ((token_piece_count == alternative_piece_count)); then
            __parser_check_examples__code_placeholder "$token_value"
            declare -i status="$?"

            if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
                ((status == 0)) || return "$status"
            fi

            conforming_placeholder_count+=1
        fi
        
        index+=1
    done

    ((conforming_placeholder_count == 1)) || return "$PARSER_NOT_ALLOWED_CODE"
    return "$SUCCESS"
}

# __parser_examples__description_singular_alternative_token_index <content> <index>
# Output a singular alternative when an alternative expansion is possible.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <content> is valid and expansion is allowed
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_NOT_ALLOWED_CODE if repetition is not allowed
#   
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
__parser_examples__description_singular_alternative_token_index() {
    declare in_content="$1"
    declare -i in_index="$2"

    parser_check_examples__allows_alternative_expansion "$in_content" "$in_index"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare tokens="$(parser_examples__description_alternative_tokens_at "$in_content" "$in_index")"
    # shellcheck disable=2155
    declare token_count="$(parser_tokens__count "$tokens")"
    declare -i index=0

    while ((index < token_count)); do
        [[ "$(parser_tokens__type "$tokens" "$index")" == CONSTRUCT ]] && {
            echo -n "$index"
            return "$SUCCESS"
        }

        index+=1
    done

    return "$SUCCESS"
}

# __parser_examples__description_singular_placeholder_token_index <content> <index>
# Output a singular alternative when an alternative expansion is possible.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <content> is valid and expansion is allowed
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_NOT_ALLOWED_CODE if repetition is not allowed
#   
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
__parser_examples__description_singular_placeholder_token_index() {
    declare in_content="$1"
    declare -i in_index="$2"

    declare -i alternative_index=
    alternative_index="$(__parser_examples__description_singular_alternative_token_index "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare alternative_pieces="$(parser_tokens__value "$(parser_examples__description_alternative_tokens_at "$in_content" "$in_index")" "$alternative_index")"
    # shellcheck disable=2155
    declare alternative_piece_count="$(parser_tokens__count "$(__parser_tokens__all_unbalanced "$alternative_pieces" "|")")"
    # shellcheck disable=2155
    declare code_tokens="$(parser_examples__code_placeholder_tokens_at "$in_content" "$in_index")"
    # shellcheck disable=2155
    declare -i code_token_count="$(parser_tokens__count "$code_tokens")"
    declare -i index=0

    # shellcheck disable=2155
    while ((index < code_token_count)); do
        declare token_type="$(parser_tokens__type "$code_tokens" "$index")"
        declare token_value="$(parser_tokens__value "$code_tokens" "$index")"

        if [[ "$token_type" == CONSTRUCT ]]; then
            declare placeholder_pieces="$(__parser_tokens__all_unbalanced "$token_value" "|")"
            declare placeholder_piece_count="$(parser_tokens__count "$placeholder_pieces")"
            ((placeholder_piece_count == alternative_piece_count)) && echo -n "$index"
        fi

        index+=1
    done

    return "$SUCCESS"
}

# __parser_examples__token_definition <token> <token-value>
# Output a token definition.
#
# Output:
#   <token-definition>
#
# Return:
#   - 0 always
#
# Notes:
#   - <token> and <token-value> should not contain trailing \n
__parser_examples__token_definition() {
    declare in_token="$1"
    declare in_token_value="$2"

    if [[ "$in_token" == CONSTRUCT ]]; then
        echo -n "{$in_token_value}"
    else
        echo -n "$in_token_value"
    fi

    return "$SUCCESS"
}

# parser_examples__expand_at <content> <index>
# Output an expanded example.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <content> is valid and expansion is allowed
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_NOT_ALLOWED_CODE if repetition is not allowed
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__expand_at() {
    declare in_content="$1"
    declare -i in_index="$2"

    declare -i description_alternative_index=
    description_alternative_index="$(__parser_examples__description_singular_alternative_token_index "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    declare -i code_placeholder_index=
    code_placeholder_index="$(__parser_examples__description_singular_placeholder_token_index "$in_content" "$in_index")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    # shellcheck disable=2155
    declare description_tokens="$(parser_examples__description_alternative_tokens_at "$in_content" "$in_index")"
    # shellcheck disable=2155
    declare code_tokens="$(parser_examples__code_placeholder_tokens_at "$in_content" "$in_index")"
    # shellcheck disable=2155
    declare description_alternative_value="$(parser_tokens__value "$description_tokens" "$description_alternative_index")"
    # shellcheck disable=2155
    declare code_placeholder_value="$(parser_tokens__value "$code_tokens" "$code_placeholder_index")"
    # shellcheck disable=2155
    declare description_alternative_pieces="$(__parser_tokens__all_unbalanced "$description_alternative_value" "|")"
    # shellcheck disable=2155
    declare code_placeholder_pieces="$(__parser_tokens__all_unbalanced "$code_placeholder_value" "|")"
    # shellcheck disable=2155
    declare -i pieces_count="$(parser_tokens__count "$description_alternative_pieces")"
    declare -i piece_index=0

    # shellcheck disable=2155
    while ((piece_index < pieces_count)); do
        declare generated_description=
        declare generated_code=
        declare -i index=0

        while ((index < description_alternative_index)); do
            generated_description+="$(parser_tokens__value "$description_tokens" "$index")"
            index+=1
        done

        generated_description+="$(parser_tokens__value "$description_alternative_pieces" "$piece_index")"
        index+=1

        while ((index < "$(parser_tokens__count "$description_tokens")")); do
            generated_description+="$(parser_tokens__value "$description_tokens" "$index")"
            index+=1
        done

        declare -i index=0
        
        while ((index < code_placeholder_index)); do
            declare token_type="$(parser_tokens__type "$code_tokens" "$index")"
            declare token_value="$(parser_tokens__value "$code_tokens" "$index")"
            generated_code+="$(__parser_examples__token_definition "$token_type" "$token_value")"
            index+=1
        done

        generated_code+="{$(parser_tokens__value "$code_placeholder_pieces" "$piece_index")}"
        index+=1

        while ((index < "$(parser_tokens__count "$code_tokens")")); do
            declare token_type="$(parser_tokens__type "$code_tokens" "$index")"
            declare token_value="$(parser_tokens__value "$code_tokens" "$index")"
            generated_code+="$(__parser_examples__token_definition "$token_type" "$token_value")"
            index+=1
        done

        echo -n '- '
        # shellcheck disable=2016
        printf '%s:\n\n`%s`\n\n' "$generated_description" "$generated_code"
        piece_index+=1
    done

    return "$SUCCESS"
}

# parser_examples__expanded_or_original_at <content> <index>
# Output an expanded example or original if expansion is not possible.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <content> is valid and expansion is allowed
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__expanded_or_original_at() {
    declare in_content="$1"
    declare -i in_index="$2"

    declare example=
    example="$(parser_examples__expand_at "$in_content" "$in_index")"
    declare -i status="$?"

    # shellcheck disable=2155
    if ((status != 0)); then
        declare original_description="$(parser_examples__description_at "$in_content" "$in_index")"
        declare original_code="$(parser_examples__code_at "$in_content" "$in_index")"
        echo -n '- '
        # shellcheck disable=2016
        printf '%s:\n\n`%s`\n\n' "$original_description" "$original_code"
    else
        echo "$example"
        echo
    fi

    return "$SUCCESS"
}

# parser_examples__expand_all <content>
# Output a expanded examples.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <content> is valid and expansion is allowed
#   - $PARSER_INVALID_CONTENT_CODE if <content> is invalid
#   - $PARSER_NOT_ALLOWED_CODE if repetition is not allowed
#
# Notes:
#   - <content> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_examples__expand_all() {
    declare in_content="$1"

    declare -i index=0

    declare example_count=
    example_count="$(parser_examples__count "$in_content")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    while ((index < example_count)); do
        parser_examples__expanded_or_original_at "$in_content" "$index"
        index+=1
    done

    return "$SUCCESS"
}



# __parser_check_ranges__content <range>
# Check whether a range is valid.
#
# Output:
#   <empty-string>
#
# Return:
#   - 0 if <range> is valid
#   - $PARSER_INVALID_EXAMPLES_CODE otherwise
#
# Notes:
#   - <content> should not contain trailing \n
__parser_check_ranges__content() {
    declare in_range="$1"

    # shellcheck disable=2016
    sed -nE '/^([[:digit:]]+\.\.|\.\.[[:digit:]]+|[[:digit:]]+\.\.[[:digit:]]+)$/! Q1' <<<"$in_range" ||
        return "$PARSER_INVALID_EXAMPLES_CODE"
    
    return "$SUCCESS"
}

# parser_ranges__from_or_default <range>
# Output a range lowest bound or default.
#
# Output:
#   <lowest-bound>
#
# Return:
#   - 0 if <range> is valid
#   - $PARSER_INVALID_EXAMPLES_CODE otherwise
#
# Notes:
#   - <range> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_ranges__from_or_default() {
    declare in_range="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_ranges__content "$in_range" || return "$PARSER_INVALID_EXAMPLES_CODE"
    fi

    sed -E 's/^\.\.[[:digit:]]+$/0/
        s/^([[:digit:]]+)\.\.([[:digit:]]+)?$/\1/' <<<"$in_range"
}

# parser_ranges__to_or_default <range>
# Output a range highest bound or default.
#
# Output:
#   <highest-bound>
#
# Return:
#   - 0 if <range> is valid
#   - $PARSER_INVALID_EXAMPLES_CODE otherwise
#
# Notes:
#   - <range> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_ranges__to_or_default() {
    declare in_range="$1"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        __parser_check_ranges__content "$in_range" || return "$PARSER_INVALID_EXAMPLES_CODE"
    fi

    sed -E 's/^[[:digit:]]+\.\.$/infinity/
        s/^([[:digit:]]+)?\.\.([[:digit:]]+)$/\2/' <<<"$in_range"
}



# parser_converters__code_placeholder_piece_to_rendered <piece> [<option-style>]
# Output a rendered placeholder piece.
#
# Output:
#   <rendered-piece>
#
# Return:
#   - 0 if <range> is valid
#   - $PARSER_INVALID_TOKENS_CODE if <piece> is invalid
#   - $PARSER_INVALID_ARGUMENT_CODE if <option-style> is invalid
#
# Notes:
#   - <piece> should not contain trailing \n
#   - checks are performed just when $CHECK environment variable is not empty and is zero
parser_converters__code_placeholder_piece_to_rendered() {
    declare in_piece="$1"
    declare in_option_style="${2:-short}"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        [[ ! "$in_option_style" =~ ^(short|long)$ ]] && return "$PARSER_INVALID_ARGUMENT_CODE"
    fi

    declare type=
    type="$(parser_examples__code_placeholder_piece_type "$in_piece")"
    declare -i status="$?"

    if [[ -n "$CHECK" ]] && ((CHECK == 0)); then
        ((status == 0)) || return "$status"
    fi

    CHECK=
    # shellcheck disable=2155
    declare description="$(parser_examples__code_placeholder_piece_description "$in_piece")"
    declare rendered=

    # shellcheck disable=2155
    case "$type" in
        bool|int|float|char|command)
            rendered="$(sed -E 's/ +/_/g' <<<"$description")"
        ;;
        string|any)
            rendered="\"$(sed -E 's/ +/_/g' <<<"$description")\""
        ;;
        option)
            declare examples="$(parser_examples__code_placeholder_piece_examples "$in_piece")"
            [[ ! "$examples" =~ ^[^,]+,[^,]+$ ]] && return "$PARSER_INVALID_EXAMPLES_CODE"
            
            case "$in_option_style" in
                short)
                    rendered="$(sed -E 's/^[^,]+,([^,]+)$/\1/g' <<<"$examples")"
                ;;
                long)
                    rendered="$(sed -E 's/^([^,]+),[^,]+$/\1/g' <<<"$examples")"
                ;;
            esac

            rendered="$(sed -E 's/^ +//
                s/ +$//g' <<<"$rendered")"
        ;;
        file|directory|/?file|/?directory)
            type="$(sed -E 's|^/\?||' <<<"$type")"
            rendered="\"path/to/$(sed -E 's/ +/_/g' <<<"$description")_$type\""
        ;;
        path|/?path)
            rendered="\"path/to/$(sed -E 's/ +/_/g' <<<"$description")_file|path/to/$(sed -E 's/ +/_/g' <<<"$description")_directory\""
        ;;
        /file|/directory)
            type="$(sed -E 's|^/||' <<<"$type")"
            rendered="\"/path/to/$(sed -E 's/ +/_/g' <<<"$description")_$type\""
        ;;
        /path)
            rendered="\"/path/to/$(sed -E 's/ +/_/g' <<<"$description")_file|/path/to/$(sed -E 's/ +/_/g' <<<"$description")_directory\""
        ;;
        remote-file|remote-directory|/?remote-file|/?remote-directory)
            type="$(sed -E 's|^(/\?)?remote-||' <<<"$type")"
            rendered="\"remote/path/to/$(sed -E 's/ +/_/g' <<<"$description")_$type\""
        ;;
        remote-path|/?remote-path)
            rendered="\"remote/path/to/$(sed -E 's/ +/_/g' <<<"$description")_file|remote/path/to/$(sed -E 's/ +/_/g' <<<"$description")_directory\""
        ;;
        /remote-file|/remote-directory)
            type="$(sed -E 's|^/remote-||' <<<"$type")"
            rendered="\"/remote/path/to/$(sed -E 's/ +/_/g' <<<"$description")_$type\""
        ;;
        /remote-path)
            rendered="\"/remote/path/to/$(sed -E 's/ +/_/g' <<<"$description")_file|/remote/path/to/$(sed -E 's/ +/_/g' <<<"$description")_directory\""
        ;;
        remote-any)
            type="$(sed -E 's|^remote-||' <<<"$type")"
            rendered="\"remote $(sed -E 's/ +/_/g' <<<"$description")\""
        ;;
    esac

    echo "$rendered"
    return "$SUCCESS"
}
