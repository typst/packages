#let typearea(div: 9, bcor: 0mm, two-sided: true, ..rest, body) = {
  let width = 100% - bcor
  let height = 100%

  set page(
    ..rest,
    margin: if two-sided {
      (
        "top": height / div,
        "bottom": height / div * 2,
        "inside": width / div + bcor,
        "outside": width / div * 2,
      )
    // Auto currently defaults to left, as there is no way to check the text language
    } else if rest.named().at("binding", default: auto) != right {
      (
        "top": height / div,
        "bottom": height / div * 2,
        "left": width / div * 1.5 + bcor,
        "right": width / div * 1.5,
      )
    } else {
      (
        "top": height / div,
        "bottom": height / div * 2,
        "left": width / div * 1.5,
        "right": width / div * 1.5 + bcor,
      )
      
    }
  )

  body
}
