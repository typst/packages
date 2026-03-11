# Skoltech Slides

## Overview

This template `innovative-skoltech-slides` is available online at
[Typst][typst]. Alternatively, you can use the CLI to kick this project off
using the command

```shell
typst init @preview/innovative-skoltech-slides
```

## Configuration

This template exports the `innovative-skoltech-slides` function with the
following named arguments.

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a name key and can have the keys department, organization,
  location, and email.
- `authors`: An information of a single author (presenter).

  ```typst
  authors: (
    name: [First Name],
    role: [second-year PhD student],
    institution: "Skoltech",
    comment: [some auxilliary note],
  )
  ```
- `keywords`: Publication keywords (used in PDF metadata).
- `date`: Creation date (used in PDF metadata).
- `bibliography`: The result of a call to the bibliography function or none.
  The function also accepts a single, positional argument for the body of the
  paper.
- `appendix`: Content to append after bibliography section (can be included).
- `aux`: Auxiliary parameters to tune font settings (e.g. font family) or page
  decorations (e.g. page header).

The template will initialize your package with a sample call to the `skoltech`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule at the top of your file.

### Font Config (FC)

According to Skoltech's brandbook, [Futura PT by ParaType][futura-pt] is a
proper type. However, it is a proprietary font. Thus, [Jost*][jost] is a
fallback font. Preferred font family to use can be configure via `aux` keyword
argument of the template.

```typst
#let fc = (font-family: (sans: ("Your Font Family", )))
#show: skoltech.with(title: [...], author: [...], aux: fc)
```

However, if your are Skoltech's student or faculty member then you have Futura
PT font and can just drop it somewhere. If you use standalone Typst compiler
then you should probably adjust font discovery via `TYPST\_FONT\_PATHS`
environment variable or `--font-path` command line option.

[typst]: https://typst.app/
[futura-pt]: https://www.paratype.ru/catalog/font/pt/futura-pt
[jost]: https://indestructibletype.com/Jost
