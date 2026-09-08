// ═══════════════════════════════════════════════════════════════════════════
// BOXED STYLE - Full framed boxes with backgrounds
// ═══════════════════════════════════════════════════════════════════════════
//
// Variants:
//   - prominent: Full border with header separated by line
//   - standard:  Simple box with border
//   - subtle:    Light border, no fill
//   - accent:    Colored box using env-color
//   - minimal:   Thin border only
//   - inline:    No box, just bracketed label
//   - titled:    Label breaks top border line (beautitled-style)
//   - centered:  Label centered at top, breaking the border
//   - corner:    L border (top + left)
//   - corner2:   Inverted L border (left + bottom)
//   - proof:     Boxed proof
//

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

#let format-header(title, name, num, cfg, color: black) = {
  text(weight: cfg.label-weight, size: cfg.label-size, fill: color, title)
  if num != none {
    text(weight: cfg.label-weight, size: cfg.label-size, fill: color, [ #num])
  }
  if name != none {
    let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
    text(size: cfg.label-size, [ (#name-content)])
  }
}

// Get background color (B&W aware)
#let get-bg-color(base-color, cfg) = {
  if cfg.color-mode == "bw" {
    white  // No background in B&W mode
  } else if cfg.color-mode == "grayscale" {
    luma(95%)  // Very light gray
  } else {
    base-color.lighten(92%)
  }
}

// Get stroke color (B&W aware)
#let get-stroke-color(base-color, cfg) = {
  if cfg.color-mode == "bw" {
    black
  } else if cfg.color-mode == "grayscale" {
    luma(40%)
  } else {
    base-color
  }
}

// Get header bar fill (B&W aware)
#let get-header-fill(base-color, cfg) = {
  if cfg.color-mode == "bw" {
    luma(30%)  // Dark gray bar
  } else if cfg.color-mode == "grayscale" {
    luma(40%)
  } else {
    base-color
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VARIANTS
// ═══════════════════════════════════════════════════════════════════════════

// PROMINENT: Full border with header separated by line
#let boxed-prominent(title, name, num, body, cfg, env-color) = {
  let stroke-color = get-stroke-color(cfg.accent-color, cfg)

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: stroke-color + cfg.border-width,
    radius: cfg.border-radius,
    clip: true,
    {
      // Header (no fill, just text)
      block(
        width: 100%,
        inset: (x: 0.5em, top: 0.35em, bottom: 0.15em),
        text(weight: cfg.label-weight, size: cfg.label-size, {
          title
          if num != none { [ #num] }
          if name != none {
            let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
            " (" + name-content + ")"
          }
        })
      )
      // Separator line
      line(length: 100%, stroke: stroke-color + cfg.border-width)
      // Body
      block(
        width: 100%,
        inset: (x: 0.5em, top: 0.25em, bottom: 0.4em),
        body
      )
    }
  )
}

// STANDARD: Simple box with border
#let boxed-standard(title, name, num, body, cfg, env-color) = {
  let stroke-color = get-stroke-color(cfg.accent-color, cfg)

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: stroke-color + cfg.border-width,
    radius: cfg.border-radius,
    inset: cfg.inset,
    {
      format-header(title, name, num, cfg, color: stroke-color)
      v(cfg.header-gap)
      body
    }
  )
}

// SUBTLE: Light border, no fill
#let boxed-subtle(title, name, num, body, cfg, env-color) = {
  let stroke-color = if cfg.color-mode == "bw" { luma(60%) }
                     else if cfg.color-mode == "grayscale" { luma(70%) }
                     else { cfg.secondary-color.lighten(30%) }
  let text-color = if cfg.color-mode == "bw" { luma(40%) }
                   else if cfg.color-mode == "grayscale" { luma(50%) }
                   else { cfg.secondary-color }

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: stroke-color + 1pt,
    radius: cfg.border-radius,
    inset: cfg.inset,
    {
      format-header(title, name, num, cfg, color: text-color)
      v(cfg.header-gap)
      text(fill: text-color.darken(20%), body)
    }
  )
}

// ACCENT: Colored box using env-color
#let boxed-accent(title, name, num, body, cfg, env-color) = {
  let bg-color = get-bg-color(env-color, cfg)
  let stroke-color = get-stroke-color(env-color, cfg)

  block(
    width: 100%,
    breakable: cfg.breakable,
    fill: bg-color,
    stroke: stroke-color + cfg.border-width,
    radius: cfg.border-radius,
    inset: cfg.inset,
    {
      format-header(title, name, num, cfg, color: stroke-color)
      v(cfg.header-gap)
      body
    }
  )
}

// MINIMAL: Thin border only
#let boxed-minimal(title, name, num, body, cfg, env-color) = {
  let stroke-color = if cfg.color-mode == "bw" { luma(70%) }
                     else if cfg.color-mode == "grayscale" { luma(75%) }
                     else { cfg.secondary-color.lighten(50%) }
  let text-color = if cfg.color-mode == "bw" { luma(40%) }
                   else if cfg.color-mode == "grayscale" { luma(50%) }
                   else { cfg.secondary-color }

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: stroke-color + 0.5pt,
    radius: cfg.border-radius,
    inset: (x: 0.6em, y: 0.4em),
    {
      text(size: cfg.label-size - 1pt, fill: text-color, {
        format-header(title, name, num, cfg, color: text-color)
      })
      v(cfg.header-gap)
      body
    }
  )
}

