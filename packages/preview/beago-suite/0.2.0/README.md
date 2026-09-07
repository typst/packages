# beago-suite

A minimal [Typst](https://typst.app) template package with draft, article, and fantasy-book layouts.

## Install

Published package:

```typst
#import "@preview/beago-suite:0.2.0": *
```

Local development:

```typst
#import "../src/lib.typ": *
```

## Templates

| Template        | Use for                                                                     |
| --------------- | --------------------------------------------------------------------------- |
| `beago-draft`   | Quick notes and working documents with an optional DRAFT watermark          |
| `beago-article` | Long-form writing with abstract, heading numbering, and justified body text |
| `book-fantasy`  | A5 fantasy/historical book: front matter, parts, drop caps, auto colophon |

Full demos: [draft.typ](example/draft.typ), [article.typ](example/article.typ), [book-fantasy.typ](example/book-fantasy.typ).

## Draft

```typst
#import "@preview/beago-suite:0.2.0": beago-draft

#show: beago-draft.with(
    title: [Routing Config Notes],
    author: [Your Name],
    date: "2026-06-16",
)

= Open questions

- Should fallback chains be explicit or inferred?
```

### Parameters

| Parameter     | Default    | Description                  |
| ------------- | ---------- | ---------------------------- |
| `title`       | `[Title]`  | Document title               |
| `author`      | `[Author]` | Author name                  |
| `date`        | today      | Date string                  |
| `font-size`   | `11pt`     | Base font size               |
| `paper`       | `"a4"`     | Page size                    |
| `watermark`   | `true`     | Show rotated DRAFT watermark |
| `title-align` | `left`     | Title block alignment        |

## Article

```typst
#import "@preview/beago-suite:0.2.0": beago-article

#show: beago-article.with(
    title: [Document Title],
    subtitle: [Optional subtitle],
    author: [Your Name],
    date: "2026-06-16",
    abstract: [A short summary of the document.],
    paper: "a4",
    heading-numbering: "1.1.",
    first-line-indent: (amount: 2em, all: false),
)

= Introduction

$ (-1.32865 plus.minus 0.50273) times 10^(-6) $
```

### Parameters

| Parameter           | Default    | Description                               |
| ------------------- | ---------- | ----------------------------------------- |
| `title`             | `[Title]`  | Document title                            |
| `subtitle`          | `none`     | Optional subtitle                         |
| `author`            | `[Author]` | Author name                               |
| `date`              | today      | Date string                               |
| `abstract`          | `none`     | Optional abstract block                   |
| `font-size`         | `11pt`     | Base font size                            |
| `paper`             | `"a4"`     | Page size                                 |
| `heading-numbering` | `"1.1."`   | Heading number format (`none` to disable) |
| `title-align`       | `center`   | Title block alignment                     |
| `first-line-indent` | `none`     | Paragraph first-line indent               |
| `line-spacing`      | `1em`      | Line and paragraph spacing                |


## Book Fantasy

A5 two-sided book layout (typearea + Schola by default): classic cover, optional front matter, roman TOC pages, then arabic body. Chapters open with drop caps; parts and chapters are numbered and listed in the TOC.

**Page order:** cover → title page → publishing-info → dedication → acknowledgements → epigraph → frontmatter → TOC → body → colophon

**Structure:**
- `=` — top-level sections (Preface, Appendix); unnumbered
- `#book-part[Title]` — Part I, II, … (title page + TOC entry)
- `==` — chapters under a part; auto Roman numerals (I, II, …) above the title and in the TOC
- `#show: book-backmatter` — end matter (e.g. appendix); no page footer

```typst
#import "@preview/beago-suite:0.2.0": book-fantasy, dropped, book-part, book-backmatter

#show: book-fantasy.with(
    title-prefix: [The],
    title: [Maid of Orleans],
    subtitle: [Translated from the German of Frederick Henning],
    author: [George P. Upton],
    author-note: [Translator of "Memories," etc.],
    place: [Chicago],
    publisher: [A. C. McClurg & Co.],
    year: [1904],
    publishing-info: [Copyright, 1904],
    dedication: [To the memory of the Maid of Orleans],
    epigraph: quote(attribution: [Voltaire])[Courage is womanish when it is Joan's.],
    colophon: true,
)

= Preface

#dropped[The life story of Joan of Arc,][
    as told in this volume, closely follows the historical facts.]

#book-part[The Pastoral Years]

== The Fairy Tree

#dropped[As the traveller,][ descending the valley approaches Domremy.]

#show: book-backmatter

= Appendix
```

### Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `title` | `[Title]` | Cover / title-page title |
| `title-prefix` | `none` | Small word above title (e.g. `The`) |
| `subtitle` | `none` | Cover subtitle |
| `author` | `[Author]` | Author / translator |
| `author-note` | `none` | Line under author on the cover |
| `publisher` / `place` / `year` | `none` | Cover imprint |
| `cover-image` | `none` | Cover art (e.g. `#image(...)`) |
| `titlepage` | `auto` | Title page after cover (`none` to skip; or custom content) |
| `publishing-info` | `none` | Copyright / imprint page |
| `dedication` | `none` | Dedication page (italic, centered) |
| `acknowledgements` | `none` | Acknowledgements page |
| `epigraph` | `none` | Epigraph before the TOC |
| `frontmatter` | `none` | Free-form page before the TOC |
| `colophon` | `false` | If `true`, auto page: font, size, paper, two-sided, Typst credit |
| `font` | `"TeX Gyre Schola"` | Body font |
| `font-size` | `11pt` | Base font size |
| `paper` | `"a5"` | Page size |
| `two-sided` | `true` | Mirrored margins (typearea) |
| `binding-correction` | `8mm` | typearea binding correction |
| `show-outline` | `true` | Table of contents (roman page numbers) |
| `show-figures-outline` | `false` | List of figures |

### Helpers

| Helper | Use |
| --- | --- |
| `dropped[First,][ rest…]` | Drop cap chapter opening (droplet) |
| `framed-image(path, caption)` | Framed plate; optional list of figures |
| `book-part[Title]` | Numbered part title page + TOC |
| `book-backmatter` | `#show:` before appendix / end matter |

## License

MIT
