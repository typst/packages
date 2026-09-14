// ═══════════════════════════════════════════════════════════════════════════
// MODERN STYLE - Contemporary clean design with geometric accents
// ═══════════════════════════════════════════════════════════════════════════
//
// Variants:
//   - prominent: Thick accent bar with rule separator
//   - standard:  Medium bar with rule
//   - subtle:    Thin bar, muted colors
//   - accent:    Uses environment-specific color
//   - minimal:   Very light styling
//   - inline:    Inline with em-dash separator
//   - proof:     Modern proof styling
//

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

// Label ink: `label-color: auto` keeps each style's own choice, `"base"`
// follows the environment colour, and an explicit colour overrides both.
#let _label-ink(cfg, fallback) = {
  let lc = cfg.at("label-color", default: auto)
  if lc == auto { fallback }
  else if lc == "base" { cfg.at("base-color", default: fallback) }
  else { lc }
}

#let format-header(title, name, num, cfg, color: black) = {
  let color = _label-ink(cfg, color)
  text(weight: cfg.label-weight, size: cfg.label-size, fill: color, title)
  if num != none {
    text(weight: cfg.label-weight, size: cfg.label-size, fill: color, [ #num])
  }
  if name != none {
    let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
    text(size: cfg.label-size, [ — #name-content])
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VARIANTS
// ═══════════════════════════════════════════════════════════════════════════

// PROMINENT: Thick accent bar with rule separator
#let modern-prominent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: cfg.base-color + 4pt),
    inset: (left: 1.2em, y: 0.6em, right: 0.5em),
    {
      format-header(title, name, num, cfg, color: cfg.base-color)
      v(0.4em)
      line(length: 100%, stroke: 0.75pt + cfg.secondary-color.lighten(40%))
      v(cfg.header-gap)
      body
    }
  )
}

// STANDARD: Medium bar with rule
#let modern-standard(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: cfg.base-color + 3pt),
    inset: (left: 1em, y: 0.5em, right: 0.5em),
    {
      format-header(title, name, num, cfg)
      v(0.3em)
      line(length: 100%, stroke: 0.5pt + cfg.secondary-color.lighten(50%))
      v(cfg.header-gap)
      body
    }
  )
}

// SUBTLE: Thin bar, muted colors
#let modern-subtle(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: cfg.secondary-color + 2pt),
    inset: (left: 1em, y: 0.5em, right: 0.5em),
    {
      text(
        weight: "semibold",
        fill: cfg.secondary-color,
        size: cfg.label-size,
        title
      )
      if num != none {
        text(fill: cfg.secondary-color, size: cfg.label-size, [ #num])
      }
      if name != none {
        let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
        text(fill: cfg.secondary-color, size: cfg.label-size, " — " + name-content)
      }
      v(cfg.header-gap)
      text(fill: cfg.secondary-color.darken(20%), body)
    }
  )
}

// ACCENT: Uses environment-specific color
#let modern-accent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: env-color + 3pt),
    inset: (left: 1em, y: 0.5em, right: 0.5em),
    {
      format-header(title, name, num, cfg, color: env-color)
      v(0.3em)
      line(length: 100%, stroke: 0.5pt + env-color.lighten(60%))
      v(cfg.header-gap)
      body
    }
  )
}

// MINIMAL: Very light styling
#let modern-minimal(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: cfg.secondary-color.lighten(40%) + 1.5pt),
    inset: (left: 0.8em, y: 0.4em),
    {
      text(size: cfg.label-size - 1pt, fill: cfg.secondary-color, {
        format-header(title, name, num, cfg, color: cfg.secondary-color)
      })
      v(cfg.header-gap)
      body
    }
  )
}

// INLINE: Inline with em-dash separator
#let modern-inline(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (left: 0.5em),
    {
      text(weight: "semibold", title)
      if num != none { text([ #num]) }
      if name != none {
        let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
        text(" — " + name-content)
      }
      text(" — ")
      body
    }
  )
}

// PROOF: Modern proof styling
#let modern-proof(body, cfg) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (left: 0.5em),
    {
      text(weight: "semibold", style: "italic", cfg.proof-label)
      h(0.3em)
      text("—")
      h(0.5em)
      body
      h(1fr)
      text(fill: cfg.secondary-color, cfg.qed-symbol)
    }
  )
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPORT STYLE DICTIONARY
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// TROU: reserved fill-in space behind the style's left bar
// ═══════════════════════════════════════════════════════════════════════════
#let modern-trou(interior, hint, cfg, color, nested: false) = {
  block(
    width: 100%,
    above: 0.8em,
    below: 0.8em,
    breakable: false,
    stroke: if cfg.trou-frame { (left: color + 2pt) } else { none },
    inset: if cfg.trou-frame { (left: 1em, y: 0.4em, right: 0.5em) } else { (x: 0pt, y: 0pt) },
    {
      if hint != none {
        text(size: cfg.trou-hint-size, weight: "semibold", fill: color)[#hint]
        v(0.25em, weak: true)
      }
      interior
    },
  )
}

#let modern-style = (
  prominent: modern-prominent,
  standard: modern-standard,
  subtle: modern-subtle,
  accent: modern-accent,
  minimal: modern-minimal,
  inline: modern-inline,
  proof: modern-proof,
  trou: modern-trou,
)
