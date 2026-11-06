// ===================================================================
// BYPST — LAYOUT AND COLOR UTILITIES
// Public helpers: colors, columns, callouts, text sizes, fills.
// ===================================================================

#import "@preview/touying:0.8.0": touying-fn-wrapper-raw
#import "config.typ": *
#import "helpers.typ": *

// -------------------------------------------------------------------
// Color Utility Functions
// -------------------------------------------------------------------

/// Apply BIPS blue color to text
/// Example: #blue[This text is blue]
#let blue(content) = text(fill: bips-blue)[#content]

/// Apply BIPS logo blue color to text
/// Example: #logo-blue[This text is the same shade of blue as the BIPS logo]
#let logo-blue(content) = text(fill: bips-logo-blue)[#content]

/// Apply BIPS orange color to text
/// Example: #orange[This text is orange]
#let orange(content) = text(fill: bips-orange)[#content]

/// Apply BIPS green color to text
/// Example: #green[This text is green]
#let green(content) = text(fill: bips-green)[#content]

/// Apply gray color to text
/// Example: #gray[This text is gray]
#let gray(content) = text(fill: bips-text-gray)[#content]

// -------------------------------------------------------------------
// Author Affiliation Helper
// -------------------------------------------------------------------

/// Helper function to format author with superscript affiliations
/// Can take single number: inst(1) or multiple numbers: inst(1,4,5)
#let inst(..numbers) = {
  let nums = numbers.pos()
  if nums.len() == 0 {
    ""
  } else {
    super[#nums.map(str).join(",")]
  }
}

// -------------------------------------------------------------------
// Multi-Column Layout Helpers
// -------------------------------------------------------------------

/// Two-column layout with equal columns by default
///
/// Example: #two-columns[Left content][Right content]
/// With options: #two-columns(gutter: 2em)[Left][Right]
#let two-columns(
  gutter: 1em,
  columns: (1fr, 1fr),
  ..args,
  left,
  right,
) = {
  grid(
    columns: columns,
    gutter: gutter,
    ..args,
    left,
    right,
  )
}

/// Three-column layout with equal columns by default
///
/// Example: #three-columns[Left][Center][Right]
/// With options: #three-columns(gutter: 1.5em, columns: (1fr, 2fr, 1fr))[L][C][R]
#let three-columns(
  gutter: 1em,
  columns: (1fr, 1fr, 1fr),
  ..args,
  left,
  center,
  right,
) = {
  grid(
    columns: columns,
    gutter: gutter,
    ..args,
    left,
    center,
    right,
  )
}

// -------------------------------------------------------------------
// Callout Blocks
// -------------------------------------------------------------------

// Rendered through touying-fn-wrapper-raw so it can read the theme's
// `callout-icons` from self.store, the way Touying's own `alert` does.
#let _callout(self: none, type: "default", title: none, icon: none, body) = {
  // Color schemes for different callout types
  let colors = (
    default: (border: bips-blue, bg: luma(240), icon: bips-blue),
    note: (border: bips-blue, bg: bips-blue.lighten(90%), icon: bips-blue),
    tip: (border: bips-green, bg: bips-green.lighten(90%), icon: bips-green),
    warning: (
      border: bips-orange,
      bg: bips-orange.lighten(90%),
      icon: bips-orange,
    ),
    important: (border: red, bg: red.lighten(90%), icon: red),
  )
  // "symbol" glyphs are missing from Fira Sans but present in Typst's bundled
  // DejaVu Sans Mono / Libertinus, which glyph fallback always reaches.
  // "drawn" uses only ASCII marks, which every body font covers.
  let mark(glyph) = text(
    fill: white,
    weight: "bold",
    size: 0.7em,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    glyph,
  )
  let disc(color, inner) = box(baseline: 0.15em, circle(
    radius: 0.5em,
    fill: color,
    inset: 0pt,
    align(center + horizon, inner),
  ))
  let check = curve(
    stroke: (paint: white, thickness: 0.12em, cap: "round", join: "round"),
    curve.move((0em, 0.18em)),
    curve.line((0.16em, 0.34em)),
    curve.line((0.46em, 0em)),
  )
  let triangle(color, glyph) = box(
    width: 1.1em,
    height: 1em,
    baseline: 0.12em,
    {
      place(polygon(fill: color, (0em, 1em), (0.55em, 0em), (1.1em, 1em)))
      place(center + bottom, dy: -0.1em, mark(glyph))
    },
  )
  let style = if self == none { "symbol" } else {
    self.store.at("callout-icons", default: "symbol")
  }
  let icon-sets = (
    symbol: (note: "ℹ", tip: "✓", warning: "⚠", important: "‼"),
    emoji: (
      note: emoji.page.pencil,
      tip: emoji.lightbulb,
      warning: emoji.warning,
      important: emoji.excl,
    ),
    drawn: (
      note: disc(bips-blue, mark("i")),
      tip: disc(bips-green, box(width: 0.46em, height: 0.34em, check)),
      warning: triangle(bips-orange, "!"),
      important: disc(red, mark("!")),
    ),
  )
  let icons = if style == none { (:) } else { icon-sets.at(style) }

  let color-scheme = colors.at(type, default: colors.default)
  let default-icon = icons.at(type, default: none)
  let display-icon = pick-first(icon, default-icon)
  //

  block(
    width: 100%,
    stroke: (left: 4pt + color-scheme.border),
    fill: color-scheme.bg,
    inset: (left: 0.8em, right: 0.8em, top: 0.5em, bottom: 0.5em),
    radius: (right: 4pt),
    below: 0.8em,
  )[
    #if title != none {
      // When title is provided, show icon + title on separate line as before
      text(
        size: 0.9em,
        weight: "bold",
        fill: color-scheme.icon,
      )[
        #if display-icon != none [#display-icon ] #h(0.5em)
        #title
        #linebreak()
      ]
      body
    } else {
      // Default: icon inline with content, no title
      if display-icon != none [
        #text(fill: color-scheme.icon, size: 0.9em)[#display-icon] #h(0.5em)
      ]
      body
    }
  ]
}

