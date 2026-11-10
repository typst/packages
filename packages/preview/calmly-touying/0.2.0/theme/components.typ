// Reusable Components - Theme-Aware
// All components accept optional `colors` parameter for theming
#import "colors.typ": *
#import "typography.typ": *

// =============================================================================
// HELPER: Get colors from theme or state
// =============================================================================

// Resolve colors - either from explicit parameter, or from state, or fallback
// This must be called INSIDE a context block to work with state
#let resolve-theme-colors(colors-param) = {
  if colors-param != none {
    colors-param
  } else {
    let from-state = theme-colors-state.get()
    if from-state != none { from-state } else { warm-amber-light }
  }
}

// Get a specific color from a colors dict
#let get-color-from(colors, key) = {
  colors.at(key, default: rgb("#888888"))
}

// =============================================================================
// LAYOUT COMPONENTS
// =============================================================================

// Two-column layout with proper gutter
#let two-col(left, right, gutter: spacing-xl) = {
  grid(
    columns: (1fr, 1fr),
    column-gutter: gutter,
    left, right
  )
}

// Three-column layout
#let three-col(a, b, c, gutter: spacing-lg) = {
  grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: gutter,
    a, b, c
  )
}

// Spacer helper
#let spacer(size: spacing-lg) = v(size)

// =============================================================================
// BOX COMPONENTS
// =============================================================================

// Soft shadow box helper
#let soft-shadow-box(
  body,
  fill: none,
  radius: radius-lg,
  inset: spacing-lg,
  width: 100%,
  colors: none,
) = context {
  let c = resolve-theme-colors(colors)
  let bg = if fill != none { fill } else { get-color-from(c, "bg-elevated") }
  let border = get-color-from(c, "border-subtle")

  block(
    width: width,
    inset: 0pt,
    outset: 0pt,
  )[
    #box(
      width: 100%,
      radius: radius,
      fill: bg,
      stroke: 0.5pt + border,
      inset: inset,
    )[
      #body
    ]
  ]
}

// Elegant highlight box with soft left accent
#let highlight-box(body, title: none, colors: none) = context {
  let c = resolve-theme-colors(colors)

  block(
    fill: gradient.linear(
      angle: 90deg,
      (get-color-from(c, "accent-subtle"), 0%),
      (get-color-from(c, "bg-elevated"), 15%),
      (get-color-from(c, "bg-elevated"), 100%),
    ),
    stroke: (
      left: 2.5pt + get-color-from(c, "accent-primary"),
      rest: 0.5pt + get-color-from(c, "border-subtle"),
    ),
    inset: (left: spacing-lg, right: spacing-md, top: spacing-md, bottom: spacing-md),
    radius: (left: 2pt, right: radius-md),
    width: 100%,
  )[
    #if title != none {
      text(
        weight: "medium",
        fill: get-color-from(c, "accent-deep"),
        size: size-small,
      )[#title]
      v(spacing-xs)
    }
    #text(fill: get-color-from(c, "text-secondary"))[#body]
  ]
}

// Elegant algorithm box with refined header
#let algorithm-box(body, title: none, colors: none) = context {
  let c = resolve-theme-colors(colors)

  block(
    fill: get-color-from(c, "bg-elevated"),
    stroke: 0.5pt + get-color-from(c, "border-soft"),
    radius: radius-lg,
    width: 100%,
    clip: true,
  )[
    #if title != none {
      block(
        fill: get-color-from(c, "bg-wash"),
        width: 100%,
        inset: (x: spacing-md, y: spacing-sm),
      )[
        #text(
          weight: "medium",
          fill: get-color-from(c, "accent-primary"),
          size: size-small,
          tracking: tracking-wide,
        )[#title]
      ]
    }
    #block(inset: spacing-md)[
      #set text(font: font-mono, size: size-code, fill: get-color-from(c, "text-secondary"))
      #set par(leading: 1em)
      #show math.equation: set text(size: size-body)
      #body
    ]
  ]
}

