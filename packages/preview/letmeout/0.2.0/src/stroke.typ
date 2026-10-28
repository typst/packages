// SVG masks retain dash phase, arbitrary patterns, caps, and joins while CSS
// supplies the paint. Gradients remain native CSS, including conic gradients.
#import "css.typ": size, paint

#let url-encode(source) = {
  for (before, after) in (("%", "%25"), ("#", "%23"), ("<", "%3C"), (">", "%3E"),
    ("\"", "%22"), ("'", "%27"), (" ", "%20"), ("\n", "%0A")) {
    source = source.replace(before, after)
  }
  source
}

// SVG presentation attributes for a resolved stroke, painted white for a mask.
#let svg-stroke-attrs(value) = {
  let thickness = value.thickness.to-absolute()
  let attrs = (
    "stroke='white'", "fill='none'", "stroke-width='" + size(thickness) + "'",
    "stroke-linecap='" + value.cap + "'", "stroke-linejoin='" + value.join + "'",
    "stroke-miterlimit='" + str(value.miter-limit) + "'",
  )
  if value.dash != auto and value.dash != none {
    let pattern = value.dash.array.map(v => size(if v == "dot" { thickness } else { v.to-absolute() }))
    attrs.push("stroke-dasharray='" + pattern.join(" ") + "'")
    attrs.push("stroke-dashoffset='" + size(value.dash.phase.to-absolute()) + "'")
  }
  attrs.join(" ")
}

#let mask-url(source) = "url(\"data:image/svg+xml," + url-encode(source) + "\")"

#let stroke-html(value, vertical: false, extra: "") = {
  if value == none { return [] }
  let thickness = value.thickness.to-absolute()
  // Give caps a half-stroke of canvas outside each geometric endpoint.
  let cap = size(thickness / 2)
  let coord = if vertical { "y" } else { "x" }
  let dimension = if vertical { "height" } else { "width" }
  let coords = if vertical { "x1='50%' y1='0' x2='50%' y2='100%'" }
    else { "x1='0' y1='50%' x2='100%' y2='50%'" }
  let source = ("<svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%'><svg "
    + coord + "='" + cap + "' width='100%' height='100%' style='overflow:visible;" + dimension + ":calc(100% - " + size(thickness) + ")'>"
    + "<line " + coords + " " + svg-stroke-attrs(value) + "/></svg></svg>")
  let mask = mask-url(source)
  let offset = if vertical { "top" } else { "left" }
  let inner = html.elem("span", attrs: (
    class: "letmeout-stroke-paint", style:
      "position: absolute; display: block; pointer-events: none; width: 100%; height: 100%; "
      + offset + ": calc(-1 * " + cap + "); " + dimension + ": calc(100% + " + size(thickness) + "); "
      + "background: " + paint(value.paint, role: "ink") + "; mask-image: " + mask
      + "; mask-size: 100% 100%; mask-repeat: no-repeat",
  ))
  html.elem("span", attrs: (
    class: "letmeout-stroke", "aria-hidden": "true",
    style: "display: block; position: relative; pointer-events: none; " + extra,
  ), inner)
}
