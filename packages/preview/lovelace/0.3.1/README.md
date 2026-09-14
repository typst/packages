# Lovelace
This is a package for writing pseudocode in [Typst](https://typst.app/).
It is named after the computer science pioneer
[Ada Lovelace](https://en.wikipedia.org/wiki/Ada_Lovelace) and inspired by the
[pseudo package](https://ctan.org/pkg/pseudo) for LaTeX.

[![toot](https://img.shields.io/badge/tutorial-toot-blue)](https://a5s.eu/toot-lovelace/)
![GitHub license](https://img.shields.io/github/license/andreasKroepelin/lovelace)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/andreasKroepelin/lovelace)
![GitHub Repo stars](https://img.shields.io/github/stars/andreasKroepelin/lovelace)

Pseudocode is not a programming language, it doesn't have strict syntax, so
you should be able to write it however you need to in your specific situation.
Lovelace lets you do exactly that.

Main features include:
- arbitrary keywords and syntax structures
- optional line numbering
- line labels
- lots of customisation with sensible defaults


## Getting started

Import the package using
```typ
#import "@preview/lovelace:0.3.1": *
```

The simplest usage is via `pseudocode-list` which transforms a nested list
into pseudocode:
```typ
#pseudocode-list[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```
resulting in:

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://a5s.eu/toot-lovelace/page2-example0-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://a5s.eu/toot-lovelace/page2-example0-light.svg">
  <img alt="simple" src="https://a5s.eu/toot-lovelace/page2-example0-light.svg">
</picture>

As you can see, every list item becomes one line of code and nested lists become
indented blocks.
There are no special commands for common keywords and control structures, you
just use whatever you like.

**To learn more about how to use and customize Lovelace,
[visit the tutorial](https://a5s.eu/toot-lovelace/).**
