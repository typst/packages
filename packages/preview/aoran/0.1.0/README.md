# aoran Typst Package

_helper utilities for choosing between `a` and `an`_

## Installation

```typ
#import "@preview/aoran:0.1.0": article
```

## API

- `article(word, capitalized: false)` – returns `"a"`, `"an"`, or `none`. Set `capitalized` to `true` to receive `"A"` / `"An"` for sentence starts.

```typ
#let word = "umbrella"
#assert(article(word) == "an")
#assert(article(word, capitalized: true) == "An")
```

## Examples

- `examples/basic.typ` shows how to join the returned article with words and headings.
- `examples/thumbnail.typ` is the snippet rendered for the package gallery preview.

Run `just examples` (or `typst compile --root . examples/basic.typ`) to render them.

## Origin

The logic is extracted from the [Glossy](https://github.com/swaits-typst-packages/glossy)
package so standalone documents can reuse the same heuristics without pulling in glossary
machinery.

## License

Licensed under the [MIT License](LICENSE).

The heuristic mirrors the original implementation used in the
[Glossy](https://github.com/swaits-typst-packages/glossy) package. It covers
vowel starts, silent leading `h`, `u` words that sound like "yoo", `eu`
prefixes, and acronym detection (e.g. `"an RFC"` but `"a CPU"`). When the input
is `none` or empty, the helper returns `none` so callers can decide how to
recover.
