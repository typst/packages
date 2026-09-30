// Clipped, semantically styled block used as the base of other components.
#import "style.typ": resolve-style, styled-body

/// Wraps content in a clipped, semantically styled block.
///
/// This is the base the other components are built on, and the one to reach for
/// when you want a panel that follows the deck's colors without spelling them
/// out.
///
/// ```typ
/// #mosaic.components.card(role: "warning")[
///   The interval covers zero.
/// ]
/// ```
///
/// *Roles*
///
/// A role names one color in the deck palette. The component paints its border
/// and rails with that color, its text with the deck's text color, and its
/// panel with the color tinted into the deck's canvas, so a component tracks
/// the active theme instead of hard-coding paint.
///
/// - `neutral`: the deck's own surface, outlined in its line color. The
///   default.
/// - `accent`: the deck's accent.
/// - `warning`, `error`: the status colors.
///
/// Every one of them is a palette entry a theme or a deck can restate, so a
/// deck that wants a different warning sets `colors: (warning: ..)` at `setup`
/// once rather than restyling each component.
///
/// *Overrides*
///
/// `fill`, `accent`, `stroke`, `radius`, `inset`, `align`, and `text` each
/// default to `auto`, meaning "take it from the role". Pass one to override
/// just that part. `text` is a dictionary of native `text` arguments and is
/// merged into the role's text color rather than replacing it.
///
/// ```typ
/// #mosaic.components.card(
///   radius: 0pt,
///   stroke: none,
///   text: (size: 0.8em),
/// )[Quiet panel]
/// ```
///
/// -> content
#let card(
  /// Content inside the card.
  /// -> content
  body,
  /// Semantic role name: `neutral`, `accent`, `warning`, or `error`.
  /// -> str
  role: "neutral",
  /// Panel fill. `auto` uses the role's color tinted into the deck canvas.
  /// -> auto | color | gradient | tiling | none
  fill: auto,
  /// Border and rail color. `auto` uses the role's own color.
  /// -> auto | color
  accent: auto,
  /// Border stroke. `auto` draws the standard thickness in `accent`.
  /// -> auto | stroke | dictionary | none
  stroke: auto,
  /// Corner radius. `auto` uses the shared component radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Padding inside the panel. `auto` uses the shared component inset.
  /// -> auto | length | relative | dictionary
  inset: auto,
  /// Horizontal alignment of the body. `auto` is `left`.
  /// -> auto | alignment
  align: auto,
  /// Native `text` arguments merged over the role's text color.
  /// -> dictionary
  text: (:),
  /// Native block width. `auto` hugs the content.
  /// -> auto | length | relative | fraction
  width: auto,
  /// Native block height. `auto` hugs the content.
  /// -> auto | length | relative | fraction
  height: auto,
) = context {
  let it = resolve-style(
    role: role,
    fill: fill,
    accent: accent,
    stroke: stroke,
    radius: radius,
    inset: inset,
    align: align,
    text: text,
    contextual: true,
  )
  block(
    width: width,
    height: height,
    fill: it.fill,
    stroke: it.stroke,
    radius: it.radius,
    inset: it.inset,
    clip: true,
    styled-body(it, body),
  )
}
