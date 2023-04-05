# Toolkit

![ci-status](https://img.shields.io/github/actions/workflow/status/command-line-interface-pages/v2-tooling/ci.yaml?style=flat-square)
[![help-wanted-issues](https://img.shields.io/github/issues/command-line-interface-pages/v2-tooling/help%20wanted?color=orange&style=flat-square)][help-wanted-issues]
[![goals](https://img.shields.io/badge/Current-goals-a32236?labelColor=ed425c&style=flat-square)][goals]

Toolkit for [v2][syntax] syntax.

[goals]: https://command-line-interface-pages.github.io/site.github.io/goals/#introduction-%E2%84%B9
[help-wanted-issues]: https://github.com/command-line-interface-pages/v2-tooling/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22
[syntax]: https://github.com/command-line-interface-pages/syntax/blob/main/base.md

## Quick introduction :rocket:

To get help for `cat` command with default theme type `clip-view cat`. If you
need a more beautiful output you can use
[this](https://github.com/command-line-interface-pages/themes/tree/main/awesome)
theme like this: `clip-view --theme awesome cat`

![clip page](./clip-page.png)

Theme is a YAML file itself.

There are several tools available for now:

- [parser](clip-parse/)
- [renderer](clip-view/)
- [converter from TlDr format](md-to-clip/)
- [converter to TlDr format](clip-to-md/)
- [placeholder syntax explainer](clip-ask/)

## Writing scripts :hammer_and_wrench:

Read [this](./CONTRIBUTING.md) guide for details.