/// Create compact styled callout blocks with inline icons
///
/// Available types: note, tip, warning, important
/// Displays icon inline with content for space efficiency
///
/// Example: #callout(type: "warning")[Content here]
#let callout(
  type: "default",
  title: none,
  icon: none,
  body,
) = touying-fn-wrapper-raw(
  _callout,
  type: type,
  title: title,
  icon: icon,
  body,
)

/// Convenience wrapper: note callout
#let callout-note(title: none, body) = callout(type: "note", title: title, body)

/// Convenience wrapper: tip callout
#let callout-tip(title: none, body) = callout(type: "tip", title: title, body)

/// Convenience wrapper: warning callout
#let callout-warning(title: none, body) = callout(
  type: "warning",
  title: title,
  body,
)

/// Convenience wrapper: important callout
#let callout-important(title: none, body) = callout(
  type: "important",
  title: title,
  body,
)

/// Titled content box — a shaded panel under a solid title bar, in the spirit
/// of a Beamer theorem block. Use it to frame a definition, a result, or an
/// aside that deserves more weight than a `callout` and no icon.
///
/// `fill` defaults to a light tint of `color`. The title bar text is white, so
/// pass a dark `color` (or override the whole bar via `title-color`).
///
/// Example: #card(title: "Definition")[The estimand is ...]
/// With options: #card(title: "Result", color: bips-green)[...]
#let card(
  title: none,
  color: bips-blue,
  fill: auto,
  title-color: white,
  radius: 4pt,
  width: 100%,
  inset: (x: 0.8em, y: 0.6em),
  body,
) = {
  let body-fill = if fill == auto { color.lighten(92%) } else { fill }
  block(
    width: width,
    radius: radius,
    clip: true,
    fill: body-fill,
    below: 0.8em,
  )[
    #if title != none {
      block(
        width: 100%,
        fill: color,
        inset: (x: inset.x, y: 0.4em),
        above: 0pt,
        below: 0pt,
        text(fill: title-color, weight: "bold")[#title],
      )
    }
    #block(width: 100%, inset: inset, above: 0pt, below: 0pt, body)
  ]
}

// -------------------------------------------------------------------
// Citations
// -------------------------------------------------------------------

/// Textual citation — "Author (Year)" (natbib \citet).
/// Example: #citet(<knuth1984>)
#let citet(label) = cite(label, form: "prose")

/// Parenthetical citation — "(Author, Year)" (natbib \citep).
/// The named twin of bare `@label` (which also uses form: "normal").
/// Example: #citep(<knuth1984>)
#let citep(label) = cite(label, form: "normal")

/// A citation shrunk and pushed to the right edge — unobtrusive side
/// attribution. `gap: 1fr` pushes to the far edge; `form` defaults to
/// parenthetical (pass "prose" for "Author (Year)").
/// Example: #sideref(<knuth1984>)   #sideref(<knuth1984>, form: "prose")
#let sideref(label, form: "normal", size: font-em-tiny * 1em, gap: 1fr) = {
  h(gap)
  text(size: size)[#cite(label, form: form)]
}

/// Footnote-area citation — numeric superscript inline, the citation in the
/// footnote. Defaults to prose form (parentheses read poorly after a
/// superscript).
/// Example: text#footcite(<knuth1984>)
#let footcite(label, form: "prose") = footnote(cite(label, form: form))

// -------------------------------------------------------------------
// Miscellaneous Helpers
// -------------------------------------------------------------------

/// Convenience function for vertical/horizontal fill
#let vfill = v(1fr)
#let hfill = h(1fr)

/// Compact list/enum spacing for tight layouts (e.g. multi-column slides)
///
/// Example: #compact[- Item A \ - Item B \ - Item C]
#let compact(spacing: 0.4em, leading: 0.4em, body) = {
  show list: set list(spacing: spacing)
  show enum: set enum(spacing: spacing)
  show terms: set terms(spacing: spacing)
  set par(leading: leading)
  show list: set text(top-edge: "cap-height", bottom-edge: "baseline")
  show terms: set text(top-edge: "cap-height", bottom-edge: "baseline")
  // Tabular figures keep the enum marker gutter fixed; see the main `show enum`
  // rule above for why (proportional digits shift the marker under #pause).
  show enum: set text(
    top-edge: "cap-height",
    bottom-edge: "baseline",
    number-width: "tabular",
  )
  body
}
