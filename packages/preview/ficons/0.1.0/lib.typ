#import "feather-icons-data.typ" as data

/// Version of the icons (not the package)
/// -> str
#let icons-version = data.icons-version

/// URL of the feather icons repository where the SVG source code is contained
/// -> str
#let icons-repository = data.icons-repository

#let _variant(f) = {
  data.strokes
    .pairs()
    .map(it => {
        let (name, strokes) = it
        (name, f(data.header + strokes + data.footer))
    }).to-dict()
}

// Convert an icon set to an inline icon set
// -> dictionary[str, content]
#let inline(
  // Image icon set -> dictionary[str, image]
  icons,
  height: 1em,
  baseline: 0.2em,
) = {
  icons
    .pairs()
    .map(it => {
      let (name, image) = it
      (name, box(image, height: height, baseline: baseline))
    })
    .to-dict()
}

#let _set-svg-variable(s, ..opts) = {
  let match = s.match(regex("^<svg .+?>"))
  assert(match.start == 0)
  let svg-tag = match.text
  for (name, value) in opts.named() {
    if value == none { value = "none" }
    if type(value) == color { value = value.to-hex() }
    if type(value) != str { value = str(value) }
    svg-tag = svg-tag.replace(
      regex(name + "=\".+?\""),
      name + "=\"" + str(value) + "\"",
    )
  }
  svg-tag + s.slice(match.end)
}

/// Icon Images
///
/// ```example
/// #stack(dir: ltr, icons.package, icons.code, icons.coffee)
/// ```
///
///-> dictionary[str, image]
#let icons = _variant(it => image(bytes(it)))

/// Icons for use inside text
///
/// ```example
/// Inline icons can be placed #inline-icons.map-pin directly within text #inline-icons.edit-2.
/// ```
/// -> dictionary[str, content]
#let inline-icons = inline(icons)

/// SVG source for icons
///
/// ````example
/// #raw(svg-icons.clock, lang: "svg")
///
/// They can be turned into icons like this:
/// #image(bytes(svg-icons.clock))
/// ````
///
/// -> dictionary[str, str]
#let svg-icons = _variant(it => it)

/// Create an icon set with additional options
///
/// ```example
/// Using the `make-icons` function, we can create a custom icon set with additional tweaks.
///
/// #let tweaked-icons = make-icons(
///   // Specify new icon color
///   stroke: orange.darken(20%),
///   // Make the stroke thinner
///   stroke-width: 1,
/// )
/// 
/// #tweaked-icons.sun
/// #tweaked-icons.moon
///
/// ```
///
/// -> dictionary[str, image]
#let make-icons(
  /// The color of the icons. This corresponds to the `stroke` field within the SVG source code -> str | color
  stroke: "currentColor",
  /// The `stroke-width` field within the SVG source code -> str | int
  stroke-width: 2,
  /// The fill between strokes in the icon -> str | color | none
  fill: none,
) = {
  _variant(svg => {
    let svg = _set-svg-variable(
      svg,
      stroke: stroke,
      stroke-width: stroke-width,
      fill: fill,
    )
    image(bytes(svg))
  })
}

/// Create an _inline_ icon set with additional options
///
/// ```example
/// Using the `make-inline-icons` function, is the same as `make-icons`, but the resulting icons can be used inside text.
///
/// #let tweaked-icons = make-inline-icons(
///   stroke: blue.darken(20%), // Specify new icon color
///   stroke-width: 3,          // Make the stroke thicker!
/// )
/// 
/// Here we have the #tweaked-icons.sun (sun) and #tweaked-icons.moon (moon)!
/// ```
///
///-> dictionary[str, content]
#let make-inline-icons(
  /// The color of the icons. This corresponds to the `stroke` field within the SVG source code -> str | color
  stroke: "currentColor",
  /// The `stroke-width` field within the SVG source code -> str | int
  stroke-width: 2,
  /// The fill between strokes in the icon -> str | color | none
  fill: none,
  /// Height of the icon -> relative
  height: 1em,
  /// Baseline offset of the icon -> relative
  baseline: 0.2em,
) = {
  inline(
    make-icons(
      stroke: stroke,
      stroke-width: stroke-width,
      fill: fill,
    ),
    height: height,
    baseline: baseline,
  )
}