// INLINE: No box, just bracketed label
#let boxed-inline(title, name, num, body, cfg, env-color) = {
  block(
    width: 100%,
    breakable: cfg.breakable,
    {
      text("[")
      text(weight: cfg.label-weight, title)
      if num != none { text([ #num]) }
      if name != none {
        let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
        text(": " + name-content)
      }
      text("]")
      h(0.5em)
      body
    }
  )
}

// TITLED: Label breaks the top border line (beautitled-style) - closed box
#let boxed-titled(title, name, num, body, cfg, env-color) = {
  let stroke-color = get-stroke-color(cfg.accent-color, cfg)
  let stroke-width = cfg.border-width

  // Build the label text
  let label-content = {
    text(size: cfg.label-size, {
      title
      if num != none { [ #num] }
      if name != none {
        let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
        " (" + name-content + ")"
      }
    })
  }

  let label-box = box(inset: (x: 0.4em), fill: white, text(weight: "bold", label-content))
  let indent = 0.8em

  context {
    let label-size = measure(label-box)
    let half-label-height = label-size.height / 2

    block(
      width: 100%,
      breakable: cfg.breakable,
      inset: (top: half-label-height),
      {
        // Content box with borders (drawn first, behind label)
        block(
          width: 100%,
          stroke: stroke-color + stroke-width,
          inset: (left: cfg.inset.x, right: cfg.inset.x, top: half-label-height + cfg.inset.y, bottom: cfg.inset.y),
          body
        )
        // The label at top-left (drawn on top with white background)
        place(
          top + left,
          dx: indent,
          dy: -half-label-height,
          label-box
        )
      }
    )
  }
}

// CENTERED: Label centered at top, breaking the border (no background)
#let boxed-centered(title, name, num, body, cfg, env-color) = {
  let stroke-color = get-stroke-color(cfg.accent-color, cfg)
  let bg = if cfg.color-mode == "bw" { white } else { white }

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: stroke-color + cfg.border-width,
    radius: cfg.border-radius,
    inset: cfg.inset,
    {
      // Centered label positioned at top, with white background to "break" the line
      place(
        top + center,
        dy: -cfg.inset.y - 0.5em,
        box(
          fill: bg,
          inset: (x: 0.5em, y: 0em),
          text(weight: "bold", size: cfg.label-size, {
            title
            if num != none { [ #num] }
            if name != none {
              let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
              " (" + name-content + ")"
            }
          })
        )
      )
      v(0.4em)
      body
    }
  )
}

// CORNER: L border (top + left sides only)
#let boxed-corner(title, name, num, body, cfg, env-color) = {
  let stroke-color = get-stroke-color(cfg.accent-color, cfg)

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (
      top: stroke-color + cfg.border-width * 1.5,
      left: stroke-color + cfg.border-width * 1.5,
      right: none,
      bottom: none,
    ),
    inset: cfg.inset,
    {
      // Header at top left
      text(weight: "bold", size: cfg.label-size, {
        title
        if num != none { [ #num] }
        if name != none {
          let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
          " (" + name-content + ")"
        }
      })
      v(cfg.header-gap)
      body
    }
  )
}

// CORNER2: Inverted L border (left + bottom sides only)
#let boxed-corner2(title, name, num, body, cfg, env-color) = {
  let stroke-color = get-stroke-color(cfg.accent-color, cfg)

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: (
      left: stroke-color + cfg.border-width * 1.5,
      bottom: stroke-color + cfg.border-width * 1.5,
      top: none,
      right: none,
    ),
    inset: cfg.inset,
    {
      // Header at top left
      text(weight: "bold", size: cfg.label-size, {
        title
        if num != none { [ #num] }
        if name != none {
          let name-content = if cfg.name-style == "italic" { emph(name) } else { name }
          " (" + name-content + ")"
        }
      })
      v(cfg.header-gap)
      body
    }
  )
}

// PROOF: Boxed proof
#let boxed-proof(body, cfg) = {
  let stroke-color = if cfg.color-mode == "bw" { luma(60%) }
                     else if cfg.color-mode == "grayscale" { luma(65%) }
                     else { cfg.secondary-color.lighten(40%) }

  block(
    width: 100%,
    breakable: cfg.breakable,
    stroke: stroke-color + 0.75pt,
    radius: cfg.border-radius,
    inset: (x: 0.8em, y: 0.5em),
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

#let boxed-style = (
  prominent: boxed-prominent,
  standard: boxed-standard,
  subtle: boxed-subtle,
  accent: boxed-accent,
  minimal: boxed-minimal,
  inline: boxed-inline,
  titled: boxed-titled,
  centered: boxed-centered,
  corner: boxed-corner,
  corner2: boxed-corner2,
  proof: boxed-proof,
)
