#import "@preview/tidy:0.3.0"

#import "template.typ": *

#import "../src/lib.typ" as crudo

#let package-meta = toml("../typst.toml").package
// #let date = none
#let date = datetime(year: 2024, month: 5, day: 14)

#show: project.with(
  title: "Crudo",
  // subtitle: "...",
  authors: package-meta.authors.map(a => a.split("<").at(0).trim()),
  abstract: [
    _Crudo_ lets you take slices from raw blocks and more: slice, filter, transform and join the lines of raw blocks.
  ],
  url: package-meta.repository,
  version: package-meta.version,
  date: date,
)

// the scope for evaluating expressions and documentation
#let scope = (crudo: crudo)
// https://github.com/Mc-Zen/tidy/issues/21
#let preamble = "set raw(block: false, lang: none);"
#let example = (..args) => {
  // breakable blocks don't work
  show: block.with(breakable: false)
  tidy.styles.minimal.show-example(
    inherited-scope: scope,
    preamble: preamble,
    ..args
  )
}
#scope.insert("example", example)

= Introduction

`raw` elements feel similar to arrays and strings in a lot of ways: they feel like lists of lines; it's common to want to extract spcific lines, join multiple ones together, etc. As values, though, `raw` elements don't behave this way.

While a package can't add methods such as `raw.slice()` to an element, we can at least provide functions to help with common tasks. The module reference describes these utility functions:

- #ref-fn("r2l()") and #ref-fn("l2r()") are the building blocks the others build on: _raw-to-lines_ and _lines-to-raw_ conversions.
- #ref-fn("transform()") is one layer above and allows arbitrarilyy transforming an array of strings.
- #ref-fn("map()"), #ref-fn("filter()") and #ref-fn("slice()") are analogous to their `array` counterparts.
- #ref-fn("lines()") is similar to `slice()` but allows more advanced line selections in a single step.
- #ref-fn("join()") combines multiple `raw` elements and is convenient e.g. to add preambles to code snippets.

// This is a template for typst packages. It provides, for example, the #ref-fn("crudo.add()") function:

// #{
//   let lines = read("../gallery/test.typ").trim().split("\n")
//   lines = lines.slice(4)
//   raw(block: true, lang: "typ", lines.join("\n"))
// }

= Module reference

== `crudo`

#{
  let module = tidy.parse-module(
    read("../src/lib.typ"),
    // label-prefix: "crudo.",
    scope: scope,
    preamble: preamble,
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}
