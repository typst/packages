// ============================================================
//  lib.typ - Aircraft checklist template for Typst (A4 / A5)
//  Requires Typst 0.12 or newer.
//
//  Usage:
//    #import "@preview/procedure-checklist:0.1.0": *
//    #show: checklist.with(title: "Cessna 152", paper: "a4")
//    #section("Before Start")[
//      #item("Parking Brake", "SET")
//    ]
// ============================================================

// ---------- internal state ----------------------------------
#let _accent   = state("cl-accent", black)
#let _numbered = state("cl-numbered", false)
#let _boxes    = state("cl-boxes", false)
#let _n        = counter("cl-item")

// ---------- dotted leader ------------------------------------
#let _leader = box(width: 1fr, inset: (x: 3pt), repeat[.])

// ============================================================
//  item() - a single checklist line: "Name .......... ACTION"
//
//  name    : label (left side)
//  action  : target state (right side). none = plain text, no leader
//  indent  : extra left indent
// ============================================================
#let item(name, action: none, indent: 0pt, ..rest) = {
  // also allow the short form:  #item("Flaps", "UP")
  let action = if action == none and rest.pos().len() > 0 {
    rest.pos().at(0)
  } else { action }

  _n.step()

  block(
    width: 100%,
    breakable: false,
    inset: (left: indent),
    above: 0.5em,
    below: 0.5em,
    context {
      let pre = if _numbered.get() {
        box(width: 1.6em, align(right, str(_n.get().first()) + "."))
        h(0.4em)
      } else if _boxes.get() {
        box(
          width: 0.75em, height: 0.75em, baseline: 0.08em,
          stroke: 0.5pt + _accent.get(),
        )
        h(0.45em)
      }

      if action == none {
        par(hanging-indent: 1.4em)[#pre#name]
      } else {
        par(hanging-indent: 1.4em)[#pre#name#_leader#action]
      }
    },
  )
}

// ============================================================
//  sub() - sub-line / clarification below an item
// ============================================================
#let sub(body, indent: 1.8em, font-size: 0.88em) = block(
  width: 100%,
  inset: (left: indent),
  above: 0.05em,
  below: 0.2em,
  text(size: font-size, body),
)

// ============================================================
//  note() - small italic remark
// ============================================================
#let note(body, indent: 1.8em, font-size: 0.85em) = block(
  width: 100%,
  inset: (left: indent),
  above: 0.1em,
  below: 0.25em,
  text(size: font-size, style: "italic", body),
)

// ============================================================
//  warn()    - highlighted note (yellow background)
//  caution() - warning box (red outline)
// ============================================================
#let warn(body, fill: rgb("#fff2a8"), font-size: 0.85em) = block(
  width: 100%,
  fill: fill,
  inset: (x: 4pt, y: 3pt),
  radius: 1.5pt,
  above: 0.35em,
  below: 0.35em,
  text(size: font-size, weight: "bold", body),
)

#let caution(body, color: rgb("#c0202a"), font-size: 0.85em) = block(
  width: 100%,
  stroke: 0.8pt + color,
  inset: (x: 5pt, y: 4pt),
  radius: 1.5pt,
  above: 0.4em,
  below: 0.4em,
  text(size: font-size, weight: "bold", fill: color, body),
)

// ============================================================
//  section() - a titled block of items
//
//  numbered      : true  -> items are numbered (1. 2. 3. ...)
//  keep-together : true  -> keep the section from splitting across
//                           columns/pages
//  color         : override heading color (e.g. red for emergencies)
//  subtitle      : small line under the heading
// ============================================================
#let section(
  title,
  numbered: false,
  keep-together: false,
  color: auto,
  subtitle: none,
  body,
) = {
  let head = context {
    let c = if color == auto { _accent.get() } else { color }
    block(
      width: 100%,
      above: 1.0em,
      below: 0.45em,
      sticky: true,
      stroke: (bottom: 0.7pt + c),
      inset: (bottom: 2.5pt),
      {
        text(size: 1.05em, weight: "bold", fill: c, smallcaps(title))
        if subtitle != none {
          linebreak()
          text(size: 0.8em, weight: "regular", style: "italic", fill: c, subtitle)
        }
      },
    )
  }

  let content = {
    _numbered.update(numbered)
    if numbered { _n.update(0) }
    head
    body
    _numbered.update(false)
  }

  if keep-together {
    block(width: 100%, breakable: false, content)
  } else {
    content
  }
}

// ============================================================
//  checklist() - main template function
//
//  paper     : "a4" or "a5" (any Typst paper size works)
//  cols      : number of columns, auto = 2 for A4, 1 for A5
//  landscape : landscape orientation
//  accent    : accent color for title and rules
//  boxes     : true -> every item gets a checkbox
//  base-size : base font size, auto = matched to paper size
//  version   : text shown bottom-left
//  footer    : text shown bottom-center
// ============================================================
#let checklist(
  title: "Checklist",
  subtitle: none,
  paper: "a4",
  cols: auto,
  landscape: false,
  accent: black,
  boxes: false,
  base-size: auto,
  font: ("Arial", "Helvetica", "Liberation Sans", "DejaVu Sans"),
  version: none,
  footer: none,
  body,
) = {
  let ncols = if cols == auto {
    if paper == "a4" { 2 } else { 1 }
  } else { cols }

  let size = if base-size == auto {
    if paper == "a4" { 9.5pt } else { 8.5pt }
  } else { base-size }

  let m = if paper == "a4" { 12mm } else { 8mm }

  set document(title: title)

  set page(
    paper: paper,
    flipped: landscape,
    margin: (x: m, top: m, bottom: m + 3mm),
    footer: context {
      set text(size: 7pt, fill: luma(90))
      grid(
        columns: (1fr, auto, 1fr),
        align(left, if version != none { "Version " + version } else { [] }),
        align(center, if footer != none { footer } else { [] }),
        align(right, counter(page).display("1 / 1", both: true)),
      )
    },
  )

  set text(font: font, size: size, hyphenate: false)
  set par(justify: false, leading: 0.5em, spacing: 0.5em)

  _accent.update(accent)
  _boxes.update(boxes)

  // ---- header ----
  block(
    width: 100%,
    above: 0pt,
    below: 0.9em,
    stroke: (bottom: 1.2pt + accent),
    inset: (bottom: 4pt),
    {
      align(center, text(
        size: if paper == "a4" { 20pt } else { 15pt },
        weight: "bold",
        fill: accent,
        title,
      ))
      if subtitle != none {
        v(1pt)
        align(center, text(
          size: 0.85em,
          weight: "bold",
          tracking: 0.6pt,
          upper(subtitle),
        ))
      }
    },
  )

  // ---- body ----
  if ncols > 1 {
    columns(ncols, gutter: 7mm, body)
  } else {
    body
  }
}
