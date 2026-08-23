// ===================================================================
// BYPST — LAYOUT AND COLOR UTILITIES
// Public helpers: colors, columns, callouts, text sizes, fills.
// ===================================================================

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

/// Create compact styled callout blocks with inline icons
///
/// Available types: note, tip, warning, important
/// Displays icon inline with content for space efficiency
///
/// Example: #callout(type: "warning")[Content here]
#let callout(
  type: "note",
  title: none,
  icon: none,
  body,
) = {
  // Color schemes for different callout types
  let colors = (
    note: (border: bips-blue, bg: bips-blue.lighten(90%), icon: bips-blue),
    tip: (border: bips-green, bg: bips-green.lighten(90%), icon: bips-green),
    warning: (
      border: bips-orange,
      bg: bips-orange.lighten(90%),
      icon: bips-orange,
    ),
    important: (border: red, bg: red.lighten(90%), icon: red),
  )

  // Default icons for each type
  let icons = (
    note: "📝",
    tip: "💡",
    warning: "⚠",
    important: "❗",
  )

  let color-scheme = colors.at(type, default: colors.note)
  let default-icon = icons.at(type, default: icons.note)
  let display-icon = pick-first(icon, default-icon)

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
        #if display-icon != none [#display-icon ]
        #title
      ]
      v(0.3em)
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
  set par(leading: leading)
  show list: set text(top-edge: "cap-height", bottom-edge: "baseline")
  // Tabular figures keep the enum marker gutter fixed; see the main `show enum`
  // rule above for why (proportional digits shift the marker under #pause).
  show enum: set text(
    top-edge: "cap-height",
    bottom-edge: "baseline",
    number-width: "tabular",
  )
  body
}
