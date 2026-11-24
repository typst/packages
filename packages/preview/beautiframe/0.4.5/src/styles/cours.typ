// ═══════════════════════════════════════════════════════════════════════════
// COURS STYLE - French mathematics course layout
// ═══════════════════════════════════════════════════════════════════════════
//
// Two-column grid: right-aligned bold label in a fixed left column (2 cm
// wide + 1 cm margin overhang), content with a thin left border on the right.
// Optimised for A4 course sheets with 2.2 cm margins.
//
// Variants:
//   - standard:  Main environments (théorème, définition, …)
//   - accent:    Colored border/label using the env-color
//   - minimal:   Inline label, no border — for remarques
//   - proof:     Proof with QED symbol
//   - subtle:    Lighter muted label, thin border
//   - inline:    Completely inline, no grid
//

// ─────────────────────────────────────────────────────────────────────────
// Layout constants — match the coursEG page geometry
// ─────────────────────────────────────────────────────────────────────────
#let _line-pos   = 2.0cm   // width of the label column
#let _label-extra = 1.0cm  // how far the block overhangs into the left margin

// ─────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────

// Label ink: `label-color: auto` keeps each style's own choice, `"base"`
// follows the environment colour, and an explicit colour overrides both.
#let _label-ink(cfg, fallback) = {
  let lc = cfg.at("label-color", default: auto)
  if lc == auto { fallback }
  else if lc == "base" { cfg.at("base-color", default: fallback) }
  else { lc }
}

#let _build-label(title, name, num, cfg, color: black) = {
  let color = _label-ink(cfg, color)
  set text(hyphenate: false)
  align(right)[
    #box[
      #text(weight: cfg.label-weight, size: cfg.label-size, fill: color)[
        #title#if num != none [ #num]
      ]
    ]
    #if name != none {
      linebreak()
      box[#text(size: cfg.label-size - 2pt, style: "italic")[#name]]
    }
  ]
}

#let _grid-layout(label-content, body, cfg, border-color: black, border-width: 1pt) = {
  block(
    above: 1.2em,
    below: 1.2em,
    width: 100% + _label-extra,
    breakable: cfg.breakable,
    inset: (left: -_label-extra, right: _label-extra),
  )[
    #grid(
      columns: (_line-pos + _label-extra, 1fr),
      column-gutter: 6pt,
      align: (right + top, left + top),
      label-content,
      block(
        width: 100%,
        stroke: (left: border-width + border-color),
        inset: (left: 6pt, y: 0pt),
        breakable: true,
      )[
        #set par(first-line-indent: 0cm)
        #body
      ],
    )
  ]
}

// ─────────────────────────────────────────────────────────────────────────
// Variants
// ─────────────────────────────────────────────────────────────────────────

// STANDARD: black border, accent-colored label
#let cours-standard(title, name, num, body, cfg, env-color) = {
  let lbl = _build-label(title, name, num, cfg, color: cfg.base-color)
  _grid-layout(lbl, body, cfg, border-color: cfg.base-color, border-width: cfg.border-width)
}

// ACCENT: env-specific color for both label and border
#let cours-accent(title, name, num, body, cfg, env-color) = {
  let lbl = _build-label(title, name, num, cfg, color: env-color)
  _grid-layout(lbl, body, cfg, border-color: env-color, border-width: cfg.border-width)
}

// SUBTLE: muted secondary color
#let cours-subtle(title, name, num, body, cfg, env-color) = {
  let lbl = _build-label(title, name, num, cfg, color: cfg.secondary-color)
  _grid-layout(lbl, body, cfg, border-color: cfg.secondary-color, border-width: 0.7pt)
}

// MINIMAL: no border, inline grid — used for remarques
#let cours-minimal(title, name, num, body, cfg, env-color) = {
  let label-text = {
    text(weight: cfg.label-weight, size: cfg.label-size)[#title]
    if num != none { text(size: cfg.label-size)[ #num] }
    if name != none {
      linebreak()
      text(size: cfg.label-size - 2pt, style: "italic")[#name]
    }
  }
  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    align(right + top)[#label-text],
    align(left + top)[#body],
  )
}

// INLINE: completely inline, no grid
#let cours-inline(title, name, num, body, cfg, env-color) = {
  block(width: 100%, breakable: cfg.breakable, {
    text(weight: cfg.label-weight, title)
    if num != none { text([ #num]) }
    if name != none {
      text(" (")
      if cfg.name-style == "italic" { emph(name) } else { name }
      text(")")
    }
    text(". ")
    body
  })
}

// PROOF: proof with QED
#let cours-proof(body, cfg) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    align(left + top)[*#cfg.proof-label.*],
    align(left + top)[#body #h(1fr)#cfg.qed-symbol],
  )
}

// ─────────────────────────────────────────────────────────────────────────
// Export
// ─────────────────────────────────────────────────────────────────────────

// ═══════════════════════════════════════════════════════════════════════════
// TROU: reserved fill-in space, hint sitting in the label column
// ═══════════════════════════════════════════════════════════════════════════
#let cours-trou(interior, hint, cfg, color, nested: false) = {
  if nested {
    // Inside an environment body: no label column, plain left-ruled block
    block(
      width: 100%,
      above: 0.7em,
      below: 0.7em,
      breakable: false,
      stroke: if cfg.trou-frame { (left: 0.7pt + color) } else { none },
      inset: if cfg.trou-frame { (left: 0.6em, y: 0.3em) } else { (x: 0pt, y: 0pt) },
      {
        if hint != none {
          text(size: cfg.trou-hint-size, style: "italic", fill: color)[#hint]
          v(0.2em, weak: true)
        }
        interior
      },
    )
  } else {
    let label = if hint == none { [] } else {
      align(right)[
        #text(size: cfg.label-size - 2pt, style: "italic", fill: color)[#hint]
      ]
    }
    _grid-layout(
      label, interior, cfg,
      border-color: color,
      border-width: if cfg.trou-frame { 0.7pt } else { 0pt },
    )
  }
}

#let cours-style = (
  standard: cours-standard,
  accent:   cours-accent,
  subtle:   cours-subtle,
  minimal:  cours-minimal,
  inline:   cours-inline,
  proof:    cours-proof,
  trou: cours-trou,
)
