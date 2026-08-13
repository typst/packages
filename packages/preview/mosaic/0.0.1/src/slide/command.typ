// Construction and validation of deferred slide commands.
#import "../shared.typ": tag, fail, is-record
#import "../grid/model.typ": plane-ids
#import "../layout/config.typ": selectable-layout-names, validate-layout-value
#import "../layout/core.typ": layout-field-keys

// `fields` overlays layout fields onto whichever layout the selection
// resolves to, refining the configured layout rather than replacing it. The
// deck compiler uses it for the automatic section tagline; the public `slide`
// fills it from named arguments when the layout is chosen by name.
#let slide-command(
  bodies,
  layout: auto,
  numbered: auto,
  invert: false,
  cells: (:),
  background: auto,
  foreground: auto,
  fields: (:),
) = (
  mosaic: tag,
  kind: "slide",
  layout: layout,
  numbered: numbered,
  invert: invert,
  cells: cells,
  background: background,
  foreground: foreground,
  fields: fields,
  bodies: bodies,
)

// Derived from the constructor so the canonical key set cannot drift from
// the record it describes.
#let slide-command-field-keys = slide-command(()).keys().sorted()

#let is-slide-command(value) = (
  is-record(value, "slide", slide-command-field-keys, "slide command")
)

// The planes are slide parameters of their own, not entries in `cells:`: a
// plane is not a grid leaf, takes no space from the grid, and carries its own
// <mosaic-background> / <mosaic-foreground> label. `auto` inherits the deck
// plane declared on `setup`, `none` suppresses it for this slide.
#let validate-plane(value, name) = {
  if value != auto and value != none and type(value) != content {
    fail("slide " + name + " must be content, none, or auto")
  }
  value
}

#let validate-layout-selection(value) = {
  if value == auto {
    return value
  }
  if type(value) == str {
    if value not in selectable-layout-names {
      fail("slide layout name must be one of " + repr(selectable-layout-names))
    }
    return value
  }
  validate-layout-value(value, "slide layout")
}

// Named arguments on `slide` are layout fields. They only make sense when the
// layout is selected by name, because that is the case where the author has no
// constructor call to put them in: the layout comes from `setup(layouts:)`.
// Passing an explicit layout value means the constructor is right there, and
// routing fields around it would silently skip its normalization.
#let validate-layout-fields(fields, selection) = {
  if fields.len() == 0 {
    return fields
  }
  let name = fields.keys().sorted().first()
  if selection != auto and type(selection) != str {
    fail(
      "slide cannot combine layout fields with an explicit layout value; pass "
        + repr(name) + " to the layout constructor instead",
    )
  }
  let layout-name = if selection == auto { "content" } else { selection }
  let allowed = layout-field-keys.at(layout-name)
  for key in fields.keys() {
    if key not in allowed {
      fail(
        "slide layout " + repr(layout-name) + " has no field " + repr(key)
          + "; expected one of " + repr(allowed),
      )
    }
  }
  fields
}

