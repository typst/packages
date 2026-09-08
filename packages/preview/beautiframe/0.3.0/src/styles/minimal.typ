// ═══════════════════════════════════════════════════════════════════════════
// MINIMAL STYLE - Ultra-clean, print-friendly
// ═══════════════════════════════════════════════════════════════════════════
//
// All variants prioritize minimal ink usage and maximum readability.
// Great for printing or when a clean aesthetic is desired.
//
// Variants:
//   - prominent: Bold label with period, slight indent
//   - standard:  Bold label inline with body
//   - subtle:    Italic label, lighter weight
//   - accent:    Label with emphasis marker
//   - minimal:   Just the label, nothing else
//   - inline:    Completely inline, no visual separation
//   - proof:     Minimal proof with QED
//

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

#let format-label(title, name, num, cfg, weight: "bold", style: "normal") = {
  let label = text(weight: weight, style: style, title)
  if num != none {
    label = label + text(weight: weight, style: style, [ #num])
  }
  if name != none {
    let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
    label = label + text(" (" + name-content + ")")
  }
  label
}

// ═══════════════════════════════════════════════════════════════════════════
// VARIANTS
// ═══════════════════════════════════════════════════════════════════════════

// PROMINENT: Bold label with period, body on new line with indent
#let minimal-prominent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      format-label(title, name, num, cfg, weight: "bold")
      text(".")
      v(cfg.header-gap)
      pad(left: 1em, body)
    }
  )
}

// STANDARD: Bold label inline with body
#let minimal-standard(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      format-label(title, name, num, cfg, weight: "bold")
      text(".")
      h(0.5em)
      body
    }
  )
}

// SUBTLE: Italic label, lighter weight
#let minimal-subtle(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      format-label(title, name, num, cfg, weight: "regular", style: "italic")
      text(style: "italic", ".")
      h(0.5em)
      body
    }
  )
}

// ACCENT: Small caps label for distinction
#let minimal-accent(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      smallcaps(text(weight: "bold", title))
      if num != none { smallcaps(text([ #num])) }
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

// MINIMAL: Just bold label, period, content
#let minimal-minimal(title, name, num, body, cfg, env-color) = {
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

// INLINE: Completely inline, parenthesized label
#let minimal-inline(title, name, num, body, cfg, env-color) = {
  {
    text("(")
    text(weight: "semibold", title)
    if num != none { text([ #num]) }
    if name != none {
      text(": ")
      if cfg.name-style == "italic" { emph(name) } else { name }
    }
    text(")")
    h(0.3em)
    body
  }
}

// PROOF: Minimal proof with QED
#let minimal-proof(body, cfg) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      text(style: "italic", cfg.proof-label + ".")
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

#let minimal-style = (
  prominent: minimal-prominent,
  standard: minimal-standard,
  subtle: minimal-subtle,
  accent: minimal-accent,
  minimal: minimal-minimal,
  inline: minimal-inline,
  proof: minimal-proof,
)
