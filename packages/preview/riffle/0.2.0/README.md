# riffle

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Manual](https://img.shields.io/badge/manual-English%20%7C%20Chinese-purple)](https://github.com/sses7757/typst-riffle/blob/v0.2.0/doc/manual.pdf)

Reflow content into new margins in the middle of a page.

Documents with asymmetric margins (a wide *outer* margin for margin notes,
figures, or a classic book layout) sometimes need a stretch of content to use a
different layout — for example exercise blocks laid out in two columns across the
full symmetric width, or normal text resuming at the wide book margin after such
a block. `riffle` reflows that content **starting exactly where it
appears**, without forcing a page break, and keeps the new margins for the pages
that follow.

The idea of reflowing content mid-page comes from
[meander.typ](https://github.com/Vanille-N/meander.typ). This package focuses on
the asymmetric ⇄ symmetric direction, on the multi-page asymmetric case that
could previously fail to
[converge](https://github.com/Vanille-N/meander.typ/issues/1#issuecomment-3306100761),
and on mixed CJK/Latin reflow.

The name stays with the river metaphor: a *riffle* is the short stretch of a
stream where the current changes character — here, the stretch of a page where
the layout changes course.

## Installation

The package is available on Typst Universe:

```typ
#import "@preview/riffle:0.2.0": margin-reflow
```

## Quick start

```typ
#import "@preview/riffle:0.2.0": margin-reflow

#set page(margin: (inside: 1.75cm, outside: 6.45cm))
#set par(first-line-indent: (amount: 2em, all: true), justify: true)

// ... text on the current asymmetric page ...

#margin-reflow(
  columns: (count: 2, gutter: 14pt),
  margin: "symmetric",
  footnote-style: (size: 9pt),
)[
  第一段内容。#footnote[第一条脚注。]

  第二段内容。
]
```

The call reflows the content into two columns across the symmetric content
width, right where it appears, and the following pages use symmetric margins.

## `margin-reflow`

One function covers every direction:

```typ
#margin-reflow(
  content,
  columns: (count: 1, gutter: 4%),
  margin: auto,
  footnote-style: none,
  set-page-margin: true,
)
```

- `content` *(content)*: the content to reflow. Paragraph breaks are honored.
- `columns` *(dictionary, default `(count: 1, gutter: 4%)`)*: forwarded to the
  column layout. Only `count` *(int, default `1`)* and `gutter` *(length,
  default `4%` of the reflow width)* are meaningful.
- `margin` *(auto, length, dictionary, or `"symmetric"`, default `auto`)*: the
  horizontal margin to switch to — a page-margin dictionary such as
  `(inside: 1cm, outside: 3cm)`, a plain length for equal left/right margins,
  `"symmetric"` for `min(inside, outside)` of the current page on both sides, or
  `auto` to inherit the current margin. The top and bottom margins of the current
  page are preserved.
- `footnote-style` *(none, dictionary, or function)*: styling for the manually
  laid-out footnote entries. `none` keeps the inherited defaults, a dictionary is
  applied as `set text(...)` to the body of each entry (so it takes `text`'s
  arguments such as `size` or `fill`), and a function is applied to the body
  directly. The entry spacing (`gap`, `indent`, `clearance`, `separator`) comes
  from the ambient `footnote.entry` settings.
- `set-page-margin` *(bool, default `true`)*: `true` switches the margins of the
  pages *after* the reflow with `set page(...)` and splits only the current page
  by hand (fast, recommended, works with any `count`); `false` never uses
  `set page(...)`, splits every page by hand and emulates the margin change with
  padding (slower, but it leaves the document's page settings untouched). The
  hand-split path requires `count: 1`: a hand-split page cannot switch to a
  multi-column layout partway through, so any other `count` is rejected with an
  assertion.

The function:

- starts at the current position and never inserts a page break before the
  reflowed content;
- lays the reflowed content flush to the bottom of the available height;
- pulls footnotes out of the flow and renders them at the bottom of the reflowed
  block, preserving numbering and `ref`s;
- switches the margins of the following pages to the new layout;
- is a `context` function, so it measures the current page itself.

Set `par.first-line-indent` if you want first-line indentation inside the
reflowed content.

## Limitations

- **No nesting.** The function measures and rewrites its content, and reads the
  page state at the position where it is called, so a `margin-reflow` call
  *inside* the reflowed content cannot be handled: the inner call would measure a
  page whose geometry the outer call has already replaced. Keep calls sequential.
- **No state updates inside the content.** The content is laid out several times
  while the package finds the amount that fits (once per page with
  `set-page-margin: false`), so a `state` updated inside the reflowed content runs
  more than once and cannot be relied upon. Keep the state handling outside and
  pass the result in — or use a metadata-based mechanism. `counter` access that
  Typst resolves after layout (including a manual `counter(...).update(...)` or
  `.step()` written as document content) is *not* affected.
- **Footnotes are rendered by the package.** Typst's `footnote.entry` rules do
  not apply to footnotes inside a reflow; use the `footnote-style` parameter for
  the entry body and `#set footnote.entry(...)` for the spacing.
- **Page setup.** The page width and height must be concrete lengths.
  `set-page-margin: false` requires `count: 1`. `margin: auto` inherits the
  current margin, which on an asymmetric page means the columns span the
  asymmetric width; pass `margin: "symmetric"` for a two-column reflow.

## Compatibility and CJK

- **Content-processing packages** should be applied to the content *before* it is
  passed in, because the function splits and rebuilds content. For example, with
  `cjk-unbreak`:

  ```typ
  #import "@preview/cjk-unbreak:0.2.3": remove-cjk-break-space

  #margin-reflow(
    columns: (count: 2, gutter: 10pt),
    margin: "symmetric",
  )[
    #remove-cjk-break-space[
      中文与英文混排 content ...
    ]
  ]
  ```

- **CJK and mixed scripts** are supported: the splitter is aware of Han
  characters, CJK punctuation and spaces, so Chinese, Japanese and Korean text,
  as well as mixed CJK/Latin reflow, works. Use a CJK-capable font and enable
  justification and indentation:

  ```typ
  #set text(font: ("New Computer Modern", "SimSun"), lang: "zh")
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)
  ```

  A line break in the *source* between two CJK characters renders as a space;
  `cjk-unbreak` removes it when both sides are plain text, but not across a
  styled element such as `strong` or a footnote.

- **Layout packages** have not been tested. The function builds its own
  fixed-height `grid`/`block` structure and changes `page.margin`, so packages
  that also control pagination, columns or page geometry may conflict. Packages
  that only decorate content generally work.

- **Margin-note packages** (e.g. `marginalia`, a common combination): because the
  reflow manages the page and changes `page.margin` mid-page, do *not* wrap its
  output in `marginalia.wideblock`, and do *not* use
  `marginalia.wideblock`/`marginalia.header` for headers or footers. Instead,
  align the header/footer from `page.margin` so that they follow the margins the
  reflow sets (the manual shows a minimal example). An *empty*
  `marginalia.wideblock` may still be used to keep margin notes from overflowing
  into the body text.

## Documentation

- [Manual (English)](https://github.com/sses7757/typst-riffle/blob/v0.2.0/doc/manual.pdf)
- [手册（中文）](https://github.com/sses7757/typst-riffle/blob/v0.2.0/doc/manual-zh.pdf)
- [README（中文）](README.zh.md)

The examples in the manuals are rendered on small pages with boundary guide
lines: the *blue* dashed line marks the symmetric content boundary and the
*orange* dashed line the asymmetric one.

## Development

- Register a Git repository to update the package locally.
  ```sh
  git init
  git remote add origin git@github.com:sses7757/typst-riffle.git
  ```
- Test the package.
  ```sh
  powershell -NoProfile -File tests\run.ps1
  ```
- Render the manual figures.
  ```sh
  powershell -NoProfile -File scripts\render-doc-images.ps1
  ```

## License

Licensed under the [MIT license](LICENSE).
