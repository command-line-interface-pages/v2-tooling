% MD-TO-CLIP(1) md-to-clip 2.15.0
% Emily Grace Seville
% February 2023

# NAME

md-to-clip - convert from TlDr format to Command Line Interface Pages format

# SYNOPSIS

**md-to-clip** *--help*|*-h*  
**md-to-clip** *--version*|*-v*  
**md-to-clip** *--author*|*-a*  
**md-to-clip** *--email*|*-e*  
**md-to-clip** *--no-file-save*|*-nfs*  
**md-to-clip** [*--output-directory*|*-od* *DIRECTORY*] [*--special-placeholder-config*|*-spc* *FILE.yaml*] <FILE.md FILE2.md ...>

# DESCRIPTION

**md-to-clip** converts pages in the following manner:

- summary:
  - all tags: removes trailing dot
  - *More information*: removes angle brackets
  - *See also*:
    - removes spaces around commas
    - removes *or* keyword
    - removes backticks around command names
- code description:
  - I/O streams:
    - replaces all references with *stdin*/*stdout*/*stderr*
    - removes backticks around references
  - rewording: replaces *given*/*specified* with *specific*
- code example:
  - placeholders:
    - removes *{{...}}*
    - expands placeholders ending with *(s)* or something like *{1,2,...}* like
      *{{file(s)}}* to placeholders with asterisk quantifier like
      *{file\* file}*
    - converts special placeholders defined in *$HOME/.md-to-clip.yaml*
    - converts integer, float, option, device, path, file, directory, boolean
      character and string placeholders
    - expands placeholders with *one_or_more*/*two_or_more*/.../*nine_or_more*
      like **{{one_or_more_files}}* to placeholders with range quantifier like
      *{/?file 2.. some description}*

All placeholders are required by default as there is no standardized way in TlDr
to present optional placeholders. Most TlDr placeholders with alternatives like
*{{boolean|integer}}* are recognized as strings.

# EXAMPLES

*md-to-clip --help*
: Display help

*md-to-clip --no-file-save sed.md*
: Convert sed page

*md-to-clip sed.md*
: Convert sed page and save it to sed.clip in the folder with the input file

*md-to-clip --output-directory ~/Documents sed.md*
: Convert sed page and save it to ~/Documents/sed.clip

# BUGS

https://github.com/command-line-interface-pages/v2-tooling/tree/main/md-to-clip

# EXIT VALUES

*0*
: Success

*1*
: Failure

# COPYRIGHT

Copyright ©️ 2023 Emily Grace Seville
