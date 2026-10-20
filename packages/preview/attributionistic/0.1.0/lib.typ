#let afigure(
  body,
  attr: none,
  ..args,
) = [
  #figure(body, ..args)
  #box(
    hide(attr),
    width: 0pt,
    height: 0pt,
  ) <afig>
]

#let default-entry(index, figure, attribution) = {
  block(breakable: false, {
    figure.caption
    h(measure(figure.caption).width - measure(figure.caption.body).width)
    attribution
  })
}

#let figure-credits(kind: image, template: default-entry) = context {
  let figures = query(figure.where(kind: kind))
  let attributions = query(<afig>)
  let offset = 0

  for (idx, f) in figures.enumerate() {
    if idx >= attributions.len() {
      return
    }

    if attributions.at(idx).body.body == [] {
      offset += 1

      if idx + offset >= attributions.len() {
        return
      }

      if attributions.at(idx + offset).body.body == [] {
        continue
      }
    }

    template(idx + offset, f, attributions.at(idx + offset).body.body)
  }
}
