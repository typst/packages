// Native show-rule shorthand for painting labeled cell and plane blocks.

/// Builds the transforming rule that paints a cell's or plane's own block.
///
/// Properties of the content inside a cell, such as text, alignment, and
/// paragraphs, reach it through ordinary `set` rules on its label. The cell's
/// own surface cannot, because it is a block constructed before those rules
/// apply, so it is painted by wrapping the labeled block instead. `surface`
/// returns that standard wrapper, `it => block(width: 100%, height: 100%, ...,
/// it)`, ready to use as the body of a label rule.
///
/// ```typ
/// #show label("mosaic-cell-body"): mosaic.surface(
///   fill: luma(240),
///   stroke: 0.5pt + gray,
///   radius: 6pt,
/// )
/// ```
///
/// *What it applies to*
///
/// - Any grid cell, through its `<mosaic-cell-ID>` label.
/// - The full-slide planes, which carry `<mosaic-background>` and
///   `<mosaic-foreground>`.
///
/// Both kinds of rule may be combined with ordinary `set` rules on the same
/// label; the `set` rule styles the content and this one paints the block
/// around it.
///
/// -> function
#let surface(
  /// Paint behind the content, or `none`.
  /// -> none | color | gradient | tiling
  fill: none,
  /// Border drawn around the painted block, or `none`.
  /// -> none | length | color | gradient | stroke | tiling | dictionary
  stroke: none,
  /// Corner radius of the painted block.
  /// -> relative | dictionary
  radius: 0pt,
  /// Height of the painted block. Keep `100%` for cells in `1fr` or fixed
  /// tracks; pass `auto` for a content-sized cell in an `auto` track so the
  /// paint hugs the content.
  /// -> auto | relative
  height: 100%,
) = it => block(
  width: 100%,
  height: height,
  fill: fill,
  stroke: stroke,
  radius: radius,
  it,
)
