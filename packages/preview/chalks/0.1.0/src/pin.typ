// Pins: invisible anchors recording position + size of wrapped content.
#let pin-label(name) = label("chalks:pin:" + name)

/// Wrap content so annotations can reference it by name. Transparent to
/// layout: the metadata element is zero-size at the content's start.
///
/// ```typst
/// The key #pin("idea")[idea].
/// #annotate(circle: "idea")
/// ```
///
/// - name (str): Page-local annotation identifier.
/// - body (content): Content to render and measure.
#let pin(name, body) = context {
  let size = measure(body)
  [#metadata((w: size.width.pt(), h: size.height.pt()))#pin-label(name)#body]
}
