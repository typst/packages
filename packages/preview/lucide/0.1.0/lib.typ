//! typst-lucide
//!
//! https://github.com/Lieunoir/typst-lucide

#import "lib-map.typ": *

/// Render a lucide icon as svg image
///
/// Parameters:
/// - `name`: Name of the icon
/// - `stroke`: How to stroke the icon
/// - `size`: Size og the svg
/// - `fill`: Fill color, none by default. Officially not supported (see https://lucide.dev/guide/advanced/filled-icons)
///
/// Returns: lucide icon as svg
#let lucide(name, stroke: stroke(paint: black, thickness: 2pt, cap: "round", join: "round"), size: 24pt, fill: none) = {
  let fill = if type(fill) == color {
    fill.to-hex()
  } else {
    "none"
  }

  let cap = if stroke.cap != "butt" and stroke.cap != "round" and stroke.cap != "square" {
    "round"
  } else {
    stroke.cap
  }
  let join = if stroke.join != "miter" and stroke.join != "round" and stroke.join != "bevel" {
    "round"
  } else {
    stroke.join
  }

  let prefix = "<svg
    xmlns=\"http://www.w3.org/2000/svg\"
    width=\"SIZE\"
    height=\"SIZE\"
    viewBox=\"0 0 24 24\"
    fill=\"FILL_COLOR\"
    stroke=\"STROKE_COLOR\"
    stroke-width=\"STROKE_WIDTH\"
    stroke-linecap=\"CAP\"
    stroke-linejoin=\"JOIN\"
  >".replace(
    "STROKE_WIDTH", str(stroke.thickness.pt())
  ).replace(
    "SIZE", str(size.pt())
  ).replace(
    "STROKE_COLOR", stroke.paint.to-hex()
  ).replace(
    "FILL_COLOR", fill
  ).replace(
    "CAP", cap
  ).replace(
    "JOIN", join
  )

  let suffix = "</svg>"
  let icon_content = lucide-icon-map.at(name)
  let icon_raw = (prefix, icon_content, suffix).join()
  image(bytes(icon_raw), alt: "icon: " + name)
}

/// Render an inline (boxed) lucide icon, with size and stroke color inferred from context by default
///
/// Parameters:
/// - `name`: Name of the icon
/// - `stroke`: Uses text color by default
/// - `size`: Can be absolute or relative
/// - `fill`: Fill color, none by default. Officially not supported (see https://lucide.dev/guide/advanced/filled-icons)
/// - `..args`: Additional arguments to pass to the `box` function
///
/// Returns: lucide icon as boxed svg
#let lucide-inline(name, stroke: stroke(thickness: 2pt, cap: "round", join: "round"), size: auto, fill: none, ..args) = context {
  let paint = if stroke.paint == auto or stroke.paint == none {
    // Could be gradient or tiling
    if type(text.fill) == color {
      text.fill
    } else {
      black
    }
  } else { stroke.paint }
  let stroke = std.stroke(thickness: stroke.thickness, paint: paint, cap: stroke.cap, join: stroke.join)

  let size = if type(size) == length {
    size
  } else if type(size) == ratio {
    size * text.size
  } else if type(size) == relative {
    size.ratio * text.size + size.length
  } else {
    text.size
  }

  box(lucide(name, stroke: stroke, fill: fill, size: size), ..args)
}
