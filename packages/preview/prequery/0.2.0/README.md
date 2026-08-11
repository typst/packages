# Prequery

[![GitHub Pages](https://img.shields.io/static/v1?logo=github&label=Pages&message=prequery&color=blue)](https://typst-community.github.io/prequery/)
[![GitHub repo](https://img.shields.io/static/v1?logo=github&label=Repo&message=prequery&color=blue)](https://github.com/typst-community/prequery)
[![Universe](https://img.shields.io/static/v1?logo=typst&label=Universe&message=prequery&color=239DAD)](https://typst.app/universe/package/prequery)
[![GitHub tag](https://img.shields.io/github/tag/typst-community/prequery?sort=semver&color=blue)](https://github.com/typst-community/prequery/tags/)
[![License](https://img.shields.io/badge/License-MIT-blue)](https://github.com/typst-community/prequery?tab=MIT-1-ov-file)
[![GitHub issues](https://img.shields.io/github/issues/typst-community/prequery)](https://github.com/typst-community/prequery/issues)

This package helps extracting metadata for preprocessing from a typst document, for example image URLs for download from the web.
Typst compilations are sandboxed: it is not possible for Typst packages, or even just a Typst document itself, to access the "ouside world".
This sandboxing of Typst has good reasons.
Yet, it is often convenient to trade a bit of security for convenience by weakening it.
Prequery helps with that by providing some simple scaffolding for supporting preprocessing of documents.

The Prequery documentation is located at https://typst-community.github.io/prequery/; for now, the package API is still in the [PDF manual](docs/manual.pdf).

## Getting Started

Here's an example for referencing images from the internet:

```typ
#import "@preview/prequery:0.2.0"

// toggle this comment or pass `--input prequery-fallback=true` to enable fallback
// #prequery.fallback.update(true)

#prequery.image(
  "https://raw.githubusercontent.com/typst-community/prequery/refs/heads/main/test-assets/example-image.svg",
  "assets/example-image.svg")
```

Using `typst query`, the image URL(s) are extracted from the document:

```sh
typst query --input prequery-fallback=true --field value \
    main.typ '<web-resource>'
```

This will output the following piece of JSON:

```json
[{"url": "https://raw.githubusercontent.com/typst-community/prequery/refs/heads/main/test-assets/example-image.svg", "path": "assets/example-image.svg"}]
```

Which can then be used to download all images to the expected locations.
One option to do so is to use the `prequery` preprocessor; you can look at the [Quickstart section](https://typst-community.github.io/prequery/quickstart/installation.html) to learn how.