// Elegant code block with soft styling
#let code-block(code, lang: none, colors: none) = context {
  let c = resolve-theme-colors(colors)

  block(
    fill: get-color-from(c, "bg-surface"),
    stroke: 0.5pt + get-color-from(c, "border-soft"),
    radius: radius-md,
    inset: spacing-md,
    width: 100%,
  )[
    #set text(font: font-mono, size: size-code, fill: get-color-from(c, "text-secondary"))
    #raw(code, lang: lang)
  ]
}

// =============================================================================
// TEXT HELPERS
// =============================================================================

// Soft alert/emphasis text
#let alert(body, colors: none) = context {
  let c = resolve-theme-colors(colors)
  text(fill: get-color-from(c, "accent-primary"), weight: "medium")[#body]
}

// Muted text helper
#let muted(body, colors: none) = context {
  let c = resolve-theme-colors(colors)
  text(fill: get-color-from(c, "text-muted"), size: size-caption)[#body]
}

// Subtle text
#let subtle(body, colors: none) = context {
  let c = resolve-theme-colors(colors)
  text(fill: get-color-from(c, "text-light"), size: size-small)[#body]
}

// Elegant figure caption
#let fig-caption(body, colors: none) = context {
  let c = resolve-theme-colors(colors)
  text(
    fill: get-color-from(c, "text-muted"),
    size: size-caption,
    style: "italic",
    tracking: tracking-wide,
  )[#body]
}

// =============================================================================
// VISUAL ELEMENTS
// =============================================================================

// Elegant accent line with gradient fade
#let accent-line(width: 64pt, colors: none) = context {
  let c = resolve-theme-colors(colors)

  box(width: width, height: 2pt)[
    #rect(
      width: 100%,
      height: 100%,
      radius: 1pt,
      fill: gradient.linear(
        angle: 0deg,
        (get-color-from(c, "accent-secondary"), 0%),
        (get-color-from(c, "accent-primary"), 50%),
        (get-color-from(c, "accent-secondary"), 100%),
      ),
    )
  ]
}

// Soft divider line
#let soft-divider(width: 100%, colors: none) = context {
  let c = resolve-theme-colors(colors)
  line(length: width, stroke: 0.5pt + get-color-from(c, "border-subtle"))
}

// Refined bullet point with soft accent
#let bullet(body, colors: none) = context {
  let c = resolve-theme-colors(colors)
  grid(
    columns: (auto, 1fr),
    column-gutter: spacing-sm,
    align(top)[
      #box(
        width: 5pt,
        height: 5pt,
        radius: radius-full,
        fill: get-color-from(c, "accent-secondary"),
        baseline: 0.4em,
      )
    ],
    body
  )
}

// Pill/tag component
#let pill(body, accent: false, colors: none) = context {
  let c = resolve-theme-colors(colors)
  let c-accent-subtle = get-color-from(c, "accent-subtle")
  let c-bg-surface = get-color-from(c, "bg-surface")
  let c-accent-secondary = get-color-from(c, "accent-secondary")
  let c-border-subtle = get-color-from(c, "border-subtle")
  let c-accent-deep = get-color-from(c, "accent-deep")
  let c-text-muted = get-color-from(c, "text-muted")

  box(
    fill: if accent { c-accent-subtle } else { c-bg-surface },
    stroke: 0.5pt + if accent { c-accent-secondary.transparentize(50%) } else { c-border-subtle },
    radius: radius-full,
    inset: (x: spacing-sm, y: spacing-2xs),
  )[
    #text(
      size: size-micro,
      weight: "medium",
      fill: if accent { c-accent-deep } else { c-text-muted },
    )[#body]
  ]
}

// Quote block
#let quote-block(body, attribution: none, colors: none) = context {
  let c = resolve-theme-colors(colors)

  block(
    inset: (left: spacing-lg, y: spacing-sm),
    stroke: (left: 2pt + get-color-from(c, "border-soft")),
  )[
    #text(style: "italic", fill: get-color-from(c, "text-secondary"), size: size-body)[#body]
    #if attribution != none {
      v(spacing-xs)
      text(fill: get-color-from(c, "text-muted"), size: size-caption)[— #attribution]
    }
  ]
}

