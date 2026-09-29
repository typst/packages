// Compact inline badge.
#import "style.typ": resolve-style, styled-body, component-tokens

/// Creates a compact inline badge.
///
/// A badge is a small pill that sits in the text flow rather than breaking it,
/// which suits a status marker, a version marker, or a keyword beside a
/// heading.
///
/// ```typ
/// == Estimator #mosaic.components.badge(role: "accent")[stable]
/// ```
///
/// Any radius at least half the badge's height rounds its ends completely, so
/// an oversized value such as `999pt` gives fully rounded pill ends. Restyle
/// the body through `text`.
///
/// ```typ
/// #mosaic.components.badge(
///   role: "warning",
///   radius: 999pt,
///   text: (weight: "bold", size: 0.7em),
/// )[draft]
/// ```
///
/// See `card` for the list of roles, how they resolve against the active
/// theme, and the full list of overrides.
///
/// -> content
#let badge(
  /// Badge content, usually a word or two.
  /// -> content
  body,
  /// Semantic role name: `neutral`, `accent`, `warning`, or `error`.
  /// -> str
  role: "neutral",
  /// Corner radius. Oversize it (`999pt`) for fully rounded pill ends.
  /// -> length | dictionary
  radius: component-tokens.badge-radius,
  /// Pill fill. `auto` uses the role's color tinted into the deck canvas.
  /// -> auto | color | gradient | tiling | none
  fill: auto,
  /// Border color. `auto` uses the role's own color.
  /// -> auto | color
  accent: auto,
  /// Border stroke. `auto` draws the standard thickness in `accent`.
  /// -> auto | stroke | dictionary | none
  stroke: auto,
  /// Padding inside the pill. `auto` uses the compact badge inset.
  /// -> auto | length | relative | dictionary
  inset: auto,
  /// Native `text` arguments merged over the role's text color, such as `size`
  /// and `weight`.
  /// -> dictionary
  text: (:),
) = context {
  let it = resolve-style(
    role: role,
    fill: fill,
    accent: accent,
    stroke: stroke,
    radius: radius,
    inset: inset,
    text: text,
    defaults: (inset: component-tokens.badge-inset),
    contextual: true,
  )
  box(
    fill: it.fill,
    stroke: it.stroke,
    radius: it.radius,
    inset: it.inset,
    styled-body(it, body),
  )
}
