# ILLC MoL Thesis

[![status-badge](https://ci.codeberg.org/api/badges/14184/status.svg)](https://ci.codeberg.org/repos/14184)

This is a Typst port of the [official Master of Logic thesis
template](https://codeberg.org/m4lvin/illc-mol-thesis-template) of the
Institute for Logic, Language, and Computation at the University of Amsterdam.

## Preview

A preview generated from the `main` branch of this repository is [available
online as a PDF](https://foxy.codeberg.page/illc-mol-thesis/main.pdf).

## Usage

To use this template, run

```bash
typst init @preview/illc-mol-thesis:0.1.0
```

from any directory to initialize a new project.

## Functions

The following code assumes all names from this template were imported
beforehand.

```typst
#import "@preview/illc-mol-thesis:0.1.0": *
```

### `mol-thesis`

An initialization function for show rules.

```typst
#show: mol-thesis
```

### `mol-titlepage`

Renders the first page of the thesis.

```typst
#mol-titlepage(
  title: "Title of the Thesis",
  author: "John Q. Public",
  birth-date: "April 1st, 1980",
  birth-place: "Alice Springs, Australia",
  defence-date: "August 28, 2005",
  /* Only one supervisor? The singleton array ("Dr Jack Smith",) needs the
     trailing comma. */
  supervisors: ("Dr Jack Smith", "Prof Dr Jane Williams"),
  committee: (
    "Dr Jack Smith",
    "Prof Dr Jane Williams",
    "Dr Jill Jones",
    "Dr Albert Heijn"),
  degree: "MSc in Logic"
)
```

### `mol-abstract`

Renders an abstract for your thesis.

```typst
#mol-abstract[
  Your abstract here.
]
```

### `mol-chapter`

Introduces a new chapter. Replaces first level headings `=`, so section titles
within your chapter should be prefixed by `==`.

```typst
#mol-chapter("Your Chapter Title")

== Your Section Title

...
```

### `definition`, `theorem`, `lemma`, `corollary`, `remark`, `proof`

Introduces the appropriate block.

```typst
#definition[
  We defined the language $cal(L)$ as follows:

  $ phi.alt ::= top | p | phi.alt and phi.alt $
]
```

### `mathcounter`

A counter keeping all the mathematical elements of this template in sync.

```typst
#import "@preview/great-theorems:0.1.1": *

#let axiom = mathblock(
  blocktitle: "Axiom",
  counter: mathcounter, // axioms follow the same numbering as definitions, etc.
)
```

## Attributions

The original [MoL thesis template, along with the ILLC
logo](https://codeberg.org/m4lvin/illc-mol-thesis-template) by the [Institute
for Logic, Language, and Computation](https://illc.uva.nl), is released under
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).
