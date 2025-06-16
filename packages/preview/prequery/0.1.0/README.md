# Prequery

This package helps extracting metadata for preprocessing from a typst document, for example image URLs for download from the web. Typst compilations are sandboxed: it is not possible for Typst packages, or even just a Typst document itself, to access the "ouside world". This sandboxing of Typst has good reasons. Yet, it is often convenient to trade a bit of security for convenience by weakening it. Prequery helps with that by providing some simple scaffolding for supporting preprocessing of documents.

Here's an example for referencing images from the internet:

```typ
#import "@preview/prequery:0.1.0"

// toggle this comment or pass `--input prequery-fallback=true` to enable fallback
// #prequery.fallback.update(true)

#prequery.image(
  "https://en.wikipedia.org/static/images/icons/wikipedia.png",
  "assets/wikipedia.png")
```

Using `typst query`, the image URL(s) are extracted from the document:

```sh
typst query --input prequery-fallback=true --field value \
    main.typ '<web-resource>'
```

This will output the following piece of JSON:

```json
[{"url": "https://en.wikipedia.org/static/images/icons/wikipedia.png", "path": "assets/wikipedia.png"}]
```

Which can then be used to download all images to the expected locations.

See the [manual](docs/manual.pdf) for details.
