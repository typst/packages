// Presentation-oriented image convenience built on native Typst images.
#import "../shared.typ": validate-scrim

#let _native-image = image

/// Creates a slide-sized native Typst image with an optional scrim.
///
/// This is Typst's own `image` with presentation defaults: it fills its
/// container instead of hugging its natural size, and it can carry a scrim.
/// Everything else is forwarded unchanged, so `alt`, `format`, `page`, and
/// `scaling` all work as usual.
///
/// ```typ
/// #mosaic.slide(content: (
///   background: mosaic.components.image(path("cover.webp")),
///   body: [Text over the photograph],
/// ))
/// ```
///
/// When Mosaic is imported as a package, wrap an asset of the calling project
/// in a native `path` value, as above. A bare string would resolve relative to
/// the package instead.
///
/// *Scrims*
///
/// A `scrim` paints a layer over the picture and under whatever text is
/// composed on top of it, which is how a photograph is quieted enough to read
/// against. It takes an ordinary Typst paint, so it accepts exactly what a
/// `fill` accepts.
///
/// ```typ
/// // Darken the whole picture evenly.
/// #mosaic.components.image(
///   path("cover.webp"),
///   scrim: black.transparentize(55%),
/// )
///
/// // Darken only the band the text occupies.
/// #mosaic.components.image(
///   path("cover.webp"),
///   scrim: gradient.linear(
///     black.transparentize(20%), black.transparentize(100%),
///     angle: 90deg,
///   ),
/// )
/// ```
///
/// Without a scrim this returns the native image element directly, unwrapped.
///
/// -> content
#let image(
  /// Native image source. Use `path(...)` for an asset in the calling project.
  /// -> str | path | bytes
  source,
  /// Width of the image area. Defaults to filling the container.
  /// -> auto | length | relative
  width: 100%,
  /// Height of the image area. Defaults to filling the container.
  /// -> auto | length | relative | fraction
  height: 100%,
  /// Native Typst fitting mode: `"cover"` fills and crops, `"contain"` fits
  /// the whole picture inside.
  /// -> str
  fit: "cover",
  /// Paint layered over the picture and under any text composed on top of it.
  /// Accepts whatever a native `fill` accepts.
  /// -> none | color | gradient | tiling
  scrim: none,
  /// Further arguments forwarded unchanged to native Typst `image`, such as
  /// `alt`, `format`, `page`, and `scaling`.
  /// -> arguments
  ..native,
) = {
  let scrim = validate-scrim(scrim, "image")

  if scrim == none {
    return _native-image(
      source,
      width: width,
      height: height,
      fit: fit,
      ..native,
    )
  }

  block(
    width: width,
    height: height,
    breakable: false,
    clip: true,
  )[
    #_native-image(
      source,
      width: if width == auto { auto } else { 100% },
      height: if height == auto { auto } else { 100% },
      fit: fit,
      ..native,
    )
    #place(
      top + left,
      rect(
        width: 100%,
        height: 100%,
        fill: scrim,
        stroke: none,
      ),
    )
  ]
}
