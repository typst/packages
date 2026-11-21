// Horizontal divider, optionally split around a title.
#import "style.typ": component-tokens, deck-colors

/// Creates a horizontal divider, optionally split around a title.
///
/// Without a title it is one full-width rule. With one, it becomes two rules
/// with the title centered between them, which is how a slide marks a change of
/// name without spending a heading on it.
///
/// ```typ
/// #mosaic.components.divider()
///
/// #mosaic.components.divider(
///   title: text(size: 0.7em)[Robustness checks],
///   stroke: 0.5pt + luma(70%),
/// )
/// ```
///
/// -> content
#let divider(
  /// Content centered between the two line segments. `none` draws one unbroken
  /// rule instead.
  /// -> content | none
  title: none,
  /// Native Typst stroke used for both line segments. `auto` draws the deck's
  /// line color at the shared component thickness.
  /// -> auto | stroke
  stroke: auto,
) = context {
  let stroke = if stroke != auto {
    stroke
  } else {
    component-tokens.rule-thickness + deck-colors().line
  }
  grid(
    columns: if title == none { (1fr,) } else { (1fr, auto, 1fr) },
    gutter: component-tokens.divider-gap,
    align: horizon,
    ..if title == none {
      (line(length: 100%, stroke: stroke),)
    } else {
      (
        line(length: 100%, stroke: stroke),
        title,
        line(length: 100%, stroke: stroke),
      )
    },
  )
}
