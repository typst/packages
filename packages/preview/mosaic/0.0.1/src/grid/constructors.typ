// Public and internal constructors for canonical grid nodes.
#import "../shared.typ": tag, fail
#import "model.typ": (
  plane-ids, is-node, is-track, axis-name,
  is-stroke, is-track-size,
)
#import "validation.typ": validate

#let resolve-cell-id(identifier, id, name) = {
  if identifier.named().len() > 0 {
    fail(name + " accepts only a cell id and optional fixed content")
  }
  let positional = identifier.pos()
  if positional.len() > 1 {
    fail(name + " accepts at most one positional argument, the cell id")
  }
  let resolved = if positional.len() == 1 {
    if id != none {
      fail("cell id must be passed positionally or through id:, not both")
    }
    positional.first()
  } else {
    id
  }
  if type(resolved) != str or resolved == "" {
    fail("cell id must be a non-empty string")
  }
  if resolved in plane-ids {
    fail("cell id " + repr(resolved) + " is reserved for the " + resolved + " plane")
  }
  resolved
}

// Internal cell constructor used by layout resolvers and setup defaults.
#let styled-cell(
  ..identifier,
  content: none,
  style: (:),
  id: none,
) = {
  let id = resolve-cell-id(identifier, id, "styled-cell")
  if type(style) != dictionary {
    fail("styled-cell style must be a dictionary")
  }
  // `auto` defers the inset to render time, where `settings.spacing.inset` is
  // readable. Injecting a literal here would silently outrank the configured
  // token, since a cell that leaves `inset` at `auto` contributes no key of its
  // own. The key is always present so an otherwise-bare cell still carries a
  // style and reaches `render-cell`.
  (
    mosaic: tag,
    kind: "cell",
    content: content,
    style: (inset: auto) + style,
    id: id,
  )
}

/// Creates a structural leaf cell in a Mosaic grid tree.
///
/// A cell is where slide content lands. Its id must be a non-empty string,
/// unique within the tree, and may not be one of the reserved plane ids
/// `background` or `foreground`. Pass it positionally or through `id:`, but
/// not both.
///
/// ```typ
/// #mosaic.grids.rows(
///   mosaic.grids.track(auto, mosaic.grids.cell("header")),
///   mosaic.grids.cell("body"),
/// )
/// ```
///
/// *Styling*
///
/// Cells are structural only. Every rendered cell is labeled
/// `<mosaic-cell-ID>`, so appearance comes from native Typst rules. Use a `set`
/// rule for properties of the content and `mosaic.surface` for the cell's own
/// block.
///
/// ```typ
/// #show label("mosaic-cell-body"): set text(size: 0.9em)
/// #show label("mosaic-cell-body"): mosaic.surface(fill: luma(240))
/// ```
///
/// -> dictionary
#let cell(
  /// The cell id, as the sole positional argument. Give it here or through
  /// `id:`.
  /// -> arguments
  ..identifier,
  /// Fixed content rendered in place of a slide body, so the surrounding slide
  /// supplies no block for this cell.
  /// -> content | none
  content: none,
  /// The cell id, when it is not passed positionally.
  /// -> str | none
  id: none,
  /// Native Typst inset applied inside the cell's labeled block. `auto` uses
  /// the `spacing.inset` configured on `setup`.
  /// -> auto | length | relative | dictionary
  inset: auto,
) = {
  if identifier.named().len() > 0 {
    fail("cell accepts only a cell id, optional fixed content, and inset")
  }
  let id = resolve-cell-id(identifier, id, "cell")
  styled-cell(
    id: id,
    content: content,
    style: if inset == auto { (:) } else { (inset: inset) },
  )
}