// =============================================================================
// CARD COMPONENTS
// =============================================================================

// Refined person card for acknowledgements
#let person-card(name, role, image-path: none, colors: none) = context {
  let c = resolve-theme-colors(colors)

  align(center)[
    #if image-path != none {
      box(
        width: 72pt,
        height: 72pt,
        radius: radius-full,
        clip: true,
        stroke: 1.5pt + get-color-from(c, "border-soft"),
        fill: get-color-from(c, "bg-muted"),
      )[
        #image(image-path, width: 100%, height: 100%, fit: "cover")
      ]
    } else {
      // Elegant placeholder with initials-style circle
      box(
        width: 72pt,
        height: 72pt,
        radius: radius-full,
        fill: gradient.radial(
          (get-color-from(c, "bg-muted"), 0%),
          (get-color-from(c, "bg-surface"), 100%),
        ),
        stroke: 1.5pt + get-color-from(c, "border-soft"),
      )[
        #align(center + horizon)[
          #text(fill: get-color-from(c, "text-light"), size: 28pt, weight: "light")[#name.first()]
        ]
      ]
    }
    #v(spacing-sm)
    #text(weight: "medium", size: size-body, fill: get-color-from(c, "text-primary"))[#name]
    #v(spacing-3xs)
    #text(fill: get-color-from(c, "text-muted"), size: size-caption)[#role]
  ]
}

// Refined institution card
#let institution-card(name, logo-path: none, colors: none) = context {
  let c = resolve-theme-colors(colors)

  align(center)[
    #if logo-path != none {
      box(height: 48pt)[
        #image(logo-path, height: 100%)
      ]
    } else {
      box(
        width: 100pt,
        height: 48pt,
        fill: get-color-from(c, "bg-surface"),
        radius: radius-md,
        stroke: 0.5pt + get-color-from(c, "border-subtle"),
      )[
        #align(center + horizon)[
          #text(fill: get-color-from(c, "text-light"), size: size-caption, weight: "medium")[#name]
        ]
      ]
    }
    #v(spacing-xs)
    #text(fill: get-color-from(c, "text-muted"), size: size-caption)[#name]
  ]
}

// Contact info item with icon placeholder
#let contact-item(content, colors: none) = context {
  let c = resolve-theme-colors(colors)
  text(fill: get-color-from(c, "text-muted"), size: size-caption)[#content]
}

// =============================================================================
// ALERT AND EXAMPLE BOXES (Moloch-inspired)
// =============================================================================

// Alert box - for warnings, important notes, critical information
#let alert-box(body, title: none, colors: none) = context {
  let c = resolve-theme-colors(colors)
  let c-alert-bg = get-color-from(c, "alert-bg")
  let c-alert-border = get-color-from(c, "alert-border")
  let c-alert-text = get-color-from(c, "alert-text")
  let c-text-secondary = get-color-from(c, "text-secondary")

  block(
    fill: c-alert-bg,
    stroke: (
      left: 3pt + c-alert-border,
      rest: 0.5pt + c-alert-border.transparentize(60%),
    ),
    inset: (left: spacing-lg, right: spacing-md, top: spacing-md, bottom: spacing-md),
    radius: (left: 2pt, right: radius-md),
    width: 100%,
  )[
    #if title != none {
      text(
        weight: "semibold",
        fill: c-alert-text,
        size: size-small,
        tracking: tracking-wide,
      )[#title]
      v(spacing-xs)
    }
    #text(fill: c-text-secondary)[#body]
  ]
}

// Example box - for examples, code samples, demonstrations
#let example-box(body, title: none, colors: none) = context {
  let c = resolve-theme-colors(colors)
  let c-example-bg = get-color-from(c, "example-bg")
  let c-example-border = get-color-from(c, "example-border")
  let c-example-text = get-color-from(c, "example-text")
  let c-text-secondary = get-color-from(c, "text-secondary")

  block(
    fill: c-example-bg,
    stroke: (
      left: 3pt + c-example-border,
      rest: 0.5pt + c-example-border.transparentize(60%),
    ),
    inset: (left: spacing-lg, right: spacing-md, top: spacing-md, bottom: spacing-md),
    radius: (left: 2pt, right: radius-md),
    width: 100%,
  )[
    #if title != none {
      text(
        weight: "semibold",
        fill: c-example-text,
        size: size-small,
        tracking: tracking-wide,
      )[#title]
      v(spacing-xs)
    }
    #text(fill: c-text-secondary)[#body]
  ]
}

// Generic block with transparent or filled mode (Moloch-style)
#let themed-block(body, title: none, fill-mode: "transparent", colors: none) = context {
  let c = resolve-theme-colors(colors)
  let c-bg-surface = get-color-from(c, "bg-surface")
  let c-bg-elevated = get-color-from(c, "bg-elevated")
  let c-border-soft = get-color-from(c, "border-soft")
  let c-accent-primary = get-color-from(c, "accent-primary")
  let c-text-secondary = get-color-from(c, "text-secondary")

  let bg = if fill-mode == "fill" { c-bg-surface } else { c-bg-elevated }

  block(
    fill: bg,
    stroke: 0.5pt + c-border-soft,
    inset: spacing-md,
    radius: radius-lg,
    width: 100%,
  )[
    #if title != none {
      text(
        weight: "semibold",
        fill: c-accent-primary,
        size: size-body,
      )[#title]
      v(spacing-sm)
    }
    #text(fill: c-text-secondary)[#body]
  ]
}

// =============================================================================
// HAND-DRAWN LIST SYMBOLS (Moloch-inspired)
// =============================================================================

// Level 1: Filled circle
#let bullet-circle(size: 6pt, color: accent-secondary) = {
  circle(radius: size / 2, fill: color)
}

// Level 2: Filled square
#let bullet-square(size: 5pt, color: accent-secondary) = {
  rect(width: size, height: size, fill: color)
}

// Level 3: Dash/line
#let bullet-dash(size: 8pt, color: accent-secondary) = {
  rect(width: size, height: 2pt, fill: color, radius: 1pt)
}

// =============================================================================
// CITATION GADGET
// =============================================================================

// Citation gadget - small box shown at slide corner with integrated bibliography citation
// bib-key: single key (string) or multiple keys (array of strings)
// display-label: display text - if none, uses the citation key(s)
// Position options: "top-right", "bottom-left", "bottom-right"
#let cite-box(bib-key, display-label: none, position: "bottom-right", colors: none) = context {
  let c = resolve-theme-colors(colors)

  // Handle single or multiple keys
  let keys = if type(bib-key) == array { bib-key } else { (bib-key,) }

  // Use provided label or show citation key(s)
  let display-content = if display-label != none { display-label } else { keys.join(", ") }

  // Hidden citations to register with bibliography (placed outside box)
  place(hide[#for key in keys { cite(label(key)) }])

  let cite-pill = box(
    fill: get-color-from(c, "bg-wash"),
    stroke: (
      left: 1.5pt + get-color-from(c, "accent-primary"),
      rest: 0.5pt + get-color-from(c, "border-subtle"),
    ),
    radius: (right: 4pt),
    inset: (left: spacing-xs, right: spacing-sm, y: spacing-2xs),
  )[
    // Clickable link to bibliography slide
    #link(<bibliography>)[
      #text(
        size: size-micro,
        fill: get-color-from(c, "text-secondary"),
      )[#emph[#display-content]]
    ]
  ]

  // Position in corner
  if position == "top-right" {
    place(top + right, dx: -spacing-md, dy: spacing-md)[#cite-pill]
  } else if position == "bottom-left" {
    place(bottom + left, dx: spacing-md, dy: -spacing-md)[#cite-pill]
  } else {
    place(bottom + right, dx: -spacing-md, dy: -spacing-md)[#cite-pill]
  }
}
