#let typearea(
  div: 9,
  binding-correction: 0mm,
  two-sided: true,
  font-size: 11pt,
  header-include: false,
  footer-include: false,
  header-height: 1.25em,
  header-sep: 1.5em,
  footer-height: 1.25em,
  footer-sep: 3.5em,
  ..rest,
  body
) = {
  if div < 4 {
    panic("div must be at least 4. Was " + div)
  }
  let width = 100% - binding-correction
  let height = 100%
  let content-height = height / div * (div - 3)
  let header-space = header-height + header-sep
  let footer-space = footer-height + footer-sep

  let overwrite = (:)
  if "header" in rest.named() {
    overwrite.insert(
      "header",
      block(
        above: 0pt,
        below: 0pt,
        breakable: false,
        height: header-height,
        rest.named().at("header"),
      )
    )
  }
  if "footer" in rest.named() {
    overwrite.insert(
      "footer",
      block(
        above: 0pt,
        below: 0pt,
        breakable: false,
        height: footer-height,
        rest.named().at("footer"),
      )
    )
  }
  let h-div = height / div
  let w-div = width / div

  let top-margin = h-div + if header-include { header-space } else { 0pt }
  let bottom-margin = h-div * 2 + if footer-include { footer-space } else { 0pt }

  set page(
    ..rest,
    ..overwrite,
    header-ascent: header-sep,
    footer-descent: footer-sep,
    margin: if two-sided {
      (
        "top": top-margin,
        "bottom": bottom-margin,
        "inside": w-div + binding-correction,
        "outside": w-div * 2,
      )
    // Auto currently defaults to left, as there is no way to check the text language
    } else if rest.named().at("binding", default: auto) != right {
      (
        "top": top-margin,
        "bottom": bottom-margin,
        "left": w-div * 1.5 + binding-correction,
        "right": w-div * 1.5,
      )
    } else {
      (
        "top": top-margin,
        "bottom": bottom-margin,
        "left": w-div * 1.5,
        "right": w-div * 1.5 + binding-correction,
      )

    }
  )

  body
}