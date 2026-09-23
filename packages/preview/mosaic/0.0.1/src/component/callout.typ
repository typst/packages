// Card-based callout with a semantic side stripe.
#import "style.typ": resolve-style, component-tokens
#import "card.typ": card

/// Creates a callout with a semantic side stripe.
///
/// A callout is a `card` with two additions: a colored stripe down its left
/// edge, and an optional bold title in the same color. Where `card` is a
/// neutral panel, this one announces what kind of remark it holds.
///
/// ```typ
/// #mosaic.components.callout(role: "warning", title: [Caveat])[
///   The estimate assumes independent errors.
/// ]
/// ```
///
/// *Roles*
///
/// - `accent`: the deck's accent. The default.
/// - `warning`, `error`: the status colors.
/// - `neutral`: the deck's own surface.
///
/// *Custom colors*
///
/// A role is the portable spelling, and it stays correct when the deck changes
/// theme. When a callout needs a color the palette does not name, pass
/// `accent` directly: it paints the stripe and the title. The panel keeps the
/// role's own fill, so a callout that should be tinted to match states `fill`
/// as well.
///
/// ```typ
/// #mosaic.components.callout(
///   accent: rgb("#7c3aed"),
///   fill: rgb("#f1ebfd"),
///   title: [Takeaway],
/// )[
///   Bounded work beats unbounded intent.
/// ]
/// ```
///
/// See `card` for the full list of overrides.
///
/// -> content
#let callout(
  /// Callout content.
  /// -> content
  body,
  /// Semantic role name: `accent`, `warning`, `error`, or `neutral`.
  /// -> str
  role: "accent",
  /// Bold title set above the body in the stripe color.
  /// -> content | none
  title: none,
  /// Panel fill. `auto` uses the role's color tinted into the deck canvas.
  /// -> auto | color | gradient | tiling | none
  fill: auto,
  /// Stripe and title color. `auto` uses the role's own color.
  /// -> auto | color
  accent: auto,
  /// Border stroke. `auto` draws the left stripe and no other edge.
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
  /// Native block width. Full width by default, so a column of callouts rules
  /// to one edge; `auto` hugs the content the way `card` does.
  /// -> auto | length | relative | fraction
  width: 100%,
) = context {
  let it = resolve-style(
    role: role,
    fill: fill,
    accent: accent,
    radius: radius,
    inset: inset,
    align: align,
    text: text,
    contextual: true,
  )
  // The stripe is this component's whole border, so an explicit `stroke`
  // replaces it rather than adding to it.
  let stroke = if stroke == auto {
    (left: component-tokens.callout-rail + it.accent, rest: none)
  } else {
    stroke
  }
  card(
    [
      #if title != none {
        std.text(weight: "bold", fill: it.accent)[#title]
        parbreak()
      }
      #body
    ],
    role: role,
    fill: it.fill,
    accent: it.accent,
    stroke: stroke,
    radius: it.radius,
    inset: it.inset,
    align: it.align,
    text: it.text,
    width: width,
  )
}
