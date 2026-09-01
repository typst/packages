# FTN77 Thesis Template

A Typst template for writing Bachelor's/Master's theses at the Faculty of technical sciences, University of Novi Sad.

**⚠️ Disclaimer**
: This is not an official template, but rather what I developed for my personal thesis which follows uni guidelines.

## Overview

File [thesis.pdf](./thesis.pdf) provides an example of the compiled pdf, compiled directly from the [starter files](./template/).

The main entry point of the template is the `thesis` function. It layouts the document to include all uni forms like so:

- Cover (page i) *
- Assignment (Задатак за завршни рад) *
- Abstract
- Abstract en
- Dedication
- Acknowledgement
- Heading and figure outlines
- Abbrevations
- Terms
- 1 Main content (page 1)
- Literature
- A Appendices
- Biography
- Kwd (Кључна документација информација) *
- Kwd en (Key words documentation) *
- Conflict (Изјава о непостојању сукоба интереса) *

*Required pages, the rest can be ommited

If you want to use some other layout you can use the provided components on their own without relying on the main entry point.

Some features of the template:

- default styling which follows uni guidelines
    - Guidelines reccomend microsoft proprietary fonts (Times, Arial, and Courier New - Cambria Math selected to match) which are used as primary fonts (and should be especially for form pages) but fallback to their liberation equivallents so will look pretty much the same in the Typst web app
- customizable styling for most fragments
    - This is done by overriding named styles from the [style.typ](./style.typ), and passing it to the `thesis`
    - See starter [style.typ](./template/style.typ)
    - Common varying args can be passed directly to `thesis` (like page margin, body font and size...)
    - Can look good on different page sizes (like a4 or iso-b5, etc.), adjusting the margin and base font size (`style.base`) should suffice
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
    - Figure numbers are hierarchical in both main and appendices (can be disabled with `chapter-relative-fig-nums` argument)
        - For example, first chapter figures "Слика 1.1", "Слика 1.2", ... then second "Слика 2.1", ... then in appendix 2 "Слика Б.1"
- abbrevation/terms lists with indexes
    - Thanks to the [glossy](https://typst.app/universe/package/glossy/) package
    - Supports terms which are also abbrevations and are included in both lists. Distinguished by group "term", "abbr" or no specified group for both.
    - Only abbrevations are cross referenced while terms are one way.
- footnotes for url links that have shortened display text (can be disabled with `url-footnotes` argument)
- support for export to any pdf standard Typst supports (as of Typst@0.15.0)

## Usage

A minimal example of how to use the template is show below:

```typ
#import "@preview/ftn77-thesis:0.2.0": appendices, thesis

#show: thesis // use .with() to specify args with metadata

// write your main content here

#show: appendices

// write your appendices here
```

For further info initialize the project with Typst CLI or in the Typst web app (see "How to use" section).

## Help & Feedback

Found a problem or have a suggestion? [Open an issue](https://github.com/cetkovicaleksa/ftn77-thesis/issues) or [contact me](https://github.com/cetkovicaleksa) on GitHub.

If you used this template to write your own thesis, I would love to see it 😁.

## License

This template is licensed under the **GPL 3.0 or later** license, see [LICENSE](./LICENSE).

## Third-party materials

- Faculty of Technical Sciences, University of Novi Sad logos, forms, and other official materials remain the property of their respective copyright  holders and are provided for use with the template. They are not licensed under the template's license unless explicitly stated otherwise.

- **GitHub Light theme** — licensed under the [CC BY-SA 3.0](
  http://creativecommons.org/licenses/by-sa/3.0/
  ) license.
- **IEEE Reference Guide (ieee.xml)** — modified, licensed under the [CC BY-SA 3.0](
  http://creativecommons.org/licenses/by-sa/3.0/
  ) license.
