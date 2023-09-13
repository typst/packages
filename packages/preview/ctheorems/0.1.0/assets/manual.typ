#show raw.where(block: true): block.with(
  fill: luma(250),
  inset: 1em,
  radius: 4pt,
  width:100%,
  stroke: luma(200),
)

= Getting Started
== Introduction

The `ctheorems` package provides `typst` functions that help create numbered theorems, lemmas, corollaries, etc. The package is designed to be easy to use and customize, and it is also very lightweight.

A theorem enviorment lets you wrap content together with automatically updating numbering information. Enviorments can:

- have their own counter (e.g. Theorem 1, Example 1, etc.)
- share the same counter (e.g. Theorem 1, Lemma 2, etc.)
- be attached to another enviorment (e.g. Theorem 1, Collary 1.1, etc.)
- be attached to headings 
- have a numbering level depth fixed (for instance, use only top level heading numbers)
- be referenced elsewhere in the document
== Using `ctheorems`

First you need to install the package. Just download the `.zip` file from the github repository and extract it to your `@local` folder. Then you can import it in your document:
```typst
#import "@local/ctheorems:0.1.0": *
```
When it will get accepted as an oficial package, you will be able to import it from the `@preview` repository, aka:
```typst
#import "@preview/ctheorems:1.0.0": *
```







