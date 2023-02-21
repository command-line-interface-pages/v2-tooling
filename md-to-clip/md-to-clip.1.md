% MD-TO-CLIP(1) md-to-clip 2.0.7
% Emily Grace Seville
% February 2023

# NAME

md-to-clip - convert from TlDr format to Command Line Interface Pages format

# SYNOPSIS

**md-to-clip** *--help*|*-h*\
**md-to-clip** *--version*|*-v*\
**md-to-clip** *--author*|*-a*\
**md-to-clip** *--email*|*-e*\
**md-to-clip** *--no-file-save*|*-nfs*\
**md-to-clip** [*--output-directory*|*-od* *DIRECTORY*] [*--special-placeholder-config*|*-spc* *FILE.yaml*] <FILE.md FILE2.md ...>

# DESCRIPTION

**md-to-clip** converts pages in the following manner:

- removes trailing dots in summary description and after tag values
- removes backticks around *See also* tag value
- removes *or* keyword from *See also* tag value
- converts I/O stream references in example descriptions to *stdin*/*stdout*/*stderr*
- converts *a*/*the* *given*/*specified* with *a specific*
- removes *{{...}}* placeholders
- expands placeholders with *(s)*, *{1,2,...}*

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

https://github.com/command-line-interface-pages/prototypes/issues?q=is%3Aissue+is%3Aopen+label%3A%22for%3A+tldr+-%3E+clip+converter%22

# EXIT VALUES

*0*
: Success

*1*
: Failure

# COPYRIGHT
Copyright ©️ 2023 Emily Grace Seville
