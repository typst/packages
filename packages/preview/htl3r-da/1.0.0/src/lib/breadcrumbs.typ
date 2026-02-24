#import "util.typ": to-string
#import "settings.typ": BREADCRUMBS_COLOR, FONT_SIZE

#let breadcrumb_shape(value, first: false, last: false) = {
  let outset = 2pt
  let skew = 5pt
  let text_dimensions = measure(box(text(size: FONT_SIZE - 2pt, value)))
  let height = text_dimensions.height + outset * 2
  let width = (
    text_dimensions.width
      + outset * if not first { 3 } else { 1 }
      + if not (last or first) { 0pt } else { outset }
  )
  box(
    width: width,
    height: text_dimensions.height,
    {
      place(
        dy: -outset,
        polygon(
          fill: BREADCRUMBS_COLOR.fill,
          stroke: BREADCRUMBS_COLOR.stroke,
          (0pt, height),
          (if not first { skew } else { 0pt }, 0pt),
          (width + if not last { skew } else { 0pt }, 0pt),
          (width, height),
        ),
      )
      place(
        dy: 0pt,
        dx: if not first { skew } else { outset },
        box(text(size: FONT_SIZE - 2pt, value)),
      )
    },
  )
}

#let breadcrumbs(layers) = context {
  if layers.len() < 2 {
    panic("Es sollten mindestens 2 Elemente angegeben werden!")
  }
  let offset = 4pt
  breadcrumb_shape(layers.first(), first: true)
  h(offset)
  for layer in layers.slice(1, layers.len() - 1) {
    breadcrumb_shape(layer)
    h(offset)
  }
  breadcrumb_shape(layers.last(), last: true)
}
