#let asset-paths = (
  credit-qr: "../assets/qr/repository.svg",
  code-theme-dark: "../assets/highlighting/ambrosia-dark.tmTheme",
  citation-style: "../assets/citations/compact-author-year.csl",
  showcase: (
    touying-ambrosia: (light: "../assets/logos/touying-ambrosia.svg", dark: "../assets/logos/touying-ambrosia-dark.svg"),
    kyklo-logo: (light: "../assets/logos/kyklo-logo.svg", dark: "../assets/logos/kyklo-logo-dark.svg"),
    kyklo-mark: (light: "../assets/logos/kyklo-mark.svg", dark: "../assets/logos/kyklo-mark-dark.svg"),
    olympus-institute: (light: "../assets/logos/olympus-institute.svg", dark: "../assets/logos/olympus-institute-dark.svg"),
    helios-polytechnic: (light: "../assets/logos/helios-polytechnic.svg", dark: "../assets/logos/helios-polytechnic-dark.svg"),
    delphi-forum: (light: "../assets/logos/delphi-forum.svg", dark: "../assets/logos/delphi-forum-dark.svg"),
    nectarion-college: (light: "../assets/logos/nectarion-college.svg", dark: "../assets/logos/nectarion-college-dark.svg"),
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


#let transparentize-svg(data, opacity: 1) = {
  data = _svg-text(data)
  let op-str = str(opacity)
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
