// ═══════════════════════════════════════════════════════════════════════════
// ACADEMIC STYLE - Formal research paper style
// ═══════════════════════════════════════════════════════════════════════════
//
// Matches conventions from AMS and academic journals.
// Uses all-caps labels, italicized bodies for theorems.
//
// Variants:
//   - prominent: All-caps bold label, italicized body
//   - standard:  Bold label, normal body
//   - subtle:    Regular weight label, normal body
//   - accent:    Emphasized with spacing
//   - minimal:   Simple academic format
//   - inline:    Inline academic format
//   - proof:     Standard academic proof
//

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

#let format-header-caps(title, name, num, cfg) = {
  text(weight: "bold", upper(title))
  if num != none {
    text(weight: "bold", [ #num])
  }
  if name != none {
    let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
    text([ (#name-content)])
  }
}

#let format-header-normal(title, name, num, cfg, weight: "bold") = {
  text(weight: weight, title)
  if num != none {
    text(weight: weight, [ #num])
  }
  if name != none {
    let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
    text([ (#name-content)])
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VARIANTS
// ═══════════════════════════════════════════════════════════════════════════

// PROMINENT: All-caps bold label, italicized body (AMS theorem style)
#let academic-prominent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    above: 0.5em,
    below: 0.5em,
    {
      format-header-caps(title, name, num, cfg)
      text(".")
      v(cfg.header-gap)
      emph(body)
    }
  )
}

// STANDARD: Bold label, normal body
#let academic-standard(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    above: 0.4em,
    below: 0.4em,
    {
      format-header-normal(title, name, num, cfg, weight: "bold")
      text(".")
      v(cfg.header-gap)
      body
    }
  )
}

// SUBTLE: Regular weight label, normal body
#let academic-subtle(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    above: 0.3em,
    below: 0.3em,
    {
      text(style: "italic", title)
      if num != none { text(style: "italic", [ #num]) }
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

// ACCENT: Emphasized with extra spacing and rule
#let academic-accent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    above: 0.8em,
    below: 0.8em,
    {
      line(length: 100%, stroke: 0.3pt + cfg.secondary-color.lighten(50%))
      v(0.4em)
      format-header-caps(title, name, num, cfg)
      text(".")
      v(cfg.header-gap)
      emph(body)
      v(0.4em)
      line(length: 100%, stroke: 0.3pt + cfg.secondary-color.lighten(50%))
    }
  )
}

// MINIMAL: Simple academic format
#let academic-minimal(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      text(weight: "semibold", title)
      if num != none { text([ #num]) }
      text(".")
      h(0.4em)
      body
    }
  )
}

// INLINE: Inline academic format
#let academic-inline(title, name, num, body, cfg, env-color) = {
  {
    text(weight: "bold", title)
    if num != none { text(weight: "bold", [ #num]) }
    if name != none {
      let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
      text(" (" + name-content + ")")
    }
    text(":")
    h(0.4em)
    body
  }
}

// PROOF: Standard academic proof
#let academic-proof(body, cfg) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    above: 0.3em,
    below: 0.5em,
    {
      text(style: "italic", cfg.proof-label + ".")
      h(0.5em)
      body
      h(1fr)
      sym.square.filled
    }
  )
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPORT STYLE DICTIONARY
// ═══════════════════════════════════════════════════════════════════════════

#let academic-style = (
  prominent: academic-prominent,
  standard: academic-standard,
  subtle: academic-subtle,
  accent: academic-accent,
  minimal: academic-minimal,
  inline: academic-inline,
  proof: academic-proof,
)
