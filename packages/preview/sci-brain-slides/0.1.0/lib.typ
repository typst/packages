// Public entrypoint. Touying remains responsible for slides and reveals.
#import "src/lib.typ": *
#import "src/scale.typ": type-scale
#import "src/palettes/brand.typ": build as brand-palette

// Bind the theme and its components together, including custom brand colors.
#let setup(theme: "academic", primary: none, text-size: 20pt, sizes: (:)) = {
  assert(theme in themes, message: "theme must be academic, dark, minimal, vibrant, or brand")
  assert(primary == none or theme == "brand", message: "primary requires theme: \"brand\"")
  let pal = if primary == none { palettes.at(theme) } else { brand-palette(primary) }
  let apply = if primary == none { themes.at(theme) } else { themes.brand.with(primary: primary) }
  let scale = type-scale(text-size: text-size, overrides: sizes)
  (theme: apply.with(sizes: scale), palette: pal, sizes: scale,
    gadgets: gadgets(pal, sizes: scale), layouts: layouts(pal, sizes: scale))
}

// Load drawing packages only when these helpers are called.
#let cetz-gadgets(pal) = {
  import "src/gadgets_cetz.typ": make
  make(pal)
}
#let pin-gadgets(pal, sizes: sizes) = {
  import "src/gadgets_pin.typ": make
  make(pal, sizes: sizes)
}
