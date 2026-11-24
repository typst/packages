// ============================================================================
// FLOE DESIGN SYSTEM — ACADEMIC PLAQUES (components/academic.typ)
// Thin Semantic Wrappers around Master Plaque Primitive
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": plaque

/// Helper to parse positional title / body cleanly
#let _parse-args(args, default-title: none) = {
  let title = default-title
  let body = none
  let pos = args.pos()
  if pos.len() == 1 {
    body = pos.at(0)
  } else if pos.len() >= 2 {
    title = pos.at(0)
    body = pos.at(1)
  }
  if "title" in args.named() {
    title = args.named().title
  }
  (title, body)
}

/// Formal Academic Theorem Plaque
#let theorem(..args) = {
  let (title, body) = _parse-args(args)
  let name = if "name" in args.named() { args.named().name } else { none }
  let takeaway = if "takeaway" in args.named() { args.named().takeaway } else { none }
  let num = if "num" in args.named() { args.named().num } else { none }
  let title-below = if "title-below" in args.named() { args.named().title-below } else { false }

  let resolved-title = if name != none { name } else { title }
  let resolved-subtitle = if name != none and title != none { title } else { none }

  plaque(
    tag: "THEOREM",
    num: num,
    title: resolved-title,
    subtitle: resolved-subtitle,
    accent: floe-amber,
    header-fill: floe-navy,
    title-below: title-below,
    footer: if takeaway != none [
      #grid(
        columns: (auto, 1fr),
        gutter: 6pt,
        align: (top, top),
        text(font: fonts.sans, size: 8pt, fill: rgb("#B45309"))[★],
        [
          *Key Engineering Takeaway:* #h(4pt) #takeaway
        ]
      )
    ] else { none },
    body,
  )
}

/// Formal Definition Plaque
#let definition(..args) = {
  let (title, body) = _parse-args(args)
  let num = if "num" in args.named() { args.named().num } else { none }
  let term = if "term" in args.named() { args.named().term } else { none }
  let tag-badge = if "tag" in args.named() { args.named().tag } else { none }
  let title-below = if "title-below" in args.named() { args.named().title-below } else { true }

  let display-title = if term != none { term } else { title }

  plaque(
    tag: "DEFINITION",
    num: num,
    title: display-title,
    badge-label: tag-badge,
    accent: floe-cyan,
    header-fill: rgb("#F0F9FF"),
    border-color: rgb("#BAE6FD"),
    title-below: title-below,
    body,
  )
}

/// Supporting Lemma Plaque
#let lemma(..args) = {
  let (title, body) = _parse-args(args)
  let num = if "num" in args.named() { args.named().num } else { none }
  let title-below = if "title-below" in args.named() { args.named().title-below } else { false }

  plaque(
    tag: "LEMMA",
    num: num,
    title: title,
    accent: floe-purple,
    header-fill: rgb("#FAF5FF"),
    border-color: rgb("#DDD6FE"),
    title-below: title-below,
    body,
  )
}

/// Deductive Corollary Plaque
#let corollary(..args) = {
  let (title, body) = _parse-args(args)
  let title-below = if "title-below" in args.named() { args.named().title-below } else { false }

  plaque(
    tag: "COROLLARY",
    title: title,
    accent: slate-700,
    header-fill: slate-100,
    border-color: slate-200,
    title-below: title-below,
    body,
  )
}

/// Algorithm Pseudocode Plaque
#let algorithm(..args) = {
  let (title, body) = _parse-args(args)
  let num = if "num" in args.named() { args.named().num } else { none }
  let title-below = if "title-below" in args.named() { args.named().title-below } else { false }

  plaque(
    tag: "ALGORITHM",
    num: num,
    title: title,
    accent: slate-800,
    header-fill: slate-100,
    border-color: slate-300,
    title-below: title-below,
    body,
  )
}

/// Canonical Mathematical Proof Environment with `sketch: false` Flag and QED Endmarker
#let proof(
  title: none,
  sketch: false,
  qed: true,
  ..args,
) = {
  let (parsed-title, body) = _parse-args(args, default-title: title)
  let is-sketch = if "sketch" in args.named() { args.named().sketch } else { sketch }
  let show-qed = if "qed" in args.named() { args.named().qed } else { qed }
  let label-text = if is-sketch { "PROOF SKETCH" } else { "PROOF" }

  block(
    width: 100%,
    breakable: true,
    stroke: (left: 2pt + if is-sketch { slate-300 } else { slate-400 }),
    inset: (left: 12pt, y: 6pt),
    above: 1.0em,
    below: 1.0em,
  )[
    #block(below: 0.35em, sticky: true)[
      #text(font: fonts.sans, size: text-scale.xs, weight: "bold", fill: if is-sketch { slate-500 } else { floe-navy }, tracking: 0.06em)[
        #label-text #if parsed-title != none [— #parsed-title]
      ]
    ]
    #set text(size: text-scale.base)
    #body
    #if show-qed [
      #h(1fr) #text(fill: if is-sketch { slate-400 } else { slate-700 })[$square.stroked$]
    ]
  ]
}
