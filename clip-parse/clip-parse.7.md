% CLIP-PARSE(7) clip-parse 1.4.1
% Emily Grace Seville
% February 2023

# NAME

clip-parse - parse Command Line Interface Pages

# DESCRIPTION

**clip-parse** contains several functions for parsing pages following this
naming convention:

- *parser__\**: for header handling
- *parser_summary__\**: for summary handling
- *parser_examples__\**: for example handling

These prefixes can be treated like namespaces in other programming languages.

Parser supports almost all v2.7.0 syntax (https://github.com/command-line-interface-pages/syntax/blob/main/base.md)
except:

- escaping comma in placeholder examples
- range expansion in placeholder examples

# EXAMPLES

*source clip-parse*
: Source a parser API

*parser__version*
: Get a parser version

*parser__header_prettified "$page"*
: Get a page header

*parser_summary__description_prettified "$page"*
: Get a page description

*parser_examples__description_prettified_at "$page" 0*
: Get an example description

*parser_examples__code_prettified_at "$page" 0*
: Get an example code

# BUGS

https://github.com/command-line-interface-pages/v2-tooling/tree/main/clip-parse

# COPYRIGHT

Copyright ©️ 2023 Emily Grace Seville
