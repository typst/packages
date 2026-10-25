// Spacing of abntly: the vertical distances between the elements and the indents. The lines of the text are 1.5 apart
// (NBR 14724, 5.2), with 0.2 cm more between the paragraphs, a decision of the package; single spacing (1.2) in the
// long quote, the notes and the title of a figure. Where the norms say nothing, the distances are decisions of the
// package: in ex around the headings, in fractions of a single line around the long quote and the code.
//
// Every distance is in em of the body, so it follows the body an author sets, as the sizes of fonts.typ; a heading or
// a quote measures `em` in its own size, so a distance of the body is converted there (`in-size`). The line box goes
// from 1 em above the baseline down to the baseline (`top-edge: 1em, bottom-edge: "baseline"`), which puts the first
// baseline of a page 1 em under the top of the text block: `leading` is the line step minus 1 em, and the space
// between two blocks is the distance between their baselines minus the size of the lower line. Left out, as fine
// adjustments that cost more than they give: the floating of figures, a shorter space around an equation after a
// short line and distances that stretch or shrink to fill the page.
//
// The main function (src/abntly.typ) applies `spacing` after `fonts`; the values are public, for the other files of
// the package, which build their distances from them. The author calls one function of this file: `no-indent`, the
// paragraph without the indent of its first line.

#import "fonts.typ": elements

// NBR 14724, 5.2: 1.5 between the lines of the text, in the size of each text (the lines of a heading, 1.5 its size)
#let line-spacing = 1.5em
// single spacing: 1.2 of the size
#let single-spacing = 1.2em
// the ex of the skips around the headings: 5.1667 pt in a 12 pt body (a value of the package, not read from the font)
#let ex = 5.1667em / 12
// the skip around the long quote and the code: 2/3 of a single line (no norm gives it: a decision of the package)
#let topsep = single-spacing * 2 / 3
// the extra space between two paragraphs, 0.2 cm in a 12 pt body, in em so that it follows the body; only between the
// paragraphs (and around the lists and the alíneas, which keep the space of a paragraph)
#let paragraph-skip = 0.2cm / 12pt * 1em
// the size of each heading and of the smaller body, as a multiple of the body (fonts.typ)
#let scale = (
  heading: (elements.chapter, elements.section, elements.subsection, elements.subsubsection, elements.paragraph)
    .map(e => e.size.em),
  quote: elements.quote.size.em,
  footnote: elements.footnote.size.em,
)
// the skips around each level of heading, in em of the body, a decision of the package: before the heading (followed
// by one line of the heading) and after it (followed by one line of the text), less after than before, which binds
// the heading to its text. The chapter opens the page; after it, 40 pt of a 12 pt body. The fifth level takes the
// 1.5 ex of the fourth
#let heading-before = (none, 3.5 * ex, 3.25 * ex, 3.25 * ex, 3.25 * ex)
#let heading-after = (40em / 12, 2.3 * ex, 1.5 * ex, 1.5 * ex, 1.5 * ex)
// a figure: 14 pt and a single line of its title before it; from the title to the illustration, 15.9 pt, and the
// same `gap` from the illustration to its source (src/elements.typ); `between` the source, the legend and the notes,
// from a baseline to the next, the space between two paragraphs of the text, which sets each one apart; from the last
// of them to the text, 38.86 pt (values in pt of a 12 pt body)
#let figure-spacing = (
  before: 14em / 12 + single-spacing,
  gap: 15.9em / 12,
  between: line-spacing + paragraph-skip,
  after: 38.86em / 12,
)
// the paragraph indent, which the norms leave open: a decision of the package; the alíneas take it too
#let indent = 1.3cm

// The text that goes on after a displayed equation, a long quote or a list belongs to the paragraph before it ("em
// que x é…"): no indent on its first line. The one function of this file the author calls: a name for the `par`.
/// Creates a paragraph without the indent of its first line: the text that goes on after a displayed equation, a long
/// quote or a list, as in "where $x$ is…", which belongs to the paragraph before it.
///
/// - body (content): Text of the paragraph.
/// -> content
#let no-indent(body) = par(first-line-indent: 0pt, body)

// a distance in em of the body, in the em of an element `s` times the body (a heading, the long quote, the notes)
#let in-size(x, s) = x.abs + x.em / s * 1em

// the block of a heading of level `n` (1 to 5)
#let heading-block(n) = {
  let s = scale.heading.at(n - 1)
  let before = heading-before.at(n - 1)
  (
    above: if before == none { 0pt } else { in-size(before, s) + line-spacing - 1em },
    below: in-size(heading-after.at(n - 1) + line-spacing - 1em, s),
  )
}

