// ═══════════════════════════════════════════════════════════════════════════
// ELEGANT STYLE - Sophisticated with decorative elements
// ═══════════════════════════════════════════════════════════════════════════
//
// Variants:
//   - prominent: Centered header with ornaments, small caps
//   - standard:  Centered with lighter ornaments
//   - subtle:    Italic inline styling
//   - accent:    Ornaments in environment color
//   - minimal:   Simple centered, no ornaments
//   - inline:    Small caps inline
//   - proof:     Elegant proof with decorative QED
//

// ═══════════════════════════════════════════════════════════════════════════
// ORNAMENT SYMBOLS
// ═══════════════════════════════════════════════════════════════════════════

#let ornament-primary = sym.diamond.stroked
#let ornament-secondary = sym.bullet
#let ornament-star = sym.star.stroked

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

#let format-centered-header(title, name, num, cfg, color: black, ornament: none) = {
  align(center, {
    if ornament != none {
      text(fill: cfg.secondary-color, ornament)
      h(0.5em)
    }
    smallcaps(text(
      weight: cfg.label-weight,
      size: cfg.label-size,
      fill: color,
      tracking: 0.05em,
      title
    ))
    if num != none {
      smallcaps(text(
        weight: cfg.label-weight,
        size: cfg.label-size,
        fill: color,
        tracking: 0.05em,
        [ #num]
      ))
    }
    if ornament != none {
      h(0.5em)
      text(fill: cfg.secondary-color, ornament)
    }
    if name != none {
      v(0.2em)
      text(
        style: "italic",
        size: cfg.label-size - 1pt,
        [(#name)]
      )
    }
  })
}

// ═══════════════════════════════════════════════════════════════════════════
// VARIANTS
// ═══════════════════════════════════════════════════════════════════════════

// PROMINENT: Centered with ornaments, emphasized
#let elegant-prominent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (x: 1.5em, y: 1em),
    {
      format-centered-header(title, name, num, cfg, color: cfg.accent-color, ornament: ornament-primary)
      v(cfg.header-gap + 0.4em)
      body
    }
  )
}

// STANDARD: Centered with lighter ornaments
#let elegant-standard(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (x: 1em, y: 0.8em),
    {
      format-centered-header(title, name, num, cfg, ornament: ornament-secondary)
      v(cfg.header-gap + 0.3em)
      body
    }
  )
}

// SUBTLE: Italic inline styling
#let elegant-subtle(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (left: 1.5em, y: 0.4em),
    {
      text(style: "italic", fill: cfg.secondary-color, title)
      if num != none {
        text(style: "italic", fill: cfg.secondary-color, [ #num])
      }
      if name != none {
        text(style: "italic", fill: cfg.secondary-color, " (" + name + ")")
      }
      text(style: "italic", fill: cfg.secondary-color, ".")
      h(0.5em)
      text(fill: cfg.secondary-color.darken(20%), body)
    }
  )
}

// ACCENT: Ornaments in environment color
#let elegant-accent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (x: 1em, y: 0.8em),
    {
      align(center, {
        text(fill: env-color, ornament-star)
        h(0.5em)
        smallcaps(text(
          weight: cfg.label-weight,
          size: cfg.label-size,
          fill: env-color,
          tracking: 0.05em,
          title
        ))
        if num != none {
          smallcaps(text(
            weight: cfg.label-weight,
            size: cfg.label-size,
            fill: env-color,
            tracking: 0.05em,
            [ #num]
          ))
        }
        h(0.5em)
        text(fill: env-color, ornament-star)
        if name != none {
          v(0.2em)
          text(style: "italic", size: cfg.label-size - 1pt, "(" + name + ")")
        }
      })
      v(cfg.header-gap + 0.3em)
      body
    }
  )
}

// MINIMAL: Simple centered, no ornaments
#let elegant-minimal(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (x: 1em, y: 0.6em),
    {
      align(center, {
        smallcaps(text(
          size: cfg.label-size - 1pt,
          fill: cfg.secondary-color,
          tracking: 0.03em,
          title
        ))
        if num != none {
          smallcaps(text(
            size: cfg.label-size - 1pt,
            fill: cfg.secondary-color,
            tracking: 0.03em,
            [ #num]
          ))
        }
        if name != none {
          v(0.15em)
          text(style: "italic", size: cfg.label-size - 2pt, fill: cfg.secondary-color, "(" + name + ")")
        }
      })
      v(cfg.header-gap)
      body
    }
  )
}

// INLINE: Small caps inline
#let elegant-inline(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      smallcaps(text(weight: cfg.label-weight, tracking: 0.03em, title))
      if num != none { smallcaps(text(tracking: 0.03em, [ #num])) }
      if name != none {
        text(style: "italic", " (" + name + ")")
      }
      text(".")
      h(0.5em)
      body
    }
  )
}

// PROOF: Elegant proof with decorative QED
#let elegant-proof(body, cfg) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    inset: (left: 1em),
    {
      text(style: "italic", smallcaps(cfg.proof-label) + ".")
      h(0.5em)
      body
      h(1fr)
      text(fill: cfg.secondary-color, sym.qed)
    }
  )
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPORT STYLE DICTIONARY
// ═══════════════════════════════════════════════════════════════════════════

#let elegant-style = (
  prominent: elegant-prominent,
  standard: elegant-standard,
  subtle: elegant-subtle,
  accent: elegant-accent,
  minimal: elegant-minimal,
  inline: elegant-inline,
  proof: elegant-proof,
)
