# appunti

A [Typst](https://typst.app/docs/) template for university lecture notes.

## Features

- Theorem environments via [theorion](https://typst.app/universe/package/theorion/)
- Algorithms via [algorithmic](https://typst.app/universe/package/algorithmic/)
- Customizable colors
- English and Italian, easy to extend
 
## Quick Start

```typst
#import "@preview/appunti:0.1.0": *

#show: notes.with(
    course: "Machine Learning",
    degree: "MSc in Computer Science",
    author: "Mario Rossi",
    language: "en",
)

= First Chapter

Content.
```

## Customization

### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `course` | `str` | `"Course"` | Course name, shown as the main title |
| `degree` | `str` | `"Degree"` | Degree programme |
| `author` | `str` | `"Author"` | Author name |
| `logo` | `dictionary` | `(:)` | Title page image, see below |
| `language` | `str` | `"en"` | Language code |
| `theme` | `dictionary` | `(:)` | Color overrides, see below |

### Logo

Any subset of these keys is accepted; the rest keep their defaults.

```typst
logo: (
    data: read("assets/logo.svg", encoding: none),
    width: 7.5cm,
    align: left,
),
```

`data` must be bytes, since relative paths cannot be resolved from inside the package.

`recolor` adapts a monochrome SVG to any color. It is a plain text substitution, so the color must appear in the file exactly as written:

```typst
data: recolor(read("assets/logo.svg", encoding: none), "black", white),
```

### Theme

Any subset of these keys is accepted; the rest keep their defaults.

```typst
theme: (
    background: white,
    foreground: luma(20),
    link: rgb("#1a5fb4"),
    rule: luma(180),
),
```

`rule` applies to the title page rule, the header rule, table borders and algorithm lines.

### Language

`"en"` and `"it"` are built in. To add one, extend `translations` in `src/i18n.typ`.

## Example

[Source code](https://github.com/evaevangelisti/appunti/blob/main/examples/catppuccin.typ)

![Catppuccin Mocha](https://raw.githubusercontent.com/evaevangelisti/appunti/main/examples/catppuccin.png)
