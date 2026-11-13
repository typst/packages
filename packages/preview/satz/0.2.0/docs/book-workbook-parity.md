# Book API: workbook parity findings

This is the Georgia maths workbook used for the experimental book API. It is
separate from the STIX decoding/RSA research report audited
[here](report-parity-audit.md); their page counts and parity results must not
be combined.

The private RSA maths workbook is the real-document specimen for satz's
experimental `book(...)` entry point. Its LaTeX source and PDF stay outside the
package. The rebuildable Typst source and generated PDF are in the ignored
local `workbook-conversion/` directory; the placeholder example is
[`examples/book.typ`](../examples/book.typ).

## Source design measured from the PDF and preamble

| Detail | Source setting | satz control |
|---|---|---|
| Page | A4, two-sided, open-any chapters | `paper`, `binding` |
| Margins | inside 27 mm, outside 25 mm, top 25 mm, bottom 27 mm | `margin` |
| Binding | 5 mm correction at the inside edge | `binding-correction` |
| Body type | Georgia, 11 pt; STIX Two Math | `font`, `font-size`, `math-font` |
| Body rhythm | 1.16 line spacing, 6 pt plus stretch between paragraphs, no indent | `leading`, `paragraph-spacing`, shared typography config |
| Main accent and ink | teal `#23616B`, ink `#24313B` | `accent`, `config.book.ink` |
| Chapter heading | hanging teal number, 25 pt number, 18 pt ink title | shared `headings` settings and book heading rule |
| Section headings | teal 12 pt; bold subsection headings | shared `headings` settings |
| Contents page | 17 pt title; 10 pt entries; 18.7 pt row pitch; no leader dots | `config.book.contents` |
| Worked example | indented 27 pt; adjustable space above and below | `config.book.worked-example`, with local `above:` override when needed |
| Exercise group | small prompt-to-grid gap; larger gap after each grid | `config.book.exercise` |
| Folio | 10 pt regular, alternating outside, y=792.5 on the contents page | `page-footer`, `config.book.footer-dy` |
| Answer area | 5 mm cells, 0.2 pt gray lines | `exercise(grid:)`, `answer-grid(...)` |

The source also uses worked examples set in a compact indented quote, an
interpretation prompt, numbered exercises, a linked solution appendix, a
notation table, a method map, and six TikZ diagrams. These became the optional
`worked-example`, `analysis-note`, and `exercise` components, Typst tables, and
local diagram images.

The specimen calibrates those TeX paragraph settings to Typst values of
`leading: 0.74em` and `paragraph-spacing: 14pt`; these values match the measured
line and paragraph baselines in this build rather than copying TeX lengths
literally. The general package default remains independently configurable.

The book rhythm is separately adjustable without editing the class:
`config.book.contents` controls title position, title and entry sizes, and entry
spacing; `config.book.worked-example` controls its inset, label/body sizes, and
default vertical spacing; `config.book.exercise` controls the gap before the
answer grid and the gap after each exercise group. Individual worked examples
can override `above`, `below`, and `inset`. The conversion uses a smaller
`above: 16pt` for the worked example placed immediately after a section heading.

## Measured PDF checks

The source PDF has 79 pages. The current satz conversion has 81 pages. Chapter
openings through Chapter 18 still land on the same physical pages; later
chapters have accumulated a two-page shift:

| Chapters | Source PDF pages | satz PDF pages |
|---|---|---|
| 1–9 | 7, 9, 11, 13, 15, 17, 19, 21, 23 | same |
| 10–18 | 26, 29, 31, 33, 36, 38, 40, 42, 45 | same |
| 19–25 | 47, 49, 51, 54, 57, 59, 62 | 48, 51, 53, 56, 59, 61, 64 |

The cover and first chapter opening also align closely by PDF coordinates
(points from the top of the page):

- Cover eyebrow: y=149 in both PDFs.
- Main title lines: y=198 and 223 in the source; y=198 and 223 in satz.
- Subtitle lines: y=280 and 296 in both.
- Cover rule: y=368 in satz and y=368 in the source.
- Chapter 1 title: y=94 in both; the first body line begins at y=134 in both.
- The contents folio is iii; main matter starts at Arabic page 1. The worked
  solutions start at Arabic page 59 in the source and 61 in satz; the three
  final reference pages are 71–73 in the source and 73–75 in satz.

The contents typography now matches the source page rhythm: its title begins
at y=93.9 in both PDFs, its first entry begins at y=132.2 in the source and
y=132.3 in satz, and both use an 18.7 pt row pitch without leader dots. The
contents folio sits at y=792.5 in both PDFs.

On the exercise page for Chapter 1, the first prompt begins at y=179.7 in the
source and y=179.9 in satz. The four answer grids begin at y=215.0, 325.1,
438.5, and 548.6 in the source; the satz grids begin at y=215.2, 326.3, 437.3,
and 548.4. The measured exercise-to-grid and grid-to-next-exercise gaps now
follow the source grouping closely.

The worked-example block also matches its two observed contexts. After a
section heading, the label begins at y=490.9 in the source and y=491.2 in
satz. After a paragraph, it begins at y=588.1 and y=588.0 respectively. Its
indent is about 27 pt in both.

The source PDF has 133 internal links, and the converted PDF has 133. They
include links from worked solutions back to their exercise anchors. The source
and converted documents also retain the blank verso after the cover and after
the contents page. The converted solution links use `#153A40`, matching the
source link color while deriving that shade from the selected teal accent.

## Remaining parity gaps

- The six source TikZ diagrams are high-resolution PNG crops in the conversion.
  Their size and placement are calibrated, but they are not vector graphics in
  the Typst PDF. Rebuilding them as native Typst drawings would improve zoom and
  print sharpness.
- Typst and LaTeX do not break every line identically. A few line endings and
  equation glyph shapes differ. The corrected local block spacing also leaves
  the satz conversion two pages longer after Chapter 18; those later breaks
  need a separate parity pass.
- The two source reference tables fit on individual pages. The current
  conversion renders them as native tables; automatic continuation of a table
  that grows across pages still needs a separate check.

## What the specimen has established for satz

The public class API can stay focused on shared page and typography behavior.
Authors need a book-level wrapper that exposes the common choices directly and
names the transitions between front matter, main matter, appendices, and back
matter. Less common cover and heading adjustments remain available through the
existing recursive `config` merge. This keeps the common writing path short
while letting the book vary from the specimen without editing satz internals.
