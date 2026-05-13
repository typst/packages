#let asset-paths = (
  logo-cnrs: "../assets/logo-cnrs.svg",
  logo-ensicaen: "../assets/logo-ensicaen.svg",
  logo-nu: "../assets/logo-nu.svg",
  logo-unicaen: "../assets/logo-unicaen.svg",
  logo-greyc: (
    en: "../assets/logo-greyc-en.svg",
    fr: "../assets/logo-greyc-fr.svg",
    small: "../assets/logo-greyc-small.svg",
    traits: "../assets/logo-greyc-traits.svg",
  ),
  cover-image: "../assets/greyc-cover.webp",
  cover-traits: "../assets/traits.svg",
)


/// Helper function to convert any length to absolute value.
#let _resolve-length(val, axis-size) = {
  let t = type(val)
  if t == length { val } else if t == ratio { val * axis-size } else if t == rel {
    val.abs + (val.ratio * axis-size)
  } else if t == fraction {
    // Treat 1fr as 100% of the container in this context
    (val / 1fr) * axis-size
  } else { val }
}


#let logo-greyc-with-traits(
  ..args,
) = layout(size => context {
  let named = args.named()
  let y-scale = 1.3 // const

  named.width = if "width" in named { _resolve-length(named.width, size.width) } else { auto }
  named.height = if "height" in named { _resolve-length(named.height, size.height) } else { auto }
  if named.height != auto {
    named.height /= y-scale
  }

  let logo-path = if text.lang == "fr" { asset-paths.logo-greyc.fr } else { asset-paths.logo-greyc.en }
  let main-logo = image(logo-path, ..named)
  let dimensions = measure(main-logo)
  let container = box(width: auto, height: dimensions.height * y-scale, clip: true)[
    #align(bottom)[
      #main-logo
    ]
    #place(top + right, dx: -8.5%, dy: -5%)[
      #image(asset-paths.logo-greyc.traits, height: 50% * dimensions.height)
    ]
  ]

  container
})


/// Call a `self => {..}` function and return the result, or just return the image.
///
/// -> image
#let load-image(self: none, it) = {
  if type(it) == image {} else if type(it) == function {
    it = it(self)
  } else if type(it) == bytes {
    it = image(it)
  } else if type(it) == string {
    if _is-xml(it) {
      it = image(bytes(it))
    } else {
      it = image(it)
    }
  } else {
    it = image(it)
  }
  return it
}


/// Check if data is svg
#let _is-xml(data) = {
  data.trim().starts-with("<")
}

#let colorize-svg(data, source: none, target: none) = {
  if not _is-xml(data) {
    data = read(data)
  }
  if source == none or target == none {
    return data
  }
  if type(source) == color {
    source = source.rgb().to-hex()
  }
  if type(target) == color {
    target = target.rgb().to-hex()
  }
  data = data.replace(regex("#[A-Fa-f0-9]{3,6}"), it => lower(it.text))
  let data = data.replace(source, target)
  return data
}


#let transparentize-svg(data, opacity: 1) = {
  if not _is-xml(data) {
    data = read(data)
  }
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
  data = data.replace(regex("#[A-Fa-f0-9]{3,6}"), it => lower(it.text))
  data = data.replace("</svg>", style-override + "</svg>")
  return data
}
