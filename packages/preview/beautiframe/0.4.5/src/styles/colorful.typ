// ═══════════════════════════════════════════════════════════════════════════
// COLORFUL STYLE - Color-coded environments
// ═══════════════════════════════════════════════════════════════════════════
//
// Each variant uses the environment-specific color (env-color) passed
// from the main lib, allowing different colors per environment type.
//
// Variants:
//   - prominent: Thick colored border, colored header
//   - standard:  Medium colored border
//   - subtle:    Thin border, lighter color
//   - accent:    Full color treatment with tinted background
//   - minimal:   Just colored text, no border
//   - inline:    Colored inline label
//   - proof:     Proof styling
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
    text(size: cfg.label-size, [ (#name-content)])
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VARIANTS
// ═══════════════════════════════════════════════════════════════════════════

// PROMINENT: Thick colored border, colored header
// Relative luminance, 0 (black) to 1 (white)
#let _luminance(color) = {
  let comps = color.components()
  let chan(c) = if type(c) == ratio { c / 100% } else { c / 255 }
  chan(comps.at(0)) * 0.299 + chan(comps.at(1)) * 0.587 + chan(comps.at(2)) * 0.114
}

// Lighten until the target lightness is reached, so tints of a dark green and
// a bright yellow read with the same strength (see background-tint in lib).
#let _tint(color, cfg) = {
  if cfg.at("background-tint", default: auto) != auto {
    color.lighten(cfg.background-tint)
  } else {
    let l = _luminance(color)
    let target = cfg.at("background-lightness", default: 0.93)
    let t = if l >= target { 0.0 } else { (target - l) / (1.0 - l) }
    color.lighten(calc.min(t, 1.0) * 100%)
  }
}

#let colorful-prominent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: env-color + 4pt),
    inset: (left: 1em, y: 0.6em),
    {
      format-header(title, name, num, cfg, color: env-color)
      v(cfg.header-gap)
      body
    }
  )
}

// STANDARD: Medium colored border
#let colorful-standard(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: env-color + cfg.border-width),
    inset: (left: 0.8em, y: 0.5em),
    {
      format-header(title, name, num, cfg, color: env-color)
      v(cfg.header-gap)
      body
    }
  )
}

// SUBTLE: Thin border, lighter color
#let colorful-subtle(title, name, num, body, cfg, env-color) = {
  let light-color = env-color.lighten(30%)
  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (left: light-color + 1.5pt),
    inset: (left: 0.8em, y: 0.4em),
    {
      format-header(title, name, num, cfg, color: light-color)
      v(cfg.header-gap)
      text(fill: luma(40%), body)
    }
  )
}

// ACCENT: Full color treatment with tinted background
#let colorful-accent(title, name, num, body, cfg, env-color) = {
  // B&W aware background
  let bg-color = if cfg.color-mode == "bw" { white }
                 else if cfg.color-mode == "grayscale" { luma(95%) }
                 else { _tint(env-color, cfg) }

  block(
    width: 100%,
    breakable: cfg.breakable,
    fill: bg-color,
    stroke: (left: env-color + 3pt),
    inset: (left: 1em, top: 0.6em, bottom: 0.6em, right: 0.8em),
    radius: (right: cfg.border-radius),
    {
      format-header(title, name, num, cfg, color: env-color)
      v(cfg.header-gap)
      body
    }
  )
}

// MINIMAL: Just colored text, no border
#let colorful-minimal(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (left: 0.5em, y: 0.3em),
    {
      text(fill: env-color, weight: cfg.label-weight, size: cfg.label-size, title)
      if num != none {
        text(fill: env-color, size: cfg.label-size, [ #num])
      }
      if name != none {
        let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
        text(size: cfg.label-size, " (" + name-content + ")")
      }
      v(cfg.header-gap)
      body
    }
  )
}

// INLINE: Colored inline label
#let colorful-inline(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      text(fill: env-color, weight: cfg.label-weight, title)
      if num != none { text(fill: env-color, [ #num]) }
      if name != none {
        let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
        text(" (" + name-content + ")")
      }
      text(".")
      h(0.5em)
      body
    }
  )
}

// PROOF: Proof styling
#let colorful-proof(body, cfg) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      text(weight: "bold", style: "italic", cfg.proof-label + ".")
      h(0.5em)
      body
      h(1fr)
      cfg.qed-symbol
    }
  )
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPORT STYLE DICTIONARY
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// TROU: reserved fill-in space behind a left bar
// ═══════════════════════════════════════════════════════════════════════════
#let colorful-trou(interior, hint, cfg, color, nested: false) = {
  block(
    width: 100%,
    above: 0.8em,
    below: 0.8em,
    breakable: false,
    stroke: if cfg.trou-frame { (left: color + cfg.border-width) } else { none },
    inset: if cfg.trou-frame { (left: 0.8em, y: 0.45em) } else { (x: 0pt, y: 0pt) },
    {
      if hint != none {
        text(size: cfg.trou-hint-size, style: "italic", fill: color)[#hint]
        v(0.25em, weak: true)
      }
      interior
    },
  )
}

#let colorful-style = (
  prominent: colorful-prominent,
  standard: colorful-standard,
  subtle: colorful-subtle,
  accent: colorful-accent,
  minimal: colorful-minimal,
  inline: colorful-inline,
  proof: colorful-proof,
  trou: colorful-trou,
)
