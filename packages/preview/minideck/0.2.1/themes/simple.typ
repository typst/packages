// Theme variants
#let variants = (
  light: (
    bg: white,
    fg: rgb("#3c3c3c"),
  ),
  dark: (
    bg: rgb("#3c3c3c"),
    fg: rgb("#eff1f3"),
  ),
)

// The paper and variant parameters must be set by the caller
#let template(page-size: none, variant: none, it) = {
  show heading: set block(below: 1em)
  let margin = calc.min(..page-size.values()) * 2.5 / 21 // same as typst default
  set page(
    width: page-size.width,
    height: page-size.height,
    margin: margin,
    header-ascent: 0pt,
    footer-descent: 0pt,
    footer: context {
      set text(0.8em)
      set align(bottom+right)
      pad(x: -margin+1cm, y: 1cm, counter(page).display())
    },
    fill: variants.at(variant).bg,
  )
  set text(
    24pt,
    fill: variants.at(variant).fg,
    font: "Libertinus Sans",
  )
  it
}

// Layout for title slide: no page numbers, centered content
#let title-slide(slide, it) = {
  set page(footer: none)
  set align(horizon+center)
  slide(it)
}

// Theme function. Called by minideck with page-size set.
#let simple(slide, page-size: none, variant: "light") = {
  (
    slide: slide,
    title-slide: title-slide.with(slide),
    template: template.with(page-size: page-size, variant: variant)
  )
}
