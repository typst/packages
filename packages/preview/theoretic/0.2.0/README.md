# Theoretic

> Opinionated tool to typeset theorems, lemmas and such

Example Usage:
```typ
  #import "@preview/theoretic:0.2.0" as theoretic: theorem, proof, qed

  // Otherwise, references won't work.
  #show ref: theoretic.show-ref

  // set up your needed presets
  #let corollary = theorem.with(kind: "corollary", supplement: "Corollary")
  #let example = theorem.with(kind: "example", supplement: "Example", number: none)
  // ..etc

  // use
  #theorem(title: [Important Theorem])[#lorem(5)]
  #corollary[#lorem(5)]
  #example[#lorem(5)]
  // ..etc
```

## Features: Overview
- No "setup" is necessary.
  All configuration is achieved via parameters on the `theorem` function.
- Automatic numbering.
- Flexible References via specific supplements.
- Custom outlines: Outline for headings _and/or_ theorems.
  - Filter for specific kinds of theorem to create e.g. a list of definitions.
  - Optionally sorted alphabetically!
  - Theorems can have a different title for outlines and can even have multiple entries in a sorted outline.
- Exercise solutions
- Automatic QED placement!
- Any theorem can be restated.

Please see the PDF manual for more details.

## Manual

<!-- [![first page of the documentation](https://github.com/nleanba/typst-theoretic/raw/refs/heads/main/preview.svg)](https://github.com/nleanba/typst-theoretic/blob/main/main.pdf)
[Full Manual →](https://github.com/nleanba/typst-theoretic/blob/main/main.pdf) -->

[![first page of the documentation](https://github.com/nleanba/typst-theoretic/raw/refs/tags/v0.2.0/preview.svg)](https://github.com/nleanba/typst-theoretic/blob/v0.2.0/main.pdf)
[Full Manual →](https://github.com/nleanba/typst-theoretic/blob/v0.2.0/main.pdf)

## Feedback
Have you encountered a bug? [Please report it as an issue in my github repository.](https://github.com/nleanba/typst-theoretic/issues)

Has this package been useful to you? [I am always happy when someone gives me a ~~sticker~~ star⭐](https://github.com/nleanba/typst-theoretic)
