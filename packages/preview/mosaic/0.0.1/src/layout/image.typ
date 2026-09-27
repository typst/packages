// Construction, validation, and resolution of the image layout.
//
// This is the image-first counterpart to the content layout: the picture is the
// argument, and the text regions arrange around it. Content slides stay free of
// image plumbing, and the directional geometry is the same private machinery
// title and section layouts already use.
#import "../shared.typ": fail
#import "../caption-fit.typ": captioned-image
#import "../grid/constructors.typ": styled-cell, rows, track
#import "core.typ": image-fit-modes, make-layout, validate-image, validate-variant
#import "support.typ": image-content, edge-inset, inset-cell
#import "image-support.typ": (
  directional-image-layout,
  image-background-cell,
  image-cell,
  validate-directional-tracks,
)

#let directional-variants = ("left", "right", "top", "bottom")
#let variants = ("figure", "full") + directional-variants

#let validate-fields(fields) = {
  let variant = validate-variant(fields.variant, variants, "layout \"image\"")
  if fields.image == none {
    fail("layout \"image\" requires an image")
  }
  _ = validate-image(
    fields.image,
    "layout \"image\" image",
    allow-size: false,
  )
  if fields.fit != auto and (
    type(fields.fit) != str or fields.fit not in image-fit-modes
  ) {
    fail("layout \"image\" fit must be auto, \"cover\", or \"contain\"")
  }
  if fields.caption != none and variant != "figure" {
    fail("layout \"image\" caption applies only to the \"figure\" variant")
  }
  if variant in directional-variants {
    _ = validate-directional-tracks(fields.tracks, "layout \"image\" tracks")
  } else if fields.tracks != auto {
    fail("layout \"image\" tracks apply only to directional variants")
  }
  fields
}

/// Creates an image-first grid recipe.
///
/// This is the image-first counterpart to `layouts.content`: the picture is the
/// argument rather than slide content, and the text regions arrange around it.
/// The surrounding `mosaic.slide` fills only the text cells.
///
/// ```typ
/// #mosaic.slide(
///   layout: mosaic.layouts.image(
///     path("chart.webp"),
///     caption: [Revenue by quarter],
///   ),
///   [== Results],
/// )
/// ```
///
/// *Variants*
///
/// - `figure`: a contained picture centered under a `header` cell, with an
///   optional `caption` below it. The conventional academic figure slide, and
///   the default.
/// - `left`, `right`, `top`, `bottom`: a full-bleed picture paired with a text
///   region of `header` and `body` cells, sized by `tracks`.
/// - `full`: the picture behind a single `body` cell, so text reads over the
///   photograph. Put a heading inside the body to title it, or pass an empty
///   block for a bare full-bleed slide.
///
/// *Captions*
///
/// A `caption` composes a native Typst `figure` around the picture, so it takes
/// the deck's own `show figure.caption` styling and figure numbering. Switch the
/// numbering off with an ordinary `set figure(numbering: none)`. Captions are
/// accepted by the `figure` variant only.
///
/// *Labels*
///
/// Every resolved cell carries a label, so appearance comes from native Typst
/// rules:
///
/// - `mosaic-cell-header`: the header, in the `figure` and directional
///   variants.
/// - `mosaic-cell-body`: the text region, in the directional and `full`
///   variants.
/// - `mosaic-cell-image`: the picture, in the `figure` and directional
///   variants. The `full` variant paints the picture as the body cell's
///   background instead, so it has no image cell of its own.
///
/// *Styling*
///
/// The layout is purely structural, so its looks come from rules on those
/// labels. The `full` variant inherits the
/// surrounding native text color, so quiet the photograph with the image dictionary's
/// `scrim` key and override the cell's text fill.
///
/// ```typ
/// #show label("mosaic-cell-body"): set text(fill: white)
/// #mosaic.slide(
///   layout: mosaic.layouts.image(
///     (path: "photo.webp", scrim: black.transparentize(55%)),
///     variant: "full",
///   ),
///   [== Full bleed],
/// )
/// ```
///
/// -> dictionary
#let image(
  /// The picture the slide is built around, as the sole positional argument.
  /// Give a path, ready-made content, or a dictionary whose `scrim` key
  /// paints a layer over the picture and under any text composed on top of it.
  /// -> content | str | path | dictionary
  image,
  /// Structural arrangement of picture and text: `figure`, `full`, `left`,
  /// `right`, `top`, or `bottom`.
  /// -> str
  variant: "figure",
  /// Caption composed below a `figure` picture. Rejected by the other variants.
  /// -> content | none
  caption: none,
  /// How the picture fills its region.
  ///
  /// - `"contain"`: fit the whole picture inside the region. The `figure`
  ///   default, since a chart must never be cropped.
  /// - `"cover"`: fill the region, cropping the overhang. The default for every
  ///   other variant.
  ///
  /// `auto` picks the per-variant default above.
  /// -> auto | str
  fit: auto,
  /// Sizes the split of a directional variant, and is rejected by `figure` and
  /// `full`. One native Typst track size answers "how much room does the picture
  /// get" and is side-independent, so `left` and `right` stay mirror images
  /// without reordering anything; the text region takes the remaining `1fr`. An
  /// array of two is in visual order instead, and must be mirrored by hand when
  /// the variant flips.
  /// -> auto | length | ratio | relative | fraction | array
  tracks: auto,
) = {
  let fields = validate-fields((
    caption: caption,
    fit: fit,
    image: image,
    tracks: tracks,
    variant: variant,
  ))
  make-layout("image", fields)
}

