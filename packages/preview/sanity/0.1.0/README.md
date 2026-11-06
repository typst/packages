<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/banner-dark.svg" width="100%">
  <img alt="sanity checks for your Typst documents" src="docs/assets/banner-light.svg" width="100%">
</picture>

[![Manual, as a PDF](https://img.shields.io/badge/Manual-PDF-608FEA)](docs/manual.pdf)
[![GitHub repository](https://img.shields.io/badge/GitHub-Repository-608FEA?logo=github)](https://github.com/techgustavo/sanity)


`sanity` is a simple Typst package to find unreferenced figures, uncited sources and lost labels.

```typst
#import "@preview/sanity:0.1.0": *

#show: sanity
```

With these lines, whenever there is something to report, a page is attached listing what was found, just like this:

<img alt="Six findings, each with its severity, its message, the id of the check that made it, and a link to the page it is on." src="docs/assets/report.svg" width="100%">

> Needs Typst 0.14 or newer. The command line script additionally needs 0.15, since it uses `typst eval`.

## Manual

It is worth checking [docs/manual.pdf](docs/manual.pdf) for package details. It contains a description of each check (what it reports) as well as the configuration and exceptions!

On this page you can *check* out
[what it _checks_](#what-it-checks),
[bibliography](#bibliography),
[the command line](#from-the-command-line) and
[recipes](#recipes).

## What it checks

Twelve checks are performed by default as soon as you apply the `show` rule, including checks for figures, tables, listings, and equations, and others. Only elements you labelled yourself are reported as unreferenced. An unlabelled figure cannot be pointed at and is *often* decorative.

The [manual](docs/manual.pdf) gives each check an entry of its own.

## Bibliography

`uncited-entry` needs the bibliography data, and a package cannot read your `.bib`. [From the command line](#from-the-command-line), `bin/sanity` reads it for you. But inside the document you can hand it over:

```typst
#show: sanity.with(bibliography: read("refs.bib"))
```

[BibTeX](https://www.bibtex.org/Format/) and [Hayagriva](https://github.com/typst/hayagriva/blob/v0.10.1/docs/file-format.md) files are both understood.

## From the command line

You can also use [`bin/sanity`](https://github.com/techgustavo/sanity/blob/v0.1.0/bin/sanity) script (and it reports on a document without touching it). It exits `1` on a warning/error, `0` when there is nothing to report, and `2` when the document does not compile.

```console
$ bin/sanity paper.typ
warning: figure <fig:latency> is never referenced [unreferenced-figure]
  ┌─ page 4

sanity: 1 warning
```

You can download it here instead, since packages can't include executables.

```sh
curl -sSLO https://raw.githubusercontent.com/techgustavo/sanity/main/bin/sanity
chmod +x sanity
```

`--help` lists the flags.

## Recipes

<details>
<summary>Check a document without touching it</summary>

With the [one-file script](#from-the-command-line)

```sh
bin/sanity paper.typ
```

</details>

<details>
<summary>Check the bibliography too</summary>

A package cannot open your `.bib`, so the document hands the data over

```typst
#show: sanity.with(bibliography: read("refs.bib"))
```

</details>

<details>
<summary>Let one figure go unreferenced</summary>

This one is decorative, so nothing is ever going to point at it

```typst
#sanity-ignore(<fig:cover>, reason: "decorative")
```

</details>

<details>
<summary>Silence one check on one element</summary>

The element stays under every other check

```typst
#sanity-ignore(<fig:map>, checks: "unreferenced-figure")
```

</details>

<details>
<summary>Turn a check on or off</summary>

By the id, which the [manual](docs/manual.pdf) lists for each check

```typst
#show: sanity.with(checks: ("reference-order": true, "empty-caption": false))
```

</details>

<details>
<summary>Fail the compilation instead of appending a page</summary>

```typst
#show: sanity.with(strict: true)
```

</details>

<details>
<summary>Gate a pull request on the findings</summary>

A workflow that fails when the manuscript does

```yaml
name: manuscript
on: [push, pull_request]

jobs:
  sanity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: typst-community/setup-typst@v5
      - run: |
          curl -sSLO https://raw.githubusercontent.com/techgustavo/sanity/main/bin/sanity
          chmod +x sanity
          ./sanity paper.typ
```

</details>

---

Thanks for considering this package!
