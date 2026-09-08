# beago-suite

A minimal [Typst](https://typst.app) template package with two layouts: quick drafts and structured articles.

## Install

Published package:

```typst
#import "@preview/beago-suite:0.1.0": *
```

Local development:

```typst
#import "../src/beago.typ": *
```

## Templates

| Template  | Use for                                                                     |
| --------- | --------------------------------------------------------------------------- |
| `beago-draft`   | Quick notes and working documents with an optional DRAFT watermark          |
| `beago-article` | Long-form writing with abstract, heading numbering, and justified body text |

Full demos: [draft.typ](template/draft.typ), [main.typ](template/main.typ).

## Draft

```typst
#import "@preview/beago-suite:0.1.0": beago-draft

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
#import "@preview/beago-suite:0.1.0": beago-article

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

## License

MIT
