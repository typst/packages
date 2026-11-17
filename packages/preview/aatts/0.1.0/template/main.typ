#import "@preview/aatts:0.1.0": constants, slides, poster, article

// data
#import "slides.typ" as example-slides
#import "poster.typ" as example-poster
#import "article.typ" as example-article


// ---- geometry
#let margin = 0.8cm
#let gutter = 0.8cm
#let rows = 3
#let cols = 2
#let inner-h = 16cm

#let slide-h = (inner-h - (rows - 1) * gutter) / rows
#let slide-w = slide-h * 16 / 9
#let poster-w = inner-h / calc.sqrt(2)

// overrides the page set by the slides theme
#set page(
  width: poster-w + gutter + cols * slide-w + (cols - 1) * gutter + 2 * margin,
  height: inner-h + 2 * margin,
  margin: margin,
  fill: constants.palette.grey.light,
  footer: none,
)

// footnotes of the minipages would land on this page, drop them
#set footnote.entry(separator: none, clearance: 0pt, gap: 0pt)
#show footnote.entry: none

// ---- minipage
// a page of true size (width, height, margin), scaled down to a framed box
#let minipage(page-w, page-h, page-margin, width, body) = box(
  fill: white,
  stroke: 0.5pt + constants.palette.grey.medium.lighten(50%),
  clip: true,
  scale(
    width / page-w * 100%,
    origin: top + left,
    reflow: true,
    box(width: page-w, height: page-h, inset: page-margin, body),
  ),
)

// "presentation-16-9", w/ the footer of the slides theme unless n is none
#let slide(n, body, inset: slides.units.space.base) = minipage(28cm, 15.75cm, inset, slide-w, {
  show: slides.theme.typography

  body
  if n != none {
    place(bottom, dy: slides.units.space.base / 2, text(
      size: slides.units.font.sm,
      fill: constants.palette.grey.medium,
      grid(columns: (1fr, auto), example-slides.footer, str(n)),
    ))
  }
})

// "a4", first page only (the rest is clipped), fit to the height of two stacked slides
#let a4(body) = minipage(21cm, 29.7cm, article.units.space.lg, (2 * slide-h + gutter) / calc.sqrt(2), block(
  height: 100%,
  clip: true,
  {
    show: article.theme.typography
    set align(left + top)
    body
  },
))

// "a0"
#let a0(body) = minipage(84.1cm, 118.9cm, poster.units.space.base, poster-w, {
  show: poster.theme.typography
  body
})

// ---- layout
// slides are numbered by their page in the example-slides
#grid(
  columns: (poster-w, auto),
  column-gutter: gutter,
  a0((poster.layouts.base)(..example-poster.hero, example-poster.body)),
  grid(
    columns: cols,
    rows: (slide-h,) * rows,
    gutter: gutter,
    slide(none, slides.layouts.title-content(..example-slides.cover)),
    slide(none, inset: 0pt, slides.layouts.title-split-content(..example-slides.cover-split)),
    slide(8, slides.layouts.base-content(..example-slides.results)),
    grid.cell(rowspan: 2, align: center, a4(article.layouts.base(..example-article.hero, example-article.body))),
    slide(14, slides.layouts.base-content(..example-slides.closing)),
  ),
)
