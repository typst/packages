# Arborly

A library for producing syntax tree graphs.

## Usage

This package requires typst 0.13

To use this package, simply add the following code to your document:

```typ
#import "@preview/arborly:0.1.1"

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

For more details and examples, see `docs/manual.pdf` in the github repository.

## Feedback

I'm neither a linguist nor a graphics programmer, so if you see room for improvement please make an issue.
