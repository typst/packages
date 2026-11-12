// Captioned figure sized to its cell: a picture, or any finished block content.
#import "../shared.typ": fail
#import "../caption-fit.typ": captioned-image
#import "../fit.typ": fit as fit-block
#import "image.typ": image as picture

#let _native-figure = figure

/// Creates a centered, captioned figure sized to its cell.
///
/// This is the in-cell counterpart to the
/// #link("../slides/image.html")[image layout]. Use the layout when one
/// picture is the whole point of a slide; use this when a figure shares the
/// slide with other content, most often as one of two side by side.
///
/// ```typ
/// #mosaic.slide(layout: "content", columns: 2)[== Before and after][
///   #mosaic.components.figure(path("before.png"), caption: [Baseline])
/// ][
///   #mosaic.components.figure(path("after.png"), caption: [After the reform])
/// ]
/// ```
///
/// *Pictures*
///
/// Given an image source, this differs from `mosaic.components.image` in its
/// defaults, which are the ones a chart or a photograph in a cell wants rather
/// than the ones a full-bleed background wants: `fit` is `"contain"`, so the
/// picture is never cropped, and the result is centered in its cell.
///
/// The default `height: auto` gives the picture the cell's full height, less
/// whatever the caption and its gap consume. Nothing has to be measured by hand,
/// and adjacent cells agree: each picture is as large as its own aspect ratio
/// allows, and the captions share one baseline at the foot of the cells.
///
/// *Other content*
///
/// A table, a chart drawn in code, or a diagram is passed as content instead of
/// a source. Such a body cannot be re-fitted the way a picture can, so it is
/// laid out at the cell's width and then scaled as a whole if it is still too
/// tall, exactly as `mosaic.fit` does. Its own arrangement is preserved, the
/// caption keeps the size the deck gave it, and a body that already fits is left
/// alone. It is never magnified past its natural size.
///
/// ```typ
/// #mosaic.components.figure(
///   table(columns: 3, ..cells),
///   caption: [Estimates by specification],
///   kind: table,
/// )
/// ```
///
/// A content body that does not fill its cell sits at the top of it and is
/// captioned directly beneath itself, rather than stretching and captioning at
/// the foot of the cell as a picture does.
///
/// Scaling a table also costs it the automatic `kind` a native `figure` would
/// have detected, so state `kind: table` for the table numbering and the "Table"
/// supplement. Further arguments go to the native `figure` here, and to the
/// native `image` for a picture source.
///
/// *Height*
///
/// `auto` reads the size of the cell, not the space left over inside it, so a
/// figure that follows prose in the same cell needs an explicit height:
///
/// ```typ
/// #mosaic.slide(layout: "content", columns: 2)[== Two revenues][
///   - Payroll taxes carry the system
///   - Consumption taxes are regressive
///   #mosaic.components.figure(path("photo.jpg"), height: 50%)
/// ][
///   #mosaic.components.figure(path("chart.png"), caption: [Shares since 1980])
/// ]
/// ```
///
/// An explicit height sizes the picture area, and the caption follows directly
/// beneath it rather than sitting at the foot of the cell. Such a figure takes
/// only the height it was given, so it leaves whatever shares its cell where it
/// was.
///
/// *Captions*
///
/// A `caption` composes a native Typst `figure`, so it takes the deck's own
/// `show figure.caption` styling, figure numbering, and references. Switch the
/// numbering off with an ordinary `set figure(numbering: none)`. Without a
/// caption no `figure` is involved: the body is centered and sized, nothing more.
///
/// -> content
#let figure(
  /// The figure's body: an image source, or finished content such as a table or
  /// a diagram. Use `path(...)` for an image asset in the calling project.
  /// -> content | str | path | bytes
  body,
  /// Caption composed beneath the body.
  /// -> content | none
  caption: none,
  /// How a picture fills its area. `"contain"` fits the whole picture inside it,
  /// which is what a chart or a screenshot needs; `"cover"` fills the area and
  /// crops the overhang. Rejected for a content body, which is scaled rather
  /// than fitted.
  /// -> str
  fit: "contain",
  /// Width of the figure's body.
  /// -> auto | length | relative
  width: 100%,
  /// Height of the figure's body. `auto` takes the cell's height less the
  /// caption, which requires the figure to be the cell's own content.
  /// -> auto | length | relative | fraction
  height: auto,
  /// Paint layered over a picture. Accepts whatever a native `fill` accepts, and
  /// is rejected for a content body.
  /// -> none | color | gradient | tiling
  scrim: none,
  /// Further arguments forwarded unchanged to the native element this is built
  /// from: `image` for a picture source, taking `alt`, `format`, `page`, and
  /// `scaling`; `figure` for a content body, taking `kind`, `supplement`, and
  /// `numbering`.
  /// -> arguments
  ..native,
) = {
  // A source is something Mosaic can rebuild at any size. Finished content can
  // only be measured and scaled, which is a different fitting problem.
  let is-image = type(body) != content

  // Applies to both bodies: a stray positional forwarded to a picture source
  // would otherwise reach `image()` and fail with a raw arity error instead
  // of a `mosaic:` diagnostic.
  if native.pos().len() != 0 {
    fail("figure takes one body; further arguments must be named")
  }

  if not is-image {
    if fit != "contain" {
      fail("figure fit applies only to a picture source")
    }
    if scrim != none {
      fail("figure scrim applies only to a picture source")
    }
    if caption == none and native.named().len() != 0 {
      fail("figure arguments apply to the native figure, so they need a caption")
    }
  }

  let resize = if is-image {
    (height, width) => picture(
      body,
      width: width,
      height: height,
      fit: fit,
      scrim: scrim,
      ..native,
    )
  } else {
    (height, width) => if height == auto {
      // The body as it stands, which is what the caption's measurement is taken
      // out of.
      body
    } else {
      // Scaled as a whole rather than offered a narrower width: a table given
      // less room rearranges its columns, which changes the composition instead
      // of its size. `grow` stays off, since a table magnified past its natural
      // size is a worse table.
      fit-block(
        body,
        width: width,
        height: height,
        wrap: false,
        grow: false,
      )
    }
  }

  // A figure given the cell's height owns the cell, so it centers in it. One
  // given an explicit height is sharing the cell with something else, and a
  // vertical alignment there would claim room it was not given and push that
  // content around: it takes the height it asked for and no more.
  let place = align.with(if height == auto { center + horizon } else { center })

  if caption == none {
    return place(resize(if height == auto { 100% } else { height }, width))
  }

  let figure-args = if is-image { (:) } else { native.named() }
  if height == auto {
    // A picture stretches to the cell, so pinning its caption to the foot gives
    // two figures in adjacent cells one caption baseline however their aspect
    // ratios differ. Content keeps its own height, so its caption stays with it.
    return captioned-image(
      resize,
      caption,
      width: width,
      pin: is-image,
      figure-args: figure-args,
    )
  }
  place(_native-figure(resize(height, width), caption: caption, ..figure-args))
}
