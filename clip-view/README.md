# Render for Command Line Interface Pages pages

Render for Command Line Interface Pages pages.

## Example

Input TlDr page:

```md
# sed

> Edit text in a scriptable manner
> Aliases: test
> See also: awk, ed
> More information: https://www.gnu.org/software/sed/manual/sed.html

- Replace all "apple" (basic regex) occurrences with "mango" (basic regex) in all input lines and print the result to stdout:

`{string command: cat sample.txt} | sed {file+ input: sample.txt} 's/apple/mango/g'`

- Execute a specific script [f]ile and print the result to stdout:

`{string command: cat sample.txt} | sed -f {file script: sample.sed}`

- Replace all "apple" ([E]xtended regex) occurrences with "APPLE" (extended regex) in all input lines and print the result to stdout:

`{string command: cat sample.txt} | sed -E 's/(apple)/\U\1/g'`

- Print just a first line to stdout:

`{string command: cat sample.txt} | sed -n '1p'`

- Replace all `apple` (basic regex) occurrences with `mango` (basic regex) in all input lines and save modifications to a specific file:

`sed -i 's/apple/mango/g' {file output: sample.txt}`

```

Output:

![page](./screenshot.jpg)