/// Associates an explicit native track size with one child of `columns` or
/// `rows`.
///
/// Unwrapped children of a split take `1fr` and therefore share the space
/// evenly. Wrap one in `track` to give it a size of its own.
///
/// ```typ
/// #mosaic.grids.rows(
///   mosaic.grids.track(auto, "header"),  // as tall as its content
///   "body",                              // 1fr, taking the rest
///   mosaic.grids.track(2em, "footer"),   // a fixed strip
/// )
/// ```
///
/// The wrapper is temporary: `columns` or `rows` unwraps it while constructing
/// the split, so a `track` value never appears in a resolved tree.
///
/// -> dictionary
#let track(
  /// Native Typst grid track size. `auto` sizes to the child's content, a
  /// length or ratio fixes it, and a fraction such as `2fr` takes a share of
  /// what remains.
  /// -> auto | length | ratio | relative | fraction
  size,
  /// The child to size: a string cell id, or a canonical Mosaic grid node built
  /// with `cell`, `columns`, or `rows`.
  /// -> str | dictionary
  child,
) = {
  if not is-track-size(size) {
    fail(
      "track size must be auto, a fixed or relative length, or a"
        + " fractional length",
    )
  }
  (
    mosaic: tag,
    kind: "track",
    size: size,
    child: child,
  )
}

#let validate-split-child(value) = {
  let size = 1fr
  let child = value
  if is-track(value) {
    size = value.size
    child = value.child
  }
  if type(child) == str {
    child = cell(id: child)
  } else if not is-node(child) {
    fail("columns/rows children must be string cell IDs or Mosaic grid nodes")
  }
  (size, child)
}

// Canonical branch constructor. Public callers use mosaic.grids.columns()
// and mosaic.grids.rows(), which pass a literal axis. Child normalization
// guarantees node children and a per-child track, so the trailing `validate`
// owns the structural checks; only the gutter and stroke values are validated
// here.
#let make-split(axis, gutter, stroke, children) = {
  let name = axis-name(axis)
  if children.len() == 0 {
    fail(name + " must contain at least one child")
  }
  if not is-track-size(gutter) {
    fail(name + " gutter must be a native Typst track size")
  }
  if not is-stroke(stroke) {
    fail(name + " stroke must be none or a native Typst stroke")
  }
  let parts = children.map(validate-split-child)
  let result = (
    mosaic: tag,
    kind: "split",
    axis: axis,
    tracks: parts.map(part => part.at(0)),
    gutter: gutter,
    stroke: stroke,
    children: parts.map(part => part.at(1)),
  )
  validate(result)
  result
}

/// Splits the available width, arranging its children as columns.
///
/// Children may be given in three forms, freely mixed:
///
/// - A string, which is shorthand for `cell(id)`.
/// - A node built with `cell`, `columns`, or `rows`, so splits nest to any
///   depth.
/// - Any of those wrapped in `track` to give it an explicit track size.
///
/// Each unwrapped child receives a `1fr` column, so an unadorned `columns`
/// divides the width evenly.
///
/// ```typ
/// #mosaic.grids.columns(
///   gutter: 1em,
///   stroke: 0.5pt + gray,
///   mosaic.grids.track(2fr, "left"),
///   "right",
/// )
/// ```
///
/// -> dictionary
#let columns(
  /// Native Typst track size used between adjacent columns.
  /// -> auto | length | ratio | relative | fraction
  gutter: 0pt,
  /// Stroke drawn along each interior column boundary, centered in the gutter.
  /// A gutter of `0pt` leaves the stroke sitting directly between the columns.
  /// -> none | stroke
  stroke: none,
  /// The columns: string cell ids, Mosaic grid nodes, or values wrapped with
  /// `track`. At least one is required.
  /// -> arguments
  ..children,
) = make-split("width", gutter, stroke, children.pos())

/// Splits the available height, arranging its children as rows.
///
/// Children take the same three forms as in `columns`: a string cell id, a
/// Mosaic grid node, or either wrapped in `track`. Each unwrapped child
/// receives a `1fr` row.
///
/// ```typ
/// #mosaic.grids.rows(
///   gutter: 0.7em,
///   mosaic.grids.track(auto, "header"),
///   mosaic.grids.columns(gutter: 1em, "left", "right"),
///   mosaic.grids.track(auto, "footer"),
/// )
/// ```
///
/// -> dictionary
#let rows(
  /// Native Typst track size used between adjacent rows.
  /// -> auto | length | ratio | relative | fraction
  gutter: 0pt,
  /// Stroke drawn along each interior row boundary, centered in the gutter.
  /// -> none | stroke
  stroke: none,
  /// The rows: string cell ids, Mosaic grid nodes, or values wrapped with
  /// `track`. At least one is required.
  /// -> arguments
  ..children,
) = make-split("height", gutter, stroke, children.pos())


