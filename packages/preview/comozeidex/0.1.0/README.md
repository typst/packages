# comozeidex

A Typst template for building a hierarchical index or binder —
**Areas → Categories → IDs → notes** — with styled headings and an
optional table of contents.

## Usage

Start a new project from the template:

```
typst init @preview/comozeidex:0.1.0 my-index
```

This gives you a ready-to-edit `main.typ`:

```typ
#import "@preview/comozeidex:0.1.0": *
#show: doc.with(title: "My Index")
#toc()                          // optional table of contents

= Home                          // Area   (level 1)
== Finances                     // Category (level 2)
=== 11.01 Bank Statements       // ID      (level 3)
#info[Monthly statements, PDF only]
#physloc[Filing cabinet, drawer 2]
#subid[11.01.01 — Checking account]
==== Some note as its own line  // looks like #info, no bullet
```

## Knobs

Styling is controlled by module-level variables at the top of
`lib.typ` — fonts, sizes, indents, and colors for each heading level,
plus tables, code blocks, blockquotes, and links. Set
`number-sections = false` to turn off outline-style numbering (on by
default) if your Area/Category/ID headings already carry their own
hand-typed numbers.

## Helpers

- `doc(title:)` — the document wrapper; apply with `#show: doc.with(...)`.
- `toc()` — an optional table-of-contents page.
- `info(body)`, `physloc(body)`, `subid(body)` — bulleted leaf notes
  under an ID heading.
- `callout(body, fill:)`, `blockquote(body)`, `divider()` — general
  prose-page helpers.

## License

MIT, see [LICENSE](LICENSE).
