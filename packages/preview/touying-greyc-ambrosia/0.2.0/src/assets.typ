#import "core.typ" as core
#import core.assets: load-image
#let asset-paths = (
  credit-qr: "../assets/qr/repository.svg",
  lab-qr: "../assets/qr/qr-code-greyc-light.svg",
  theme-logo: "../assets/logos/touying-greyc-ambrosia.svg",
  theme-logo-dark: "../assets/logos/touying-greyc-ambrosia-dark.svg",
  logo-cnrs: "../assets/logos/institutions/logo-cnrs.svg",
  logo-ensicaen: "../assets/logos/institutions/logo-ensicaen.svg",
  logo-nu: "../assets/logos/institutions/logo-nu.svg",
  logo-unicaen: "../assets/logos/institutions/logo-unicaen.svg",
  logo-greyc: (
    en: "../assets/logos/greyc/logo-greyc-en.svg",
    fr: "../assets/logos/greyc/logo-greyc-fr.svg",
    small: "../assets/logos/greyc/logo-greyc-small.svg",
    traits: "../assets/logos/greyc/logo-greyc-traits.svg",
  ),
  logo-teams: (
    amacc: (full: "../assets/logos/greyc/logo-AMACC.svg", small: "../assets/logos/greyc/logo-AMACC-small.svg"),
    codag: (full: "../assets/logos/greyc/logo-CODAG.svg", small: "../assets/logos/greyc/logo-CODAG-small.svg"),
    diamant: (full: "../assets/logos/greyc/logo-DIAMANT.svg", small: "../assets/logos/greyc/logo-DIAMANT-small.svg"),
    electronique: (full: "../assets/logos/greyc/logo-ELECTRONIQUE.svg", small: "../assets/logos/greyc/logo-ELECTRONIQUE-small.svg"),
    image: (full: "../assets/logos/greyc/logo-IMAGE.svg", small: "../assets/logos/greyc/logo-IMAGE-small.svg"),
    mad: (full: "../assets/logos/greyc/logo-MAD.svg", small: "../assets/logos/greyc/logo-MAD-small.svg"),
    safe: (full: "../assets/logos/greyc/logo-SAFE.svg", small: "../assets/logos/greyc/logo-SAFE-small.svg"),
  ),
  cover-image: "../assets/greyc-cover.webp",
  cover-traits: "../assets/traits.svg",
)

/// Load a packaged asset relative to this module, independent of the caller's directory.
#let read-asset(path) = read(path, encoding: none)

// Resolve lab paths in this package before calling general SVG transformations.
#let _svg-data(data) = if type(data) == bytes or (type(data) == str and data.trim().starts-with("<")) { data } else { read-asset(data) }
#let colorize-svg(data, source: none, target: none) = core.assets.colorize-svg(_svg-data(data), source: source, target: target)
#let transparentize-svg(data, opacity: 1) = core.assets.transparentize-svg(_svg-data(data), opacity: opacity)


/// Helper function to convert any length to absolute value.
#let _resolve-length(val, axis-size) = {
  let t = type(val)
  if t == length { val } else if t == ratio { val * axis-size } else if t == relative {
    val.length + (val.ratio * axis-size)
  } else if t == fraction {
    // Treat 1fr as 100% of the container in this context
    (val / 1fr) * axis-size
  } else { val }
}


#let logo-greyc-with-traits(
  transform: data => data,
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
  let main-logo = image(transform(read-asset(logo-path)), ..named)
  let dimensions = measure(main-logo)
  let container = box(width: auto, height: dimensions.height * y-scale, clip: true)[
    #align(bottom)[
      #main-logo
    ]
    #place(top + right, dx: -8.5%, dy: -5%)[
      #image(transform(read-asset(asset-paths.logo-greyc.traits)), height: 50% * dimensions.height)
    ]
  ]

  container
})
