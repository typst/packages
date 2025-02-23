# Arborly

A library for producing syntax tree graphs.

## Examples

## Usage

This package requires typst 0.13

To use this package, simply add the following code to your document:

```typ
#import "@preview/arborly:0.1.0"

#let tree = ("TP", (
  ("NP", (
    ("N", "this"),
  )),
  ("VP", (
    ("V", "is"),
    ("NP", (
      ("D", "a"),
      ("N", "wug"),
    )),
  )),
))

#arborly.tree(tree)
```

For more details, see `docs/manual.pdf`

## Feedback

I'm neither a linguist nor a graphics programmer, so if you see room for improvement please make an issue.
