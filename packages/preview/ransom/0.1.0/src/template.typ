// The document template: write ordinary Typst, get a ransom note.

#import "note.typ": ransom
#import "tile.typ": document-text

// ==========================================================================
// Surfaces
//
// What the finished note lies on: plain, lined or squared paper, or kraft
// paper, optionally with the creases of a letter folded in thirds.

#let _colors = (
  plain: rgb("#f7f3e8"),
  lined: rgb("#fbfaf4"),
  grid: rgb("#fbfaf4"),
  kraft: rgb("#cdab7c"),
)

#let _rule = 0.5pt + rgb("#bcd0ea")

// Horizontal rules every 8 mm for "lined", a 5 mm grid for "grid".
#let _ruling(kind) = {
  if kind == "lined" {
    tiling(size: (8mm, 8mm), relative: "self")[
      #place(bottom, line(length: 100%, stroke: _rule))
    ]
  } else if kind == "grid" {
    tiling(size: (5mm, 5mm), relative: "self")[
      #place(top + left, line(length: 100%, stroke: _rule))
      #place(top + left, line(angle: 90deg, length: 100%, stroke: _rule))
    ]
  }
}

// A crease is a faint shadow with a faint highlight just below it.
#let _crease(at) = {
  place(top + left, dy: at, line(length: 100%, stroke: 0.5pt + rgb("#00000018")))
  place(top + left, dy: at + 0.6pt, line(length: 100%, stroke: 0.5pt + rgb("#ffffff90")))
}

/// Returns the page `background` for the named surface.
///
/// - kind (str): `"plain"`, `"lined"`, `"grid"`, `"kraft"` or `"none"`.
/// - folds (bool): whether to add fold creases.
#let _page-background(kind, folds) = {
  assert(
    kind == "none" or kind in _colors,
    message: "unknown surface `" + kind + "`; choose one of: none, "
      + _colors.keys().join(", "),
  )
  if kind != "none" {
    place(top + left, rect(width: 100%, height: 100%, fill: _colors.at(kind), stroke: none))
    if kind in ("lined", "grid") {
      place(top + left, rect(width: 100%, height: 100%, fill: _ruling(kind), stroke: none))
    }
    if kind == "lined" {
      // The red margin line of a school notebook.
      place(top + left, dx: 3.4cm, line(angle: 90deg, length: 100%, stroke: 0.6pt + rgb("#e8a0a0")))
    }
  }
  if folds {
    _crease(100% / 3)
    _crease(200% / 3)
  }
}

// ==========================================================================
// ransom-note

/// Turns a whole document into a ransom note.
///
/// Use it with a show rule:
///
/// ```typ
/// #show: ransom-note.with(title: "Demands", seed: 7)
/// ```
///
/// Every piece of text in the document is cut out letter by letter. Headings
/// come out larger, because the letters follow the size of the text around
/// them. Any other named argument (`palette`, `faces`, `tilt` …) is passed on
/// to `ransom`.
///
/// - body (content): the document.
/// - title (str, none): the document title stored in the PDF metadata.
/// - seed (int, str): reshuffles every letter when changed.
/// - surface (str): what the note lies on: `"plain"`, `"lined"`, `"grid"`,
///   `"kraft"` or `"none"`.
/// - folds (bool): whether the page shows the creases of a folded letter.
/// - cut-text (bool): set to `false` to leave text alone and cut letters only
///   where you call `ransom` yourself.
/// - paper (str): the page size.
/// - margin (auto, length, dictionary): the page margin. With `auto` it is
///   2.4 cm, plus extra room on the left of lined paper for its margin line.
/// - size (length): the base size of the letters, relative to the text size.
/// - options (arguments): further options for `ransom`.
/// -> content
#let ransom-note(
  body,
  title: none,
  seed: 1,
  surface: "lined",
  folds: true,
  cut-text: true,
  paper: "a4",
  margin: auto,
  size: 1.0em,
  ..options,
) = {
  set document(title: title) if title != none
  let margin = if margin != auto { margin }
    else if surface == "lined" { (left: 4.4cm, rest: 2.4cm) }
    else { 2.4cm }
  set page(paper: paper, margin: margin, background: _page-background(surface, folds))
  let text-size = 11pt
  set text(font: "Libertinus Serif", size: text-size)
  set par(leading: 1.1em, spacing: 2.4em, justify: false)
  set heading(numbering: none)
  show heading: set block(above: 2em, below: 1.2em)
  show heading: set par(leading: 0.7em)
  show heading.where(level: 1): set text(size: 1.6em)
  show heading.where(level: 2): set text(size: 1.3em)

  if cut-text {
    // Spaces *between* runs (around `*bold*` or `code`) are real space
    // elements (0.25 em in Libertinus); widen them to match the gap that
    // `ransom` leaves between the words inside a run.
    let letters = size.abs / text-size + size.em
    let word-gap = float(options.named().at("word-gap", default: 40%))
    set text(spacing: letters * word-gap / 0.25 * 100%)
    let cut-marked = it => ransom(
      it,
      ..options,
      size: size,
      seed: (seed, "marked", it.body),
    )
    show strong: cut-marked
    show emph: cut-marked
    // Each run of text gets its own seed, derived from its content, so that
    // runs with different words do not share the same random look.
    show document-text: it => ransom(
      it.text, ..options, size: size, seed: (seed, it.text),
    )
    // Apostrophes and quotes are `smartquote` elements, not text, so they get
    // a rule of their own. They split a word such as "can't" into three runs;
    // word joiners keep those from wrapping apart as "can'" / "t". (The joiner
    // is marked like a tile label so that `document-text` leaves it alone.)
    let joiner = text(overhang: false, sym.wj)
    show smartquote: it => {
      joiner
      ransom(
        if it.double { "\"" } else { "'" },
        ..options, size: size, seed: (seed, "quote"),
      )
      joiner
    }
    // Inline code is not a plain text element, so it needs a rule of its own.
    show raw: it => ransom(
      it.text, ..options, size: size, seed: (seed, it.text),
    )
    // List numbers are produced by the numbering function.
    set enum(numbering: n => ransom(
      str(n) + ".", ..options, size: size, seed: (seed, "enum", n),
    ))
    body
  } else {
    body
  }
}
