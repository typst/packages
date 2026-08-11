///! Legend guide customisation.
///!
///! Build a guide spec the legend renderer respects when bound to an
///! aesthetic via \@guides. Customise level order with `reverse`, the
///! swatch grid with `nrow` / `ncolumn` / `byrow`, and placement with
///! `position` / `direction` / `order`.

#let _VALID-SIDES = ("none", "top", "right", "bottom", "left")

#let _POSITION-HELP = (
  "guide position must be one of "
    + _VALID-SIDES.map(s => "\"" + s + "\"").join(", ")
    + ", a Typst alignment, or a (dx:, dy:) / (x:, y:) dict; got "
)

// Build the canonical placement dict consumed by the legend renderer. Accepts
// a side string, a Typst `alignment` for inside-panel corner placement, or a
// dict `(dx:, dy:)` / `(x:, y:)` for arbitrary offsets. `direction` defaults
// to "horizontal" for top/bottom sides and "vertical" elsewhere; pass it
// explicitly to override. Shared with `guide-custom`.
#let _normalise-position(position, direction, order, byrow) = {
  let side = none
  let align = none
  let dx = 0pt
  let dy = 0pt

  if position == auto {
    side = auto
  } else if type(position) == str and _VALID-SIDES.contains(position) {
    side = position
  } else if type(position) == alignment {
    side = "inside"
    align = position
  } else if type(position) == dictionary {
    side = "inside"
    align = top + left
    if "dx" in position or "dy" in position {
      dx = position.at("dx", default: 0pt)
      dy = position.at("dy", default: 0pt)
    } else if "x" in position or "y" in position {
      dx = position.at("x", default: 0pt)
      dy = position.at("y", default: 0pt)
    } else {
      panic(_POSITION-HELP + repr(position))
    }
  } else {
    panic(_POSITION-HELP + repr(position))
  }

  let resolved-direction = if direction == auto {
    if side == auto {
      auto
    } else if side == "top" or side == "bottom" {
      "horizontal"
    } else { "vertical" }
  } else if direction == "horizontal" or direction == "vertical" {
    direction
  } else {
    panic(
      "guide direction must be \"horizontal\", \"vertical\", or `auto`; got "
        + repr(direction),
    )
  }

  (
    side: side,
    align: align,
    dx: dx,
    dy: dy,
    direction: resolved-direction,
    order: order,
    byrow: byrow,
  )
}

/// Customise the legend (swatch) for an aesthetic.
///
/// The returned spec carries customisation only; it is bound to an aesthetic
/// when passed through \@guides as `colour: guide-legend(...)` or similar,
/// and applied by the legend renderer when drawing the swatch.
///
/// \@category Guides
/// \@stability stable
/// \@since 0.0.1
///
/// \@param title Override the legend title; `none` keeps the default from labs or scale.
///
/// \@param nrow Number of rows when laying out levels in a grid; `none` for default.
///
/// \@param ncolumn Number of columns when laying out levels in a grid; `none` for default.
///
/// \@param reverse Reverse the order of levels.
///
/// \@param position Where the legend sits. One of `"top"`, `"right"`, `"bottom"`, `"left"`, `"none"`, a Typst alignment (e.g. `top + right`) for inside-panel placement, or a dict `(dx:, dy:)` / `(x:, y:)` for arbitrary offsets. `auto` (default) inherits the side from a `guides(default: ...)` entry when present, otherwise falls back to `"right"`. Wide horizontal legends on `"top"` / `"bottom"` can overflow the panel edge.
///
/// \@param direction Flow direction of swatch entries: `"horizontal"` or `"vertical"`. `auto` infers from `position` (horizontal for top/bottom, vertical otherwise).
///
/// \@param order Integer priority among multiple guides; lower draws first. `none` defers to the default aesthetic order.
///
/// \@param byrow Fill the swatch grid row-major when `true`; column-major (default) when `false`.
///
/// \@param align Horizontal alignment (`left`, `center`, `right`) of the entry labels, or `none` to use the per-direction default (horizontal legends centre, vertical legends left). Overrides the `legend-text` theme alignment.
///
/// \@returns Guide dictionary tagged `kind: "guide"`, consumed by \@guides.
///
/// \@examples Reverse the level order shown in the legend.
/// ```
/// //| alt: "Scatter chart of three coloured points with the fill legend listing levels c, b, a from top to bottom instead of the default a, b, c."
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(fill: guide-legend(reverse: true)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Override the legend title and lay swatches out across two
/// columns to compress the legend horizontally.
/// ```
/// //| alt: "Scatter chart of four-level fill mapping with a custom Group legend title and the four swatches laid out in two columns."
/// #let d = ()
/// #for grp in ("a", "b", "c", "d") {
///   for i in range(0, 4) { d.push((x: i, y: i, g: grp)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(fill: guide-legend(title: "Group", ncolumn: 2)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Penguin species legend rendered as a 3-column legend so it
/// sits flat under a wide panel.
/// ```
/// //| alt: "Scatter chart of penguin flipper length versus body mass with a wide Species legend laid out in three columns under the panel."
/// #plot(
///   data: penguins,
///   mapping: aes(x: "flipper-len", y: "body-mass", fill: "species"),
///   layers: (geom-point(size: 2pt),),
///   guides: guides(fill: guide-legend(title: "Species", ncolumn: 3)),
///   labs: labs(x: "Flipper Length (mm)", y: "Body Mass (g)"),
///   width: 14cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Right-align the entry labels so their right edges line up,
/// regardless of label width.
/// ```
/// //| alt: "Scatter chart of three coloured points whose fill legend labels (a, bbbb, cc) are right-aligned so their right edges share a common edge."
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "bbbb"),
///   (x: 3, y: 3, g: "cc"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(fill: guide-legend(align: right)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@guides, \@guide-none, \@plot
#let guide-legend(
  title: none,
  nrow: none,
  ncolumn: none,
  reverse: false,
  position: auto,
  direction: auto,
  order: none,
  byrow: false,
  align: none,
) = {
  if align != none and type(align) != alignment {
    panic(
      "guide-legend align must be `left`, `center`, `right`, or `none`; got "
        + repr(align),
    )
  }
  (
    kind: "guide",
    aesthetic: none,
    title: title,
    nrow: nrow,
    ncolumn: ncolumn,
    reverse: reverse,
    align: align,
    placement: _normalise-position(position, direction, order, byrow),
  )
}
