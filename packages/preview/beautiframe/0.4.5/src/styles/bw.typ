// ═══════════════════════════════════════════════════════════════════════════
// BW STYLE - Black-and-white guided course layout (Gymnomath / coursCollège)
// ═══════════════════════════════════════════════════════════════════════════
//
// Two-column grid (3.35 cm label | 1fr content) with NO left-margin overhang.
// The label column is wider than in the "cours" style to accommodate a compact
// label block with an optional horizontal rule.
//
// Two content treatments:
//   standard  — horizontal rule across label top, bare content (no box)
//   boxed     — no rule, content in a light rounded-rect box
//   prominent — like boxed but thicker border (for théorèmes/propositions)
//   minimal   — simple inline label, no grid (for unnumbered remarques)
//   proof     — standard layout with trailing QED symbol
//   inline    — completely inline, no grid
//
// Color mapping:
//   primary-color   → label ink / box stroke
//   secondary-color → italic subtitle below the label
//

// ─────────────────────────────────────────────────────────────────────────
// Layout constants — match the cours-bw page geometry
// ─────────────────────────────────────────────────────────────────────────
#let _col-label  = 3.35cm
#let _col-gutter = 0.55cm
#let _box-radius = 2pt

// ─────────────────────────────────────────────────────────────────────────
// Shared label block (right-aligned, compact)
// ─────────────────────────────────────────────────────────────────────────
// Label ink: `label-color: auto` keeps each style's own choice, `"base"`
// follows the environment colour, and an explicit colour overrides both.
#let _label-ink(cfg, fallback) = {
  let lc = cfg.at("label-color", default: auto)
  if lc == auto { fallback }
  else if lc == "base" { cfg.at("base-color", default: fallback) }
  else { lc }
}

#let _bw-label(title, name, num, cfg, color: none) = {
  let c = _label-ink(cfg, if color != none { color } else { cfg.primary-color })
  set text(hyphenate: false)
  align(right)[
    #text(weight: cfg.label-weight, size: cfg.label-size, fill: c)[
      #title#if num != none [~#num]
    ]
    #if name != none [
      #linebreak()
      #text(size: cfg.label-size - 1pt, style: "italic", fill: cfg.secondary-color)[#name]
    ]
  ]
}

// ─────────────────────────────────────────────────────────────────────────
// Variants
// ─────────────────────────────────────────────────────────────────────────

// STANDARD: horizontal rule across label top, bare (unboxed) content
#let bw-standard(title, name, num, body, cfg, env-color) = {
  block(width: 100%, above: 1.55em, below: 1.55em, breakable: true)[
    #grid(
      columns: (_col-label, 1fr),
      column-gutter: _col-gutter,
      align: top,
      [
        #line(length: 100%, stroke: 0.45pt + cfg.primary-color)
        #v(-0.2em)
        #_bw-label(title, name, num, cfg)
      ],
      [
        // Invisible zero-length rule to align baselines with label column
        #line(length: 0pt, stroke: 0.45pt + white)
        #v(-0.2em)
        #body
      ],
    )
  ]
}

// BOXED: no horizontal rule, content in a light rounded rectangle
#let bw-boxed(title, name, num, body, cfg, env-color) = {
  block(width: 100%, above: 1.35em, below: 1.35em, breakable: true)[
    #grid(
      columns: (_col-label, 1fr),
      column-gutter: _col-gutter,
      align: top,
      _bw-label(title, name, num, cfg),
      block(
        width: 100%,
        inset: cfg.inset,
        stroke: cfg.border-width + cfg.primary-color,
        radius: _box-radius,
      )[#body],
    )
  ]
}

