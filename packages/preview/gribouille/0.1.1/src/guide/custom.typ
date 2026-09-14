///! Drop arbitrary Typst content into the legend area.
///!
///! Bind via \@guides under any key (the name only routes the override; the
///! content has no associated scale) to render a free-form block alongside
///! the auto-built legends. Useful for annotations, swatch keys produced by
///! external code, branding, or anything Typst can typeset.

#import "legend.typ": _normalise-position

/// Render arbitrary Typst content as a legend slot.
///
/// Unlike scale-driven guides, `guide-custom` carries its own content and
/// has no aesthetic to consume; it sits next to the auto-built legends in
/// the order it appears in the \@guides binding.
///
/// \@category Guides
/// \@stability stable
/// \@since 0.5.0
///
/// \@param content Typst content block (markup, image, table, ...).
///
/// \@param width Block width as a length, or `auto` for the default 3cm.
///
/// \@param height Block height as a length, or `auto` for the default 2cm.
///
/// \@param title Optional title rendered above the block using the legend-title surface.
///
/// \@param position Where the custom block sits. Same accepted values as `guide-legend.position` (`"top"`, `"right"`, `"bottom"`, `"left"`, `"none"`, a Typst alignment, or a `(dx:, dy:)` / `(x:, y:)` dict).
///
/// \@param direction `"horizontal"` or `"vertical"`; `auto` infers from `position`. Affects title placement only since custom content is opaque.
///
/// \@param order Integer priority among multiple guides; lower draws first. `none` defers to the default aesthetic order.
///
/// \@param byrow Accepted for API uniformity with `guide-legend`; ignored because custom content is opaque.
///
/// \@returns Marker dictionary tagged `kind: "guide-custom"`, consumed by \@guides.
///
/// \@examples Add a free-form annotation block alongside the colour legend.
/// ```
/// //| alt: "Scatter chart with three colour-coded points and a free-form Notes panel beside the colour legend giving extra series context."
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(
///     custom: guide-custom(
///       [Series sourced from internal sales reports.],
///       width: 4cm,
///       height: 1.4cm,
///       title: "Notes",
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@guides, \@guide-legend
#let guide-custom(
  content,
  width: auto,
  height: auto,
  title: none,
  position: "right",
  direction: auto,
  order: none,
  byrow: false,
) = (
  kind: "guide-custom",
  content: content,
  width: width,
  height: height,
  title: title,
  placement: _normalise-position(position, direction, order, byrow),
)
