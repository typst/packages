#let asset-paths = (
  credit-qr: "../assets/qr/repository.svg",
  code-theme-dark: "../assets/highlighting/ambrosia-dark.tmTheme",
  citation-style: "../assets/citations/compact-author-year.csl",
  showcase: (
    touying-ambrosia: (light: "../assets/logos/touying-ambrosia.svg", dark: "../assets/logos/touying-ambrosia-dark.svg"),
  ),
)

/// Load a packaged asset relative to this module, independent of the caller's directory.
#let read-asset(path) = read(path, encoding: none)


/// Call a `self => {..}` function and return the result, or just return the image.
///
/// -> image
#let load-image(self: none, it) = {
  while type(it) == function {
    it = it(self)
  }
  if it == none or type(it) == content { return it }
  image(if _is-xml(it) { bytes(it) } else { it })
}


/// Check if data is svg
#let _is-xml(data) = {
  type(data) == str and data.trim().starts-with("<")
}

#let _svg-text(data) = {
  if type(data) == bytes { str(data) }
  else if _is-xml(data) { data }
  else { read(data) }
}

/// Replace one complete hexadecimal color, preserving all other SVG data.
#let colorize-svg(data, source: none, target: none) = {
  let data = _svg-text(data)
  if source == none or target == none { return data }
  let source = if type(source) == color { source.rgb().to-hex() } else { source }
  let target = if type(target) == color { target.rgb().to-hex() } else { target }
  data.replace(regex("(?i)" + source + "\\b"), _ => target)
}


/// Apply a percentage opacity, such as 60%, to every fill and stroke.
#let transparentize-svg(data, opacity: 100%) = {
  assert(type(opacity) == ratio and 0% <= opacity and opacity <= 100%,
    message: "SVG opacity must be a percentage between 0% and 100%, such as 60%.")
  data = _svg-text(data)
  let op-str = str(opacity / 100%)
  data = data.replace(
    regex("fill-opacity=\"[^\"]*\""),
    "fill-opacity=\"" + op-str + "\"",
  )
  data = data.replace(
    regex("stroke-opacity=\"[^\"]*\""),
    "stroke-opacity=\"" + op-str + "\"",
  )
  let style-override = (
    "<style> * { fill-opacity: " + op-str + " !important; stroke-opacity: " + op-str + " !important; } </style>"
  )
  data = data.replace("</svg>", style-override + "</svg>")
  return data
}