#let spacing(body) = {
  set text(top-edge: 1em, bottom-edge: "baseline")
  // the text: 1.5 between the lines, 1.5 and 0.2 cm between the paragraphs; the indent also after a heading
  set par(leading: line-spacing - 1em, spacing: line-spacing - 1em + paragraph-skip, justify: true,
    first-line-indent: (amount: indent, all: true))
  // headings: 1.5 between their own lines (the leading above, in their size); before one, its skip and a line of the
  // heading; after it, the skip and a line of the text
  show heading: set par(justify: false)
  show heading.where(level: 1): set block(..heading-block(1))
  show heading.where(level: 2): set block(..heading-block(2))
  show heading.where(level: 3): set block(..heading-block(3))
  show heading.where(level: 4): set block(..heading-block(4))
  show heading.where(level: 5): set block(..heading-block(5))
  // the chapter at the top of a new page: its first baseline at the height of its tallest glyph
  show heading.where(level: 1): set text(top-edge: "bounds")
  // figures: the title (above it: src/elements.typ) in single spacing. The figure stays where it is written: it does
  // not float (a fine adjustment, not a distance). The space around it goes on a block of its own: a `set block` on
  // the figure would reach every block inside its body, the source and the notes among them
  set figure(gap: figure-spacing.gap)
  show figure: it => block(above: figure-spacing.before - 1em, below: figure-spacing.after - 1em, it)
  show figure.caption: set par(leading: single-spacing - 1em)
  // the long quote: the skip of `topsep` around it; its first line a line of 1.5 of its size under the text, its
  // lines single; 4 cm from the margin (10520, 7.1.1: "Recomenda-se o recuo de 4 cm")
  show quote.where(block: true): it => block(
    above: in-size(topsep, scale.quote) + line-spacing - 1em,
    below: in-size(topsep + line-spacing - 1em, scale.quote),
    pad(left: 4cm, {
      set par(leading: single-spacing - 1em, first-line-indent: 0pt)
      it.body
    }))
  // lists and alíneas: the norms say nothing of the space between the items, so the 1.5 between the lines holds
  // (14724, 5.2), and around the list goes the space between paragraphs. The marker of a list right-aligned in a box
  // of 2 em, the text 0.5 em after it, at 2.5 em from the margin. The alíneas: the letter at the paragraph indent,
  // the text 0.5 em after it. (A list takes its `spacing` also above it, over a `set block`: a block around it gives
  // the space between paragraphs.) The subalíneas, a list or an enum inside an alínea (src/elements.typ gives them
  // the dash), keep the step of the items around them, not the space of a paragraph: the blocks of the rules inside
  // the block of the alíneas win over the outer ones, which collapse at their edges
  set list(indent: 0pt, marker: box(width: 2em, align(right, [•])), body-indent: 0.5em, spacing: line-spacing - 1em)
  show list: it => block(above: line-spacing - 1em + paragraph-skip, below: line-spacing - 1em + paragraph-skip, it)
  set enum(numbering: "a)", indent: indent, body-indent: 0.5em, spacing: line-spacing - 1em)
  show enum: it => block(above: line-spacing - 1em + paragraph-skip, below: line-spacing - 1em + paragraph-skip, {
    show list: inner => block(above: line-spacing - 1em, below: line-spacing - 1em, inner)
    show enum: inner => block(above: line-spacing - 1em, below: line-spacing - 1em, inner)
    it
  })
  // tables: the rows of one line 1.5 apart, as the lines of the text (14724, 5.2, which does not except the tables),
  // with the baseline at 0.7 of the row from its top and 0.3 of it below (a rule under a row clears the descenders,
  // which the baseline edge of the text would not); the same step inside a cell of more than one line, and no indent
  // there; 0.5 em at the sides of a cell
  set table(inset: (x: 0.5em, top: 0pt, bottom: 0.3 * line-spacing))
  show table: set text(top-edge: 0.7 * line-spacing)
  show table: set par(leading: 0.3 * line-spacing, justify: false, first-line-indent: 0pt)
  // displayed equations: 1 em and a line of the text above and below, from baseline to baseline, counted in Typst
  // from the box of the formula: a formula of one line rises 0.583 em above its baseline and goes 0.205 em below it
  // (`x = y + z`)
  show math.equation.where(block: true): set block(above: 1em + line-spacing - 0.583em,
    below: line-spacing - 0.205em)
  // code: the skip of `topsep` around it, as the long quote; its lines 1.5 apart, as the text
  show raw.where(block: true): set block(above: topsep + line-spacing - 1em, below: topsep + line-spacing - 1em)
  show raw.where(block: true): set par(leading: line-spacing - 1em, justify: false)
  // footnotes: 1 em over a 0.4 pt rule of 5 cm (14724, 5.2.1), single spacing inside and between the notes: the `gap`
  // of a single line of the note also goes between the rule and the first note (a `below` of the separator has no
  // effect). These arguments measure `em` in the body
  set footnote.entry(indent: 0pt, clearance: 1em, gap: (single-spacing - 1em) * scale.footnote,
    separator: line(length: 5cm, stroke: 0.4pt))
  // the lines of a note under its first letter, the number standing out (14724, 5.2.1): the number in a box of 1.2 em
  // of the body, the entry rebuilt as one paragraph hanging by that box, the only rule that rebuilds an element
  show footnote.entry: it => {
    let mark = 1.2em / scale.footnote
    let number = numbering(it.note.numbering, ..counter(footnote).at(it.note.location()))
    par(leading: single-spacing - 1em, first-line-indent: 0pt, hanging-indent: mark,
      box(width: mark, link(it.note.location(), super(number))) + it.note.body)
  }
  body
}