// Header above, body filling the rest: the arrangement that sits beside a
// directional image and over a full-bleed one. The header is one line tall,
// so it takes the shallower edge padding; the body keeps the deck inset on
// all four sides.
#let text-column(settings) = rows(
  track(auto, inset-cell(
    "header",
    settings,
    content-sized: true,
    inset: edge-inset(settings),
  )),
  track(1fr, inset-cell("body", settings)),
)

#let resolve-image-layout(command, settings) = {
  let fields = validate-fields(command.fields)
  let default-fit = if fields.variant == "figure" { "contain" } else { "cover" }
  let fitting = if fields.fit == auto { default-fit } else { fields.fit }
  // Rebuilds the picture at a given size. A picture supplied as ready-made
  // content cannot be rebuilt, so it is boxed at that size instead.
  let resize(height, width) = if type(fields.image) == content {
    block(width: width, height: height, fields.image)
  } else {
    image-content(
      fields.image,
      "layout \"image\" image",
      width: width,
      height: height,
      fit: fitting,
      allow-size: false,
    )
  }
  let picture = resize(100%, 100%)

  if fields.variant == "figure" {
    // Picture and caption are one figure, not two stacked regions: the caption
    // is measured, the picture takes what is left, and the picture's box hugs
    // its natural height so the caption sits directly beneath the image rather
    // than being pinned to the bottom edge of the slide.
    let content = if fields.caption == none {
      picture
    } else {
      captioned-image(resize, fields.caption)
    }
    rows(
      track(auto, inset-cell(
        "header",
        settings,
        content-sized: true,
        inset: edge-inset(settings),
      )),
      // The picture owns a fixed cell, so the slide supplies no block for it.
      track(1fr, styled-cell(
        id: "image",
        content: content,
        style: (content-sized: false, inset: settings.spacing.inset),
      )),
    )
  } else if fields.variant == "full" {
    // A background is a cell style, not a split style, so the full-bleed
    // variant composes into a single cell exactly as image-background title
    // and section layouts do. Put a heading inside the body to title it.
    image-background-cell(
      inset-cell("body", settings),
      picture,
    )
  } else {
    // No gutter: a full-bleed picture is its own edge, and the text region
    // already keeps the deck inset on all four sides, so a gap here would be
    // padding on top of padding. It also lets a recolored header band reach
    // the picture instead of stopping short of it across a stripe of canvas.
    directional-image-layout(
      fields.variant,
      image-cell(picture),
      text-column(settings),
      tracks: fields.tracks,
    )
  }
}
