# FTN77 Thesis Template

A Typst template for writing Bachelor's/Master's theses at the Faculty of technical sciences, University of Novi Sad.

**⚠️ Disclaimer**
: This is not an offical template, but rather what I developed for my personal thesis which follows uni guidelines.

## Overview

File [thesis.pdf](./thesis.pdf) provides an example of the compiled pdf, compiled directly from the [starter files](./template/).

The main entry point of the template is the `thesis` function. It layouts the document to include all uni forms like so:

- Cover (page i)
- Assignment (Задатак за завршни рад)
- Heading and figure outlines
- Abbrevations and terms
- 1 Main content (page 1)
- Literature
- A Appendices
- Biography
- Kwd (Кључна документација информација)
- Kwd en (Key words documentation)
- Conflict (Изјава о непостојању сукоба интереса)

If you want to use some other layout you can use the provided components on their own without relying on the main entry point.

Some features of the template:

- default styling which follows uni guidelines
    - Guidelines reccomend microsoft proprietary fonts (Times, Arial, and Courier New - Cambria Math selected to match) so ensure you have those installed to avoid fallbacks to typst otf fonts
- customizable styling for most fragments
    - This is done by overriding named styles from the [style.typ](./style.typ), and passing it to the `thesis`
    - See starter [style.typ](./template/style.typ)
    - Can look good on different page sizes (like a4 or iso-b5, etc.)
- uni forms (`assignment`, `kwd` and `conflict`)
    - These forms were custom written in Typst to match offical docx forms
    - By default auto scale to fit page, but custom style can set explicit sizing if needed
    - filled from arguments passed to `thesis` function (its signature is not the cleanest so check out [metadata.typ](./template/metadata.typ))
- automatic counts for the physical description in the kwd form (just ensure custom figure kinds are set if used)
- automatic page breaks for major sections (headings 1), with alignment to right page when `duplex` is used
- custom serbian cryl translations for the bibliography using the ieee style guide (used by default with the `bibliography` exported by the template)
- outlines for common figure types
    - "slika", "listing", "tabela" - auto recognized from `image`, `raw` and `table` figure kinds
    - "график" - custom kind, must be set when placing a figure
    - other figure kinds can be outlined by passing `outlines` to `thesis`
- idiomatic page/figure numbering
    - Front-matter pages numbered with roman numerals, main starts at 1
    - Chapters numbered 1.1 while appendices А.1 (following serbian azbuka enumeration)
    - Figure numbers are hierarchical in both main and appendices
        - For example, first chapter figures "Слика 1.1", "Слика 1.2", ... then second "Слика 2.1", ... then in appendix 2 "Слика Б.1"
- abbrevation/terms lists with indexes
    - Thanks to the [glossy](https://typst.app/universe/package/glossy/) package
    - Supports terms which are also abbrevations and are included in both lists. Distinguished by group "term", "abbr" or no specified group for both.
    - Only abbrevations are cross referenced while terms are one way.
- support for export to any pdf standard Typst supports (as of Typst@0.15.0)

## Usage

[Typst@0.15.0](https://github.com/typst/typst/tree/v0.15.0) was used for development, so ensure your typst is up to date.

Below is a minimal example of how to use the template:

```typ
#import "@preview/ftn77-thesis:0.1.0": appendices, thesis

#show thesis.with() // specify args with metadata

// write your main content here

#show appendices

// write your appendices here
```

Reccommended way to get started is to use the provided [starter files](./template/) to initialize the project, which can be done with:

```sh
$ typst init @preview/ftn77-thesis:0.1.0
Successfully created new project from @preview/ftn77-thesis:0.1.0 🎉
To start writing, run:
> cd ftn77-thesis
> typst watch thesis.typ
```

## License

This template is licensed under the **CC BY-NC-SA 4.0** license, see [LICENSE](./LICENSE).

## Third-party materials

- Faculty of Technical Sciences, University of Novi Sad logos, forms, and other official materials remain the property of their respective copyright  holders and are provided for use with the template. They are not licensed under the template's license unless explicitly stated otherwise.

- **GitHub Light theme** — licensed under the [CC BY-SA 3.0](
  http://creativecommons.org/licenses/by-sa/3.0/
  ) license.
- **IEEE Reference Guide (ieee.xml)** — modified, licensed under the [CC BY-SA 3.0](
  http://creativecommons.org/licenses/by-sa/3.0/
  ) license.