// PROMINENT: boxed with thicker stroke — for théorèmes and propositions
#let bw-prominent(title, name, num, body, cfg, env-color) = {
  block(width: 100%, above: 1.35em, below: 1.35em, breakable: true)[
    #grid(
      columns: (_col-label, 1fr),
      column-gutter: _col-gutter,
      align: top,
      _bw-label(title, name, num, cfg),
      block(
        width: 100%,
        inset: cfg.inset,
        stroke: (cfg.border-width + 0.4pt) + cfg.primary-color,
        radius: _box-radius,
      )[#body],
    )
  ]
}

// ACCENT: colored version — boxed with env-color stroke and label
#let bw-accent(title, name, num, body, cfg, env-color) = {
  block(width: 100%, above: 1.35em, below: 1.35em, breakable: true)[
    #grid(
      columns: (_col-label, 1fr),
      column-gutter: _col-gutter,
      align: top,
      _bw-label(title, name, num, cfg, color: env-color),
      block(
        width: 100%,
        inset: cfg.inset,
        stroke: cfg.border-width + env-color,
        radius: _box-radius,
      )[#body],
    )
  ]
}

// MINIMAL: no grid, simple inline bold label — for unnumbered environments
#let bw-minimal(title, name, num, body, cfg, env-color) = {
  block(width: 100%, above: 0.9em, below: 0.9em, breakable: true)[
    #text(weight: cfg.label-weight, size: cfg.label-size)[#title]
    #if num != none [ #text(size: cfg.label-size)[#num]]
    #if name != none [
      #h(0.3em)
      #text(size: cfg.label-size - 1pt, style: "italic", fill: cfg.secondary-color)[(#name)]
    ]
    #h(0.5em)
    #body
  ]
}

// INLINE: completely inline, no grid
#let bw-inline(title, name, num, body, cfg, env-color) = {
  block(width: 100%, breakable: cfg.breakable, {
    text(weight: cfg.label-weight, title)
    if num != none { text([~#num]) }
    if name != none {
      text(" (")
      if cfg.name-style == "italic" { emph(name) } else { name }
      text(")")
    }
    text(". ")
    body
  })
}

// PROOF: standard side-block layout with trailing QED
#let bw-proof(body, cfg) = {
  block(width: 100%, above: 1.55em, below: 1.55em, breakable: true)[
    #grid(
      columns: (_col-label, 1fr),
      column-gutter: _col-gutter,
      align: top,
      [
        #line(length: 100%, stroke: 0.45pt + cfg.primary-color)
        #v(-0.2em)
        #align(right)[
          #text(weight: cfg.label-weight, size: cfg.label-size, fill: cfg.primary-color)[
            #cfg.proof-label.
          ]
        ]
      ],
      [
        #line(length: 0pt, stroke: 0.45pt + white)
        #v(-0.2em)
        #body #h(1fr)#cfg.qed-symbol
      ],
    )
  ]
}

// ─────────────────────────────────────────────────────────────────────────
// Export
// ─────────────────────────────────────────────────────────────────────────

// ═══════════════════════════════════════════════════════════════════════════
// TROU: reserved fill-in space in the content column, hint in the label column
// ═══════════════════════════════════════════════════════════════════════════
#let bw-trou(interior, hint, cfg, color, nested: false) = {
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
    block(width: 100%, above: 1.1em, below: 1.1em, breakable: false)[
      #grid(
        columns: (_col-label, 1fr),
        column-gutter: _col-gutter,
        align: top,
        if hint == none { [] } else {
          align(right)[
            #text(size: cfg.label-size - 1pt, style: "italic", fill: color)[#hint]
          ]
        },
        if cfg.trou-frame {
          block(
            width: 100%,
            inset: (x: 0.5em, y: 0.4em),
            stroke: 0.5pt + color,
            radius: _box-radius,
          )[#interior]
        } else {
          interior
        },
      )
    ]
  }
}

#let bw-style = (
  standard:  bw-standard,
  boxed:     bw-boxed,
  prominent: bw-prominent,
  accent:    bw-accent,
  minimal:   bw-minimal,
  inline:    bw-inline,
  proof:     bw-proof,
  trou: bw-trou,
)
