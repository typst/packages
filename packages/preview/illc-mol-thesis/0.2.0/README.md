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
typst init @preview/illc-mol-thesis:0.2.0
```

from any directory to initialize a new project. If you already have a document,
just keep reading.

## Functions

The following code assumes all names from this template were imported
beforehand in all of your files. This can be accomplished using:

```typst
#import "@preview/illc-mol-thesis:0.2.0": *
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

### Mathematical block

Introduces the appropriate block. Can be any of:

- `corollary`,
- `definition`,
- `example`,
- `lemma`,
- `proof`.
- `proposition`,
- `remark`,
- `theorem`.

```typst
#definition[
  We defined the language $cal(L)$ as follows:

  $ phi.alt ::= top | p | phi.alt and phi.alt $
]
```

### `mathcounter`

A counter keeping all the mathematical elements of this template in sync.

```typst
#import "@preview/great-theorems:0.1.2": *

#let joke = mathblock(
  blocktitle: "Joke",
  counter: mathcounter, // jokes follow the same numbering as definitions, etc.
)
```

### `load-bib`

Bibliography function that does not throw an error if called multiple times.
This allows you to invoke it once per file in your thesis. This is important,
because Typst would otherwise raise an error if you were to cite a source in a
file with no bibliography. As Typst packages cannot access files in the project
directory for now, you must always use `read` when invoking `load-bib`, as shown
in the following examples.

If invoked with "true", it actually displays the bibliography.

```typst
// main.typ
#include "chapter-1.typ"
#load-bib(read("works.bib"), main: true)
```

Otherwise, it still makes the sources citable in the current file. Should
be invoked with "true" at most once.

```typst
// chapter-1.typ
We build on the work of @Author_2025.
#load-bib(read("works.bib"))
```

## Attributions

The original [MoL thesis template, along with the ILLC
logo](https://codeberg.org/m4lvin/illc-mol-thesis-template) by the [Institute
for Logic, Language, and Computation](https://illc.uva.nl), is released under
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).
