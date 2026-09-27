# margin-reflow

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Manual](https://img.shields.io/badge/manual-English%20%7C%20Chinese-purple)](doc/manual.pdf)

Reflow content into new margins in the middle of a page.

Documents with asymmetric margins (a wide *outer* margin for margin notes,
figures, or a classic book layout) sometimes need a stretch of content to use a
different layout — for example exercise blocks laid out in two columns across the
full symmetric width, or normal text resuming at the wide book margin after such
a block. `margin-reflow` reflows that content **starting exactly where it
appears**, without forcing a page break, and keeps the new margins for the pages
that follow.

The idea of reflowing content mid-page comes from
[meander.typ](https://github.com/Vanille-N/meander.typ). This package focuses on
the asymmetric ⇄ symmetric direction, on the multi-page asymmetric case that
could previously fail to
[converge](https://github.com/Vanille-N/meander.typ/issues/1#issuecomment-3306100761),
and on mixed CJK/Latin reflow.

## Installation

The package is available on Typst Universe:

```typ
#import "@preview/margin-reflow:0.1.0": column-flow, single-flow, asymmetric-flow
```

## Quick start

```typ
#import "@preview/margin-reflow:0.1.0": column-flow

#set page(margin: (inside: 1.75cm, outside: 6.45cm))
#set par(first-line-indent: (amount: 2em, all: true), justify: true)

// ... text on the current asymmetric page ...

#v(1em)

#column-flow(
  [
    第一段内容。#footnote[第一条脚注。]

    第二段内容。
  ],
  gutter: 14pt,
  footnote-entry: (indent: 0em, size: 9pt),
)
```

The call reflows the content into two columns across the symmetric content
width, right where it appears, and the following pages use symmetric margins.

## Functions

| Function | Starting margins | Resulting layout |
| --- | --- | --- |
| `column-flow` | asymmetric | two columns across the symmetric width |
| `single-flow` | asymmetric | one column across the symmetric width |
| `asymmetric-flow` | symmetric | one column across a given asymmetric width |

All three:

- start at the current position and never insert a page break before the
  reflowed content;
- lay the reflowed content flush to the bottom of the available height;
- pull footnotes out of the flow and render them at the bottom of the reflowed
  block, preserving numbering and `ref`s;
- switch the margins of the following pages to the new layout;
- are `context` functions, so they measure the current page themselves.

Set `par.first-line-indent` if you want first-line indentation inside the
reflowed content.

### `column-flow`

```typ
#column-flow(content, gutter: 4%, count: 2, footnote-entry: none)
```

- `content` *(content)*: the content to reflow. Paragraph breaks are honored.
- `gutter` *(length, default `4%` of the reflow width)*: gap between columns.
- `count` *(int, default `2`)*: number of columns.
- `footnote-entry` *(none, dictionary, or function)*: styling for the manually
  laid-out footnote entries. `none` uses Typst's defaults, a dictionary is used
  as `footnote.entry` configuration (such as `indent`, `size`, `leading`,
  `clearance`, `gap`, `separator`, `style`), and a function is shorthand for
  `(style: function)`.

### `single-flow`

```typ
#single-flow(content, footnote-entry: none)
```

- `content` *(content)*: the content to reflow.
- `footnote-entry` *(none, dictionary, or function)*: as in `column-flow`.

### `asymmetric-flow`

```typ
#asymmetric-flow(content, margin, footnote-entry: none)
```

- `content` *(content)*: the content to reflow.
- `margin` *(auto, length, or dictionary)*: the asymmetric horizontal margin to
  switch to, e.g. `(inside: 1cm, outside: 3cm)` or `(left: 1cm, right: 3cm)`.
  `inside`/`outside` are resolved against the current page parity, like
  `page.margin`. Only the horizontal margins are taken from `margin`; the top and
  bottom margins of the current page are preserved.
- `footnote-entry` *(none, dictionary, or function)*: as in `column-flow`.

## Compatibility and CJK

- **Content-processing packages** should be applied to the content *before* it is
  passed in, because the functions split and rebuild content. For example, with
  `cjk-unbreak`:

  ```typ
  #import "@preview/cjk-unbreak:0.2.3": remove-cjk-break-space

  #column-flow(remove-cjk-break-space[
    中文与英文混排 content ...
  ])
  ```

- **CJK and mixed scripts** are supported: the splitter is aware of Han
  characters, CJK punctuation and spaces, so Chinese, Japanese and Korean text,
  as well as mixed CJK/Latin reflow, works. Use a CJK-capable font and enable
  justification and indentation:

  ```typ
  #set text(font: ("New Computer Modern", "SimSun"), lang: "zh")
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)
  ```

- **Layout packages** have not been tested. The functions build their own
  fixed-height `grid`/`block` structure and change `page.margin`, so packages
  that also control pagination, columns or page geometry may conflict. Packages
  that only decorate content generally work. Footnote styling is rendered
  manually, so use the `footnote-entry` parameter if a package restyles
  `footnote.entry`.

- **Margin-note packages** (e.g. `marginalia`, a common combination): because the
  flow functions manage the page and change `page.margin` mid-page, do *not* wrap
  the output of a flow function in `marginalia.wideblock`, and do *not* use
  `marginalia.wideblock`/`marginalia.header` for headers or footers. Instead,
  align the header/footer from `page.margin` so that they follow the margins the
  flow sets (the manual shows a minimal example). An *empty*
  `marginalia.wideblock` may still be used to keep margin notes from overflowing
  into the body text.

## Documentation

- [Manual (English)](doc/manual.pdf)
- [手册（中文）](doc/manual-zh.pdf)
- [README（中文）](README.zh.md)

The examples in the manuals are rendered on small pages with boundary guide
lines: the *blue* dashed line marks the symmetric content boundary and the
*orange* dashed line the asymmetric one.

## License

Licensed under the [MIT license](LICENSE).
