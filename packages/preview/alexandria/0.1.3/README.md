# Alexandria

This package provides an alternative to the built-in bibliography to allow a single document to have multiple bibliographies.

This package currently has a few limitations, such as not being able to collapse citations yet, but more general support is planned soon.

## Getting Started

To add this package to your project, use this:

```typ
#import "@preview/alexandria:0.1.3": *

#show: alexandria(prefix: "x-", read: path => read(path))

...

#bibliographyx(
  "bibliography.bib",
  // title: auto is not yet supported so it needs to be specified
  title: "Bibliography",
)
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>

## Usage

See the [manual](docs/manual.pdf) for details.

## License

Parts of the Rust plugin that interfaces with the [Hayagriva](https://github.com/typst/hayagriva) citation library are based on [typst-library's `bibliography.rs`](https://github.com/typst/typst/blob/26e65bfef5b1da7f6c72e1409237cf03fb5d6069/crates/typst-library/src/model/bibliography.rs). Likewise, the example bibliographies are taken or adapted from [typst-dev-assets' `works.bib`](https://github.com/typst/typst-dev-assets/blob/1dba4bea22e5e19597fbf5f321b047ff7626e2d0/files/bib/works.bib). Both are licensed from Typst's authors under the Apache License 2.0.

The example CSL style [`ieee.csl`](https://github.com/citation-style-language/styles/blob/fd6cb3e81762055d107839c3c288c359985f81c8/ieee.csl) is taken from the [CSL project](https://citationstyles.org/) who provide it under the [Creative Commons Attribution-ShareAlike 3.0 Unported license](https://creativecommons.org/licenses/by-sa/3.0/).
