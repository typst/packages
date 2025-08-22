> [!NOTE]
> This is a [Typst](https://typst.app/) package. Click [here](https://typst.app/universe/package/stash/) to find it in the Typst Universe.


# `stash`
<div align="center">Version 0.1.0</div>

This package allows you to *stash* blocks of content and display them later.
Inspired by $\LaTeX$ [`proof-at-the-end`](https://ctan.org/pkg/proof-at-the-end).

## Getting Started

The following example illustrates how to import the package, create a stash and print it out:

```typ
#import "@preview/stash:0.1.0": *

#create-stash("proofs")

*Theorem 1:* $A = B$
#add-to-stash("proofs", [*Proof of Theorem 1*: $B = A$])

#lorem(30)

#context print-stash("proofs")
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>

Plain and simple, no additional settings!
