# Theoretic

> Opinionated tool to typeset theorems, lemmas and such

Example Usage:
```typ
  #import "@preview/theoretic:0.1.1" as theoretic: theorem, proof, qed

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

[Full manual: ![first page of the documentation](https://github.com/nleanba/typst-theoretic/raw/refs/tags/v0.1.1/preview.svg)](https://github.com/nleanba/typst-theoretic/blob/v0.1.1/main.pdf)