#let shrink_to_fit(content, max-width, base: 12pt, min-size: 8pt) = {
  let natural = measure(text(size: base, content)).width
  layout(size => {
    let limit = if type(max-width) == length { max-width } else { size.width }
    let scale = if natural > 0pt { calc.min(1.0, limit / natural) } else { 1.0 }

    let new-size = calc.max(min-size, base * scale)

    text(size: new-size, weight: "regular")[#content]
  })
}

#let running-header() = context {
  import "@preview/hydra:0.6.2": hydra

  let headings = query(selector(heading).after(here()))
  if headings.len() > 0 {
    if headings.first().level >= 2 or headings.first().location().page() != here().page() {
      grid(
        columns: (auto, 1fr),
        gutter: 1em,
        context (align(left, [#hydra(1) ])), context (align(right, shrink_to_fit(hydra(2), 1fr))),
      )
      line(length: 100%)
    }
  }
}
