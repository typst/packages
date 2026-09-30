#import "../theme/resolver.typ": resolve-token

#let folio-state = state("folio-state", (
  data: (:),
  config: (:),
  brand: (:),
  preset-tokens: (:),
))

#let folio-init(data: (:), config: (:), brand: (:), body) = {
  let brand-preset = brand.at("preset", default: none)
  let user-brand = brand
  if brand-preset != none {
    let _ = user-brand.remove("preset")
  }

  let preset-tokens = if brand-preset == none {
    (:) // no preset: falls back to default-tokens (corporate) in resolver
  } else if brand-preset == "academic" {
    import "../theme/brand-packs/academic.typ": brand
    brand
  } else if brand-preset == "corporate" {
    import "../theme/brand-packs/corporate.typ": brand
    brand
  } else if brand-preset == "minimal" {
    import "../theme/brand-packs/minimal.typ": brand
    brand
  } else {
    panic(
      "Unknown brand preset: '"
        + brand-preset
        + "'. Valid values: academic, corporate, minimal.",
    )
  }

  folio-state.update(old => {
    (
      data: data,
      config: config,
      brand: user-brand,
      preset-tokens: preset-tokens,
    )
  })

  context {
    let st = folio-state.get()
    let font = resolve-token(st, "typography.font.body")
    let size = resolve-token(st, "typography.size.body")
    let margin = resolve-token(st, "geometry.page-margin")
    let paper = resolve-token(st, "geometry.paper")

    set text(font: font, size: size)
    set page(margin: margin, paper: paper, numbering: "1")
    body
  }
}
