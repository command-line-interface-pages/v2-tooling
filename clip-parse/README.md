# Command Line Interface Pages parser

Command Line Interface Pages parser.

## Features :rocket:

- Almost complete [v2.7.0 syntax](https://github.com/command-line-interface-pages/syntax/blob/main/base.md) support except:
  - escaping comma in placeholder examples
  - range expansion in placeholder examples

## Examples :books:

Input Command Line Interface Page:

```md
# [

> Check file types and compare values
> Returns 0 if the condition evaluates to true, 1 if it evaluates to false
> More information: https://www.gnu.org/software/bash/manual/bash.html#index-test

- Test if a specific variable is (equal|not equal) to a string:

`[ "${string variable: foo}" {string operator: ==|string operator !=} "{string string: Hello world!}" ]`

- Test if a specific variable is ([eq]ual|[n]ot [e]qual|[g]reater [t]han|[l]ess [t]han|[g]reater than or [e]qual|[l]ess than or [e]qual) to a number:

`[ "${string variable: foo}" {string operator: -eq|string operator: -ne|string operator: -gt|string operator: -lt|string operator: -ge|string operator: -le} {string number: 1} ]`

- Test if a specific variable has (an empty/a [n]on-empty) value:

`[ {string operator: -z|string operator: -n} "${string variable: foo}" ]`

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
  parser__header "$page"
  ```

- :question: **question** How to get a page description?  
  :bulb: **answer**

  ```bash
  parser_summary__description "$page"
  ```

- :question: **question** How to get an example description?  
  :bulb: **answer**

  ```bash
  parser_examples__description_at "$page" 0
  ```

- :question: **question** How to get an example code?  
  :bulb: **answer**

  ```bash
  parser_examples__code_at "$page" 0
  ```

- :question: **question** How to get tokens for alternatives?  
  :bulb: **answer**

  ```bash
  parser_examples__description_alternative_tokens_at "$page" 0
  ```

- :question: **question** How to get tokens for mnemonics?  
  :bulb: **answer**

  ```bash
  parser_examples__description_mnemonic_tokens_at "$page" 0
  ```

- :question: **question** How to get tokens for placeholders?  
  :bulb: **answer**

  ```bash
  parser_examples__code_placeholder_tokens_at "$page" 0
  ```

### Advanced usage

- :question: **question** How to get a token count?  
  :bulb: **answer**

  ```bash
  parser_tokens__count "$(parser_examples__description_alternative_tokens_at "$page" 0)"
  ```

- :question: **question** How to get a token value?  
  :bulb: **answer**

  ```bash
  parser_tokens__value "$(parser_examples__description_alternative_tokens_at "$page" 0)" 0
  ```

- :question: **question** How to get a token type?  
  :bulb: **answer**

  ```bash
  parser_tokens__type "$(parser_examples__description_alternative_tokens_at "$page" 0)" 0
  ```

- :question: **question** How to get pieces (parts listed via unescaped `|`) for alternatives?  
  :bulb: **answer**

  ```bash
  value="$(parser_tokens__value "$(parser_examples__description_alternative_tokens_at "$page" 0)" 1)"
  parser_examples__description_alternative_token_pieces "$value"
  ```

- :question: **question** How to get pieces (parts listed via unescaped `|`) for placeholder?  
  :bulb: **answer**

  ```bash
  value="$(parser_tokens__value "$(parser_examples__code_placeholder_tokens_at "$page" 0)" 3)"
  parser_examples__code_placeholder_token_pieces "$value"
  ```

- :question: **question** How to get placeholder type?  
  :bulb: **answer**

  ```bash
  value="$(parser_tokens__value "$(parser_examples__code_placeholder_tokens_at "$page" 0)" 1)"
  parser_examples__code_placeholder_piece_type "$value"
  ```
