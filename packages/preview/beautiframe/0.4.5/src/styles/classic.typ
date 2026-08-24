// ═══════════════════════════════════════════════════════════════════════════
// CLASSIC STYLE - Traditional textbook with badge/grid layout
// ═══════════════════════════════════════════════════════════════════════════
//
// Based on env.typ pattern: two-column grid with right-aligned label
// and content with left border.
//
// Variants:
//   - prominent: Full badge layout with border, optional subtitle/figure
//   - standard:  Standard badge layout with border
//   - subtle:    Lighter border, muted label
//   - accent:    Colored border and label
//   - minimal:   Simple inline grid, no border
//   - inline:    Completely inline, no grid
//   - proof:     Proof with QED
//

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

// Build label content (badge style, right-aligned)
// Label ink: `label-color: auto` keeps each style's own choice, `"base"`
// follows the environment colour, and an explicit colour overrides both.
#let _label-ink(cfg, fallback) = {
  let lc = cfg.at("label-color", default: auto)
  if lc == auto { fallback }
  else if lc == "base" { cfg.at("base-color", default: fallback) }
  else { lc }
}

#let build-label(title, name, num, cfg, color: black, subtitle: none) = {
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
    #if subtitle != none {
      linebreak()
      box[#text(size: cfg.label-size - 2pt, style: "normal", weight: "regular")[#subtitle]]
    }
  ]
}

// Core grid-based layout (badge on left, content with border on right)
#let grid-layout(label-content, body, cfg, border-color: black, border-width: 1pt) = {
  let line-position = cfg.at("line-position", default: 2cm)
  let label-extra = cfg.at("label-extra", default: 1cm)
  let gap = 6pt

  block(
    above: 1.2em,
    below: 1.2em,
    width: 100% + label-extra,
    breakable: cfg.breakable,
    inset: (left: -label-extra, right: label-extra),
  )[
    #grid(
      columns: (line-position + label-extra, 1fr),
      column-gutter: gap,
      align: (right + top, left + top),
      // Label column
      label-content,
      // Content column with left border
      block(
        width: 100%,
        stroke: (left: border-width + border-color),
        inset: (left: gap, y: 0pt),
        breakable: true,
      )[
        #set par(first-line-indent: 0cm)
        #body
      ],
    )
  ]
}

// ═══════════════════════════════════════════════════════════════════════════
// VARIANTS
// ═══════════════════════════════════════════════════════════════════════════

// PROMINENT: Full badge layout with thicker border
#let classic-prominent(title, name, num, body, cfg, env-color) = {
  let label = build-label(title, name, num, cfg, color: cfg.base-color)
  grid-layout(label, body, cfg, border-color: cfg.base-color, border-width: cfg.border-width + 0.5pt)
}

// STANDARD: Standard badge layout with border
#let classic-standard(title, name, num, body, cfg, env-color) = {
  let label = build-label(title, name, num, cfg)
  grid-layout(label, body, cfg, border-color: black, border-width: cfg.border-width)
}

// SUBTLE: Lighter border, muted label
#let classic-subtle(title, name, num, body, cfg, env-color) = {
  let label = build-label(title, name, num, cfg, color: cfg.secondary-color)
  grid-layout(label, body, cfg, border-color: cfg.secondary-color, border-width: 0.75pt)
}

// ACCENT: Colored border and label using env-color
#let classic-accent(title, name, num, body, cfg, env-color) = {
  let label = build-label(title, name, num, cfg, color: env-color)
  grid-layout(label, body, cfg, border-color: env-color, border-width: cfg.border-width)
}

// MINIMAL: Simple inline grid, no border
#let classic-minimal(title, name, num, body, cfg, env-color) = {
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
    align(left + top)[#body]
  )
}

// INLINE: Completely inline, no grid
#let classic-inline(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      text(weight: cfg.label-weight, title)
      if num != none { text([ #num]) }
      if name != none {
        text(" (")
        if cfg.name-style == "italic" { emph(name) } else { name }
        text(")")
      }
      text(".")
      h(0.5em)
      body
    }
  )
}

// PROOF: Proof with QED symbol
#let classic-proof(body, cfg) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    align(left + top)[*#cfg.proof-label.*],
    align(left + top)[#body #h(1fr)#cfg.qed-symbol]
  )
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPORT STYLE DICTIONARY
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// TROU: reserved fill-in space, hint sitting in the label column
// ═══════════════════════════════════════════════════════════════════════════
#let classic-trou(interior, hint, cfg, color, nested: false) = {
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
    grid-layout(
      label, interior, cfg,
      border-color: color,
      border-width: if cfg.trou-frame { 0.7pt } else { 0pt },
    )
  }
}

#let classic-style = (
  prominent: classic-prominent,
  standard: classic-standard,
  subtle: classic-subtle,
  accent: classic-accent,
  minimal: classic-minimal,
  inline: classic-inline,
  proof: classic-proof,
  trou: classic-trou,
)
