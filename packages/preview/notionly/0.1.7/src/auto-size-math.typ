#let auto-size-math(
  doc,
  scale-equations: true,
) = {
  let auto-math(body) = layout(size => {
    let eq-width = measure(width: auto, $body$).width
    let factor = calc.min(1, size.width / eq-width)
    set text(size: 1em * factor)
    $body$
  })

  show math.equation: it => {
    if it.block and scale-equations {
      auto-math(it.body)
    } else {
      it
    }
  }

  doc
}