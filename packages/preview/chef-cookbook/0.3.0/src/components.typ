// Reusable visual building blocks for recipe rendering.

#import "theme.typ": colors, fonts, icons
#import "i18n.typ": translate

/// Empty checkbox for ingredient checklists.
#let checkbox = {
  box(
    height: 0.8em,
    width: 0.8em,
    stroke: 1pt + colors.muted.lighten(40%),
    radius: 2pt,
    baseline: 20%,
  )
}

/// Styled callout box for chef's notes.
/// Renders with a lightbulb icon, accent left border, and light fill.
#let note-box(body) = {
  block(
    width: 100%,
    inset: (left: 1em, rest: 0.8em),
    radius: (right: 4pt),
    stroke: (left: 3pt + colors.accent, rest: 0.5pt + colors.line),
    fill: colors.bg-ing,
  )[
    #text(
      font: fonts.header,
      size: 0.9em,
      weight: "bold",
      fill: colors.accent,
    )[
      #icons.note #h(0.3em)
      #translate("chefs-note")
    ]
    #v(0.3em)
    #text(style: "italic", size: 0.9em, fill: colors.muted, body)
  ]
}

/// Accent-colored section label with decorative underline.
/// Used to separate named groups within recipe instructions.
#let section-heading(title) = {
  v(1em)
  text(
    font: fonts.header,
    weight: "bold",
    size: 0.95em,
    tracking: 1pt,
    fill: colors.accent,
    upper(title),
  )
  v(0.2em)
  line(length: 2cm, stroke: 1pt + colors.accent.lighten(40%))
  v(0.5em)
}

/// Small pill badge for recipe tags.
#let tag-pill(label) = {
  box(
    inset: (x: 0.5em, y: 0.25em),
    radius: 3pt,
    fill: colors.accent.lighten(85%),
    stroke: 0.5pt + colors.accent.lighten(50%),
    text(
      font: fonts.header,
      size: 0.75em,
      weight: "medium",
      fill: colors.accent.darken(10%),
      label,
    ),
  )
}
