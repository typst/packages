#import "@preview/tidy:0.4.3"

#show heading.where(level: 2): block.with(above: 3em, below: 2em)

#show heading.where(level: 4): it => {
  block(
    above: 1.5em,
    below: 0.8em,
    [
      #line(length: 100%, stroke: (paint: luma(200), thickness: 0.5pt))
      #v(0.4em)
      #text(font: "Menlo", it.body)
    ]
  )
}

#let show-module = tidy.show-module.with(
  sort-functions: false,
  first-heading-level: 3,
  show-outline: false,
)

#let doc-module(path, name, prefix) = {
  let docs = tidy.parse-module(
    read(path),
    name: name,
    label-prefix: prefix,
    old-syntax: true,
    enable-curried-functions: true,
  )

  show-module(docs)
  pagebreak(weak: true)
}

= distro

A pure Typst library for probability distributions and their associated functions (PDF/PMF, CDF, sampling, mean, variance).

== Discrete Distributions

#doc-module("../distribution/bernoulli.typ", "Bernoulli", "bernoulli")
#doc-module("../distribution/binomial.typ", "Binomial", "binomial")
#doc-module("../distribution/categorical.typ", "Categorical", "categorical")
#doc-module("../distribution/geometric.typ", "Geometric", "geometric")
#doc-module("../distribution/poisson.typ", "Poisson", "poisson")
#doc-module("../distribution/discrete-uniform.typ", "Discrete Uniform", "discrete-uniform")

== Continuous Distributions

#doc-module("../distribution/beta.typ", "Beta", "beta")
#doc-module("../distribution/exponential.typ", "Exponential", "exponential")
#doc-module("../distribution/gamma.typ", "Gamma", "gamma")
#doc-module("../distribution/normal.typ", "Normal", "normal")
#doc-module("../distribution/continuous-uniform.typ", "Continuous Uniform", "continuous-uniform")

== Helper Functions

#doc-module("../function/beta.typ", "Beta Function", "beta-func")
#doc-module("../function/gamma.typ", "Gamma Function", "gamma-func")
