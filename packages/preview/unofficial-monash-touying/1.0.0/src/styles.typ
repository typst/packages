// Set and show rules applied to every slide body through Touying's `init`.
// Everything is a set rule or a narrow show rule, so a deck's own rules and
// element arguments still win.

#import "@preview/zebraw:0.6.3": zebraw
#import "design.typ": *

// Headings inside a slide are styled with set rules only, so they keep
// Typst's heading behaviour: a heading at the bottom of a page moves to the
// next page with the content after it.
#let _heading-rules(body) = {
  show heading.where(level: 3): set text(size: 1em, weight: "bold", fill: monash-blue)
  show heading.where(level: 3): set block(above: 1em, below: .7em)
  show heading.where(level: 4): set text(size: 1em, weight: "bold", fill: monash-blue)
  show heading.where(level: 4): set block(above: .9em, below: .6em)
  body
}

// Each nested list or enumeration is set a little smaller than its parent,
// so levels differ in size as well as in marker and indentation. The size
// is absolute, so the rules of several ancestors do not compound.
#let _nested-ratio = .92

#let _shrink-nested(it) = context {
  let size = text.size * _nested-ratio
  show list: set text(size: size)
  show enum: set text(size: size)
  it
}

// List markers differ by level in shape, colour, and size: a filled accent
// square, a hollow blue square, then a grey dash. Deeper levels cycle.
#let _list-markers(accent) = (
  box(width: .5em, height: .5em, baseline: -.08em, fill: accent),
  box(width: .42em, height: .42em, baseline: -.1em, stroke: 1.4pt + monash-blue),
  text(fill: monash-dark-grey, weight: "bold")[–],
)

// Enumeration labels differ by level: a filled accent box with a number, an
// outlined box with a letter, then a plain roman numeral. Deeper levels
// cycle.
#let _enum-label(accent, ..nums) = {
  let depth = calc.rem(nums.pos().len() - 1, 3)
  let value = nums.pos().last()
  let label(fill, stroke, color, body) = box(
    fill: fill,
    stroke: stroke,
    inset: (x: .22em, y: .12em),
    baseline: .06em,
    text(size: .72em, fill: color, weight: "bold", body),
  )
  if depth == 0 {
    label(accent, none, white, str(value))
  } else if depth == 1 {
    label(none, .9pt + accent, accent, numbering("a", value))
  } else {
    text(size: .85em, fill: monash-blue, weight: "bold", numbering("i.", value))
  }
}

#let _list-rules(accent, body) = {
  set list(marker: _list-markers(accent), indent: 1.1em, body-indent: .6em)
  set enum(
    full: true,
    numbering: _enum-label.with(accent),
    indent: 1.1em,
    body-indent: .7em,
  )
  show list: _shrink-nested
  show enum: _shrink-nested
  body
}

// Typst sets raw text at 0.8em of the surrounding text, which block code
// keeps. Inline code is enlarged to 0.85em overall (1.0625 x 0.8).
#let _code-rules(body) = {
  show raw.where(block: false): set text(size: 1.0625em)
  // `highlight` rather than `box`, so long inline code breaks across lines
  // like text instead of wrapping inside a box.
  show raw.where(block: false): it => highlight(
    fill: monash-blue-wash,
    extent: .12em,
    top-edge: "ascender",
    bottom-edge: "descender",
    radius: 1.5pt,
    text(fill: monash-blue-dark, it),
  )
  show raw.where(block: true): set text(fill: monash-charcoal)
  show: zebraw.with(
    background-color: monash-grey-light,
    highlight-color: monash-blue-wash,
    lang: false,
    radius: 2pt,
    inset: (x: space-md, y: space-sm),
    numbering: false,
  )
  body
}

#let _table-rules(body) = {
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 1.2pt + monash-blue } else { none },
      bottom: if y == 0 { .8pt + monash-blue } else { .5pt + monash-grey },
    ),
    fill: (x, y) => if y == 0 { monash-blue-wash },
    inset: (x: .65em, y: .45em),
  )
  show table: set text(size: .85em)
  show table.cell.where(y: 0): set text(weight: "bold", fill: monash-blue-dark)
  body
}

// Captions of images, tables, and code figures. Frame environments are
// figures too, so the rule is limited to these kinds.
#let _caption-rules(body) = {
  show figure.where(kind: image).or(figure.where(kind: table)).or(figure.where(kind: raw)): it => {
    show figure.caption: set text(size: .72em, fill: monash-dark-grey)
    it
  }
  body
}

// External links are coloured and underlined; internal links (outline
// entries, references, footnote markers) are left alone.
#let _link-rules(body) = {
  show link: it => if type(it.dest) == str {
    underline(offset: .15em, stroke: .6pt + monash-blue.transparentize(40%), text(fill: monash-blue, it))
  } else { it }
  body
}

#let _citation-rules(body) = {
  // The slide heading already titles a reference slide.
  set bibliography(title: none)
  show bibliography: set text(size: .62em)
  show bibliography: set par(spacing: .55em)
  show footnote.entry: set text(size: .62em)
  body
}

/// Body rules of the theme, as a Touying `init` method.
#let slide-rules(accent, self: none, body) = {
  set par(justify: false, leading: .65em)
  set figure(placement: none)
  show: _heading-rules
  show strong: it => text(fill: accent, weight: "bold", it.body)
  show: _list-rules.with(accent)
  show: _code-rules
  show: _table-rules
  show: _caption-rules
  show: _link-rules
  show: _citation-rules
  body
}
