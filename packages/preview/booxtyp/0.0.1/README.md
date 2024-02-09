# BooxTyp

A Typst template for books. It is inspired by a LaTeX template [ElegantBook](https://github.com/ElegantLaTeX/ElegantBook).

## Basic Usage

```typ
#import "@preview/booxtyp:0.0.1": *

#cover(
    // Book title
    [BooxType Template], 

    // Cover image
    image("coffee.jpg"),

    // Authors 
    authors: ("Isaac Fei",)
)

// Preface
#preface()[
    This is A Typst template for books.
]

// Table of contents
#outline()

// Main document starts here...

= Introduction

== Mathematical Context

The following sentance shows how to reference a theorem and make an index entry:

@thm:1 is known as #index[Fermat's Last Theorem].

State a theorem and give it a label so that you can reference it:

The `title` argument is optional. The round brackets will not be shown if the
title is not given.

#theorem(title: "Fermat's Last Theorem")[
  No three positive integers $a$, $b$, and $c$ can satisfy the equation
  $ a^n + b^n = c^n $
  for any integer value of $n$ greater than $2$.
]<thm:1>

#proof[
  I have discovered a truly marvelous proof of this, which this margin is too
  narrow to contain.
]

The templates `theorem`, `proposition`, `lemma`, `corollary`, `definition`,
`example`, `note`, `exercise` and `solution` can be used in the same way.

// References
#bibliography("references.bib", title: "References")

// Index page
#index-page()
```

## Example Document

Download example PDF document: [example.pdf](https://github.com/Isaac-Fate/typst-packages/files/14219447/example.pdf). Its typ source is in [example.typ](example/example.typ).

## License

This project is licensed under the Apache License 2.0.

See the [LICENSE](LICENSE) file for details.