/// Creates one logical slide command.
///
/// A logical slide is one unit of content, which may render as several physical
/// frames once incremental steps are applied.
///
/// ```typ
/// #mosaic.slide[
///   == Structure
///   Every slide resolves to a grid tree.
/// ]
/// ```
///
/// *Choosing a layout*
///
/// The selection is the one positional subject, so
/// `slide("content", variant: "body")[...]` and
/// `slide(layout: "content", variant: "body")[...]` are the same slide.
///
/// - `auto`: the configured `content` layout. The default.
/// - `"content"`, `"title"`, `"section"`: the matching entry in
///   `setup(layouts:)`. The name also determines numbering and the section
///   lifecycle.
/// - A `mosaic.layouts.*` value: used directly, carrying its own semantic name.
/// - A raw `mosaic.grids.*` tree: used directly and treated as a content layout.
///
/// *Supplying content*
///
/// Use one of the two forms, never both on the same slide:
///
/// - Positional bodies, filling cells in depth-first layout order.
/// - A `cells:` dictionary keyed by cell id, which is order-independent and
///   lets a slide skip cells.
///
/// ```typ
/// #mosaic.slide(cells: (
///   header: [== Named cells],
///   body: [Order does not matter here.],
/// ))
/// ```
///
/// *Planes*
///
/// `background:` and `foreground:` are full-slide layers rather than grid
/// cells, so they have parameters of their own. `auto` inherits the plane
/// declared on `setup`, `none` suppresses it for this slide, and content
/// overrides it.
///
/// ```typ
/// #mosaic.slide(
///   cells: (body: [Over a photograph.]),
///   background: mosaic.components.image("cover.webp"),
/// )
/// ```
///
/// *Layout fields*
///
/// Any other named argument is a field of the selected layout, so the slide
/// refines the configured layout rather than replacing it, and fields the theme
/// set survive:
///
/// ```typ
/// #mosaic.slide(layout: "title", variant: "academic")
/// ```
///
/// This requires `layout: auto` or a layout name. With an explicit
/// `mosaic.layouts.*` value the constructor is already at hand, so pass the
/// fields to it instead.
///
/// -> content
#let slide(
  /// Which layout resolves this slide: `auto` for the configured content
  /// layout, one of the names `"content"`, `"title"`, `"section"`, or
  /// `"image"`, a `mosaic.layouts.*` value, or a raw `mosaic.grids.*` tree.
  /// Also accepted as the leading positional argument.
  /// -> auto | str | dictionary
  layout: auto,
  /// Whether the slide contributes to logical slide numbering. `auto` numbers
  /// content layouts and leaves title and section layouts unnumbered; an
  /// explicit boolean always wins.
  /// -> auto | bool
  numbered: auto,
  /// Whether to invert this slide's polarity: the slide ground takes the
  /// deck's text color, type is knocked out in the canvas color, and the
  /// muted and line colors are derived to match. Works with any layout, so an
  /// inverted title, section plate, or big-number slide are all one flag.
  /// Theme rules that pin an explicit fill other than the deck text color are
  /// not rewritten; override those on their own labels where needed.
  /// -> bool
  invert: false,
  /// Cell bodies keyed by cell id. Mutually exclusive with positional bodies.
  /// -> dictionary
  cells: (:),
  /// Full-slide layer drawn behind the grid. `auto` inherits the deck
  /// background from `setup`, `none` suppresses it.
  /// -> auto | content | none
  background: auto,
  /// Full-slide layer drawn over the grid. `auto` inherits the deck foreground
  /// from `setup`, `none` suppresses it.
  /// -> auto | content | none
  foreground: auto,
  /// Positional cell bodies in depth-first layout order, plus any named
  /// arguments forwarded as fields of the selected layout.
  /// -> arguments
  ..bodies
) = {
  let named = bodies.named()
  let bodies = bodies.pos()
  // A leading string or layout/grid dictionary is the positional layout
  // selection; cell bodies are always content, so the forms cannot collide.
  if bodies.len() > 0 and type(bodies.first()) in (str, dictionary) {
    if layout != auto {
      fail("slide layout given both positionally and as layout:")
    }
    layout = bodies.first()
    bodies = bodies.slice(1)
  }
  // The selection is validated first so an unknown layout name reports itself
  // rather than failing the field lookup that follows.
  let layout = validate-layout-selection(layout)
  let fields = validate-layout-fields(named, layout)
  if numbered != auto and type(numbered) != bool {
    fail("slide numbered must be auto or a boolean")
  }
  if type(invert) != bool {
    fail("slide invert must be a boolean")
  }
  if type(cells) != dictionary {
    fail("slide cells must be a dictionary")
  }
  // A plane is not a cell, so it is never a key here. Naming the parameter is
  // more useful than the "unknown cell id" the router would otherwise report.
  for name in plane-ids {
    if name in cells {
      fail("slide " + name + " is a plane, not a cell; pass it as " + name + ":")
    }
  }
  _ = validate-plane(background, "background")
  _ = validate-plane(foreground, "foreground")
  if bodies.len() > 0 and cells.len() > 0 {
    fail("slide cannot combine named and positional cell content")
  }
  metadata(slide-command(
    bodies,
    layout: layout,
    numbered: numbered,
    invert: invert,
    cells: cells,
    background: background,
    foreground: foreground,
    fields: fields,
  ))
}
