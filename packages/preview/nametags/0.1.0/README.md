# nametags

Conference nametag badges (4 × 3 in lanyard inserts) and table tents (tabloid landscape, folded to 11 × 4.25 in) — pure Typst, driven from any CSV or array.

## Install

From Typst Universe (after the package is published):

```typst
#import "@preview/nametags:0.1.0": nametag, nametent
```

Or use a local checkout:

```typst
#import "/path/to/nametags-package/lib.typ": nametag, nametent
```

## Quick start — badges

`badges.typ`:

```typst
#import "@preview/nametags:0.1.0": nametag

#let rows = csv("attendees.csv").slice(1)        // drop header row
#let left-logo = read("logo-left.png", encoding: none)   // your logo
#let right-logo = read("logo-right.png", encoding: none) // your logo

#for row in rows {
  let (first, last, dept, inst) = row
  nametag(
    name: first + " " + last,
    affiliation: inst,
    subaffiliation: dept,
    conference: "Annual Research Symposium",
    year: "2026",
    logo-left: left-logo,
    logo-right: right-logo,
  )
}
```

`attendees.csv`:

```csv
First,Last,Affil1,Affil2
Jane,Doe,Department of Sociology,Example State University
John,Smith,School of Public Affairs,Riverside College
```

Then:

```bash
typst compile badges.typ
```

You'll get one 4 × 3 in page per attendee.

## Quick start — tents

```typst
#import "@preview/nametags:0.1.0": nametent

#let rows = csv("attendees.csv").slice(1)
#let left-logo = read("logo-left.png", encoding: none)   // your logo
#let right-logo = read("logo-right.png", encoding: none) // your logo

#for row in rows {
  let (first, last, _, inst) = row
  nametent(
    name: first + " " + last,
    affiliation: inst,
    conference: "Annual Research Symposium",
    year: "2026",
    logo-left: left-logo,
    logo-right: right-logo,
  )
}
```

Print on tabloid (11 × 17), trim or fold to 11 × 8.5, then fold along the horizontal center. The top half is rotated 180° so both sides read upright when standing on a table.

## API

### `nametag(name, affiliation, subaffiliation, conference, year, accent-color, logo-left, logo-right)`

Renders a single 4 × 3 in badge as one page.

| Parameter | Type | Default | Notes |
|----------:|------|---------|-------|
| `name` | str | `""` | Attendee's full name |
| `affiliation` | str | `""` | Primary line — typically institution |
| `subaffiliation` | str | `""` | Secondary line — typically department or title; omitted if empty |
| `conference` | str | `"Annual Research Symposium"` | Shown in the header bar, uppercased |
| `year` | str | `"2026"` | Right side of header bar |
| `accent-color` | color | `rgb("#0d3b66")` | Header-year accent and rule under name |
| `logo-left` | bytes \| none | `none` | Footer logo, left side. Pass `read("logo.png", encoding: none)` |
| `logo-right` | bytes \| none | `none` | Footer logo, right side |

### `nametent(name, affiliation, conference, year, accent-color, logo-left, logo-right)`

Renders a single tabloid landscape page that folds into a tent. Same parameter conventions as `nametag` but no `subaffiliation`. Name size is auto-selected (52 / 60 / 68 pt) by character count to keep names on one line.

## Notes

- **Logos are bytes, not paths.** Typst resolves `image()` paths relative to the file containing the call, so passing a path string into a packaged function won't find a file in your project. Loading the bytes once with `read()` and handing them in sidesteps this.
- **Example logos are placeholders.** `examples/logo-left.png` and `examples/logo-right.png` are simple wordmarks generated for the demo. Replace them with your own.
- **Fonts.** Both functions default to "Industry Inc Test Base" (headings) and "Oriya MN" (body), with Impact / Times New Roman as fallbacks. Edit the `heading-font` and `body-font` lists at the top of `nametag.typ` / `nametent.typ` to swap.
- **Quarto users.** A Quarto-driven version of this template lives at [`cwimpy/typst-templates/nametags`](https://github.com/cwimpy/typst-templates/tree/main/nametags), with an R chunk that reads the CSV and emits Typst calls.

## License

MIT
