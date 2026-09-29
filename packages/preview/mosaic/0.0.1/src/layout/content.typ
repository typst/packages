// Construction, validation, and resolution of the content layout.
#import "../shared.typ": fail
#import "../grid/constructors.typ": columns, rows, track
#import "../grid/model.typ": is-track-size
#import "core.typ": make-layout, validate-variant
#import "support.typ": track-children, edge-inset, inset-cell

#let variants = (
  "body",
  "header-body",
  "body-footer",
  "header-body-footer",
)

#let validate-fields(fields) = {
  _ = validate-variant(fields.variant, variants, "layout \"content\"")
  let count = fields.columns
  if type(count) != int or count < 1 {
    fail("layout \"content\" columns must be a positive integer")
  }
  let tracks = fields.tracks
  if tracks != auto and (
    type(tracks) != array
      or tracks.len() != count
      or not tracks.all(is-track-size)
  ) {
    fail(
      "layout \"content\" tracks must be auto or an array of "
        + str(count) + " native Typst track sizes",
    )
  }
  fields
}

/// Creates a conventional header, body, and footer grid recipe.
///
/// This is the ordinary slide layout, and the one automatic level-two headings
/// resolve to. It builds a vertical Mosaic split whose body child is a
/// horizontal split of plain cells.
///
/// ```typ
/// #mosaic.slide(
///   layout: mosaic.layouts.content(variant: "header-body", columns: 2),
///   [== Two columns],
///   [Left body],
///   [Right body],
/// )
/// ```
///
/// *Cells*
///
/// The surrounding `mosaic.slide` fills cells in traversal order:
///
/// - `header`, when the variant includes one.
/// - `body`, or `body-1`, `body-2`, and so on when `columns` is above one.
/// - `footer`, when the variant includes one.
///
/// A setup-level `content: (footer: ...)` default can satisfy the footer, so a
/// positional slide may omit that final block.
///
/// *Variants*
///
/// - `body`: one region, edge to edge.
/// - `header-body`: a content-sized header above the body.
/// - `body-footer`: the body above a content-sized footer.
/// - `header-body-footer`: both. The default.
///
/// *Labels*
///
/// Every resolved cell carries a label, so appearance comes from native Typst
/// rules:
///
/// - `mosaic-cell-header`: the header, in the variants that include one.
/// - `mosaic-cell-body`: the body, when `columns` is one.
/// - `mosaic-cell-body-1`, `mosaic-cell-body-2`, and so on: the body columns,
///   when `columns` is above one.
/// - `mosaic-cell-footer`: the footer, in the variants that include one.
///
/// *Styling*
///
/// The layout is purely structural, so its looks come from rules on those
/// labels.
///
/// ```typ
/// #show label("mosaic-cell-header"): mosaic.surface(fill: luma(240))
/// ```
///
/// The header cell carries no special typography of its own. Put a native
/// level-two heading in its content to style it as a heading and register it
/// with outlines.
///
/// -> dictionary
#let content(
  /// Structural arrangement: `body`, `header-body`, `body-footer`, or
  /// `header-body-footer`.
  /// -> str
  variant: "header-body-footer",
  /// Number of body columns, and therefore the number of body blocks the slide
  /// must supply. Must be a positive integer.
  /// -> int
  columns: 1,
  /// Native Typst track sizes for the body columns, one per column. `auto`
  /// splits the body evenly.
  ///
  /// ```typ
  /// mosaic.layouts.content(columns: 2, tracks: (2fr, 1fr))
  /// ```
  /// -> auto | array
  tracks: auto,
) = {
  let fields = validate-fields((
    variant: variant,
    columns: columns,
    tracks: tracks,
  ))
  make-layout("content", fields)
}

#let content-tree(body, fields, settings) = {
  let children = ()
  if fields.variant in ("header-body", "header-body-footer") {
    children.push(track(
      auto,
      inset-cell(
        "header",
        settings,
        content-sized: true,
        inset: edge-inset(settings),
      ),
    ))
  }
  children.push(track(1fr, body))
  if fields.variant in ("body-footer", "header-body-footer") {
    children.push(track(
      auto,
      inset-cell(
        "footer",
        settings,
        content-sized: true,
        inset: edge-inset(settings),
      ),
    ))
  }
  rows(..children)
}

#let resolve-content-layout(command, settings) = {
  let fields = validate-fields(command.fields)
  let body-cells = range(fields.columns).map(index => inset-cell(
    if fields.columns == 1 { "body" } else { "body-" + str(index + 1) },
    settings,
  ))
  let body = columns(
    gutter: settings.spacing.gap,
    ..track-children(body-cells, fields.tracks),
  )
  content-tree(body, fields, settings)
}
