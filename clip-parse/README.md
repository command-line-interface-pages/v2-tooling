# Command Line Interface Pages parser

Command Line Interface Pages parser.

## Prerequisites

- [GNU Make][make]

[make]: https://www.gnu.org/software/make/manual/

## Installation :smile:

Download installer as a temporary file and execute commands to download and
install parser with its man page:

```bash
make -f <(wget -O - https://raw.githubusercontent.com/command-line-interface-pages/v2-tooling/main/clip-parse/makefile 2> /dev/null) remote-install
```

Download installer as a `installer` file and execute commands to download and
install parser with its man page:

```bash
wget -O installer https://raw.githubusercontent.com/command-line-interface-pages/v2-tooling/main/clip-parse/makefile
make -f installer remote-install
```

> :information_source: Note: prefer the second way to install if you want to
> be able to easily uninstall parser with its man page.

## Uninstallation :disappointed:

Execute commands to uninstall parser with its man page:

```bash
make -f installer uninstall
```

## Examples :books:

Input Command Line Interface Page:

```md
# [

> Check file types and compare values
> Returns 0 if the condition evaluates to true, 1 if it evaluates to false
> More information: https://www.gnu.org/software/bash/manual/bash.html#index-test

- Test if a specific variable is (equal|not equal) to a string:

`[ "{string $variable: $foo}" {string operator: ==|string operator !=} "{string string: Hello world!}" ]`

- Test if a specific variable is ([eq]ual|[n]ot [e]qual|[g]reater [t]han|[l]ess [t]han|[g]reater than or [e]qual|[l]ess than or [e]qual) to a number:

`[ "{string $variable: $foo}" {string operator: -eq|string operator: -ne|string operator: -gt|string operator: -lt|string operator: -ge|string operator: -le} {string number: 1} ]`

- Test if a specific variable has (an empty|a [n]on-empty) value:

`[ {string operator: -z|string operator: -n} "{string $variable: $foo}" ]`

- Test if a specific [f]ile exists:

`[ -f {/?file some: ~/.bashrc} ]`

- Test if a specific [d]irectory exists:

`[ -d {/?directory some: images} ]`

- Test if a specific file or directory [e]xists:

`[ -e {/?path some: ~/.bashrc} ]`
```

Let's say we put it in `$page` variable.

### Basic usage

- :question: **question** How to get a page header?  
  :bulb: **answer**

  ```bash
  parser__header_prettified "$page"
  ```

  :checkered_flag: **output**

  ```md
  [
  ```

- :question: **question** How to get a page description?  
  :bulb: **answer**

  ```bash
  parser_summary__description_prettified "$page"
  ```

  :checkered_flag: **output**

  ```md
  Check file types and compare values
  Returns 0 if the condition evaluates to true, 1 if it evaluates to false
  ```

- :question: **question** How to get an example description?  
  :bulb: **answer**

  ```bash
  parser_examples__description_prettified_at "$page" 0
  ```

  :checkered_flag: **output**

  ```md
  Test if a specific variable is (equal|not equal) to a string
  ```

- :question: **question** How to get an example code?  
  :bulb: **answer**

  ```bash
  parser_examples__code_prettified_at "$page" 0
  ```

  :checkered_flag: **output**

  ```md
  [ "{string $variable: $foo}" {string operator: ==|string operator: !=} "{string string: Hello world!}" ]
  ```

- :question: **question** How to get tokens for alternatives?  
  :bulb: **answer**

  ```bash
  parser_examples__description_alternative_tokens_at "$page" 0
  ```

  :checkered_flag: **output**

  ```md
  LITERAL
  Test if a specific variable is 
  CONSTRUCT
  equal|not equal
  LITERAL
   to a string
  ```

- :question: **question** How to get tokens for mnemonics?  
  :bulb: **answer**

  ```bash
  parser_examples__description_mnemonic_tokens_at "$page" 2
  ```

  :checkered_flag: **output**

  ```md
  LITERAL
  Test if a specific variable has (an empty|a 
  CONSTRUCT
  n
  LITERAL
  on-empty) value
  ```

- :question: **question** How to get tokens for placeholders?  
  :bulb: **answer**

  ```bash
  parser_examples__code_placeholder_tokens_at "$page" 0
  ```

  :checkered_flag: **output**

  ```md
  LITERAL
  [ "
  CONSTRUCT
  string $variable: $foo
  LITERAL
  " 
  CONSTRUCT
  string operator: ==|string operator !=
  LITERAL
   "
  CONSTRUCT
  string string: Hello world!
  LITERAL
  " ]
  ```

### Advanced usage

- :question: **question** How to get a token count?  
  :bulb: **answer**

  ```bash
  parser_tokens__count "$(parser_examples__description_alternative_tokens_at "$page" 0)"
  ```

  :checkered_flag: **output**

  ```md
  3
  ```

- :question: **question** How to get a token value?  
  :bulb: **answer**

  ```bash
  parser_tokens__value "$(parser_examples__description_alternative_tokens_at "$page" 0)" 0
  ```

  :checkered_flag: **output**

  ```md
  Test if a specific variable is 
  ```

- :question: **question** How to get a token type?  
  :bulb: **answer**

  ```bash
  parser_tokens__type "$(parser_examples__description_alternative_tokens_at "$page" 0)" 0
  ```

  :checkered_flag: **output**

  ```md
  LITERAL
  ```

- :question: **question** How to get pieces (parts listed via unescaped `|`) for an alternative?  
  :bulb: **answer**

  ```bash
  value="$(parser_tokens__value "$(parser_examples__description_alternative_tokens_at "$page" 0)" 1)"
  parser_examples__description_alternative_token_pieces "$value"
  ```

  :checkered_flag: **output**

  ```md
  CONSTRUCT
  equal
  CONSTRUCT
  not equal
  ```

- :question: **question** How to get pieces (parts listed via unescaped `|`) for a placeholder?  
  :bulb: **answer**

  ```bash
  value="$(parser_tokens__value "$(parser_examples__code_placeholder_tokens_at "$page" 0)" 3)"
  parser_examples__code_placeholder_token_pieces "$value"
  ```

  :checkered_flag: **output**

  ```md
  CONSTRUCT
  string operator: ==
  CONSTRUCT
  string operator: !=
  ```

- :question: **question** How to get a placeholder piece type?  
  :bulb: **answer**

  ```bash
  value="$(parser_tokens__value "$(parser_examples__code_placeholder_tokens_at "$page" 0)" 1)"
  parser_examples__code_placeholder_piece_type "$value"
  ```

  :checkered_flag: **output**

  ```md
  string
  ```

- :question: **question** How to get a lowest range boundary?  
  :bulb: **answer**

  ```bash
  parser_ranges__from_or_default "2..4"
  ```

  :checkered_flag: **output**

  ```md
  2
  ```

- :question: **question** How to get a rendered placeholder piece?  
  :bulb: **answer**

  ```bash
  value="$(parser_tokens__value "$(parser_examples__code_placeholder_tokens_at "$page" 0)" 1)"
  parser_converters__code_placeholder_piece_to_rendered "$value" # as this placeholder contains just one piece this code works
  ```

  :checkered_flag: **output**

  ```md
  "$variable"
  ```
