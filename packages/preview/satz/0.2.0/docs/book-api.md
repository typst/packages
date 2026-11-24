# The satz book API

Named templates share an internal document class for page and typography
behavior. Choose `report()`, `article()`, `journal-entry()`, or `book()` when one
matches the document you want to write. Use the public `custom()` function when
you want to write your own structure while reusing Satz's page and typography
rules. `custom()` accepts a `kind` behavior preset such as `"report"` or
`"thesis"`; it does not impose a ready-made document structure.
generic `kind`, `config`, `header`, and `footer` arguments are too low-level for
the ordinary book-writing path. `book(...)` wraps that foundation in a
KOMA-Script-like entry point: choose the title, typeface, and accent once, then
write with normal Typst headings and content blocks.

The API is experimental in the current local development version. The RSA
workbook conversion in the ignored `workbook-conversion/` directory is its
large, real-document specimen; `examples/book.typ` is the privacy-safe public
example.

## Shortest path

```typst
#import "@local/satz:0.2.0": book, book-contents, book-mainmatter

#show: book.with(
  title: [Mathematics for Data Analysis],
  author: [Your Name],
  accent: rgb("#23616B"),
  font: "Libertinus Serif",
)

= How to use this book
Write front matter as ordinary Typst content.

#book-contents()

#book-mainmatter[
  = First chapter
  Begin writing. Use ordinary sections, figures, tables, equations, and links.
]
```

The book entry point supplies a designed cover or a full-page `cover-image`,
two-sided page layout with binding correction, front-matter Roman folios,
Arabic main-matter folios, and a native linked contents page. Bottom running
footers alternate between the chapter title and chapter label;
chapter-opening pages keep the folio but omit the title. Set
`running-headers: "top"` for Satz's Hydra-based top headers, or `"none"` to
show folios only. The `accent` parameter sets the heading and component color;
links use a darker mix of that accent. Pass any Typst color.

For an EPUB conversion, pass the extracted cover image as a project-relative
path. When `cover-image` is omitted, Satz keeps its configurable typographic
cover.

## Structure and components

Use `book-appendix[...]` to switch chapter numbering to letters while keeping
Arabic page numbers. Each `book-backmatter[...]` section begins on a fresh page
and retains continuous Arabic folios. Use a separate call for references, notes,
and other back-matter sections. `book-index[...]` starts a fresh two-column index
with hanging entries. Its `column-count:`, `gutter:`, `indent:`, and `spacing:`
arguments tune the index layout. `book-contents(title:, depth:)` controls the
contents heading and the deepest heading level listed; row spacing is
configurable through `config.book.contents.entry-spacing`.

Educational components are optional. `worked-example[...]` adds a compact
indented calculation; `analysis-note[...]` adds a highlighted interpretation
prompt; and `exercise[...]` prints the current chapter and local exercise
number, followed by a square answer grid. An exercise's `kind:` can label it as
`"Core"` or `"Optional challenge"`; `grid:` sets its answer-space height.
`answer-grid(height:, cell:, color:, width:)` can also be used on its own.

See [the complete authoring example](../examples/book.typ).

## Layout controls

Common choices are direct `book.with(...)` parameters: `title`, `subtitle`,
`author`, `eyebrow`, `note`, `date`, `accent`, `font`, `math-font`, `font-size`,
`leading`, `paragraph-spacing`, `paper`, `margin`, `binding`, and
`binding-correction`. Cover spacing and heading rhythm can be tuned through
`config`, while preserving the shared satz defaults:

```typst
#show: book.with(
  title: [A different book],
  cover-image: "assets/cover.jpg",
  accent: teal,
  running-headers: "bottom",
  config: (
    book: (cover-top: 35mm, cover-title-size: 30pt),
    headings: (h1-below: 28pt, h2-above: 18pt),
    page: (margin: (left: 30mm, right: 24mm, top: 22mm, bottom: 26mm)),
  ),
)
```

An index can follow the references without resetting the page counter:

```typst
#book-backmatter[
  = References
  // Add a bibliography or formatted reference entries.
]

#book-index[
  Mechanisms, 12–18
  Models, 23–27
]
```

The config dictionary uses satz's recursive `merge()` behavior: changing one
nested value leaves sibling defaults intact. `binding` chooses the inside edge;
`binding-correction` adds room at that edge. This keeps the physical page setup
explicit and adjustable instead of baking the workbook's dimensions into the
book API. `math-font` should name an OpenType math font; the book defaults to
Typst's New Computer Modern Math, and the workbook selects STIX Two Math.
See [Typst's math font documentation](https://typst.app/docs/reference/math/#math-fonts).

## Maturity and next steps

The public shape is intentionally compact, but the entry point is not yet a
stable release feature. The workbook conversion is being checked against its
source PDF for pagination, chapter openings, front and back matter, diagrams,
tables, exercise labels, and answer-space geometry. Layout controls that prove
generally useful in that review belong in `book(...)` or the shared class;
one-off conversion details stay in the conversion source.
