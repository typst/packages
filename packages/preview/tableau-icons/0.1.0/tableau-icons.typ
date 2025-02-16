#import "./_tableau-icons-ref.typ": *

/// Renders a tabular icon
///
/// - body (str): icon name
/// - fill (color): color of the icon
/// - width (length): width of the icon (icon is contained)
/// - height (length): height of the icon (icon is contained)
/// -> the desired icon with the parameters applied
///

///
///
/// - body (str): icon name
/// - fill (color): width of the icon (icon is contained)
/// - height (length): height of the icon (icon is contained)
/// - width ():
/// - args ():
/// ->
#let draw-icon(body, fill: rgb("#000000"), height: 1em, width: auto, ..args) = {
  if (type(body) != str) {
    panic("icon name not set")
  }

  if width == auto {
    width = height
  }


  box(
    height: height,
    width: width,
    align(
      center + horizon,
      if body in _tabler-icons-unicode {
        text(
          bottom-edge: "descender",
          font: "tabler-icons",
          fill: fill,
          size: calc.min(height, width),
          _tabler-icons-unicode.at(body),
        )
      } else {
        text(
          fill: red,
          weight: "bold",
          size: height,
          [X],
        )
      },
    ),
    ..args,
  )
}
