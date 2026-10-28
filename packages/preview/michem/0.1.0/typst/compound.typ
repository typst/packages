// Shared natural-scale compound cards for route and gallery templates.
#import "mechanism.typ" as mechanism

/// A labeled molecular participant; coefficient is explicit and never inferred.
#let compound(value, name: none, coefficient: none, highlights: ()) = {
  assert(
    type(highlights) == array,
    message: "Compound highlights must be an array",
  )
  for region in highlights {
    assert(
      type(region) == dictionary,
      message: "A compound highlight must be a dictionary",
    )
    assert(
      region.keys().all(key => key in ("atoms", "bonds", "radius", "color")),
      message: "Compound highlights accept atoms, bonds, radius, and color",
    )
  }
  if coefficient != none and type(coefficient) in (int, float) {
    assert(coefficient > 0, message: "Compound coefficient must be positive")
  }
  (
    kind: "compound",
    value: value,
    name: name,
    coefficient: coefficient,
    highlights: highlights,
  )
}

#let content-value(value) = if type(value) in (int, float) { str(value) } else {
  value
}

#let label(value, font, size, width: auto) = {
  let body = text(
    font: font,
    size: size,
    top-edge: "bounds",
    bottom-edge: "bounds",
    content-value(value),
  )
  let natural = measure(body)
  if width != auto and natural.width > width {
    body = block(width: width, align(center, body))
  }
  (body: body, ..measure(body))
}

#let settings(
  font,
  atom-size,
  label-size,
  bond-length,
  molecular-style,
  molecular-layout,
) = {
  for (name, value) in (
    ("atom-size", atom-size),
    ("label-size", label-size),
    ("bond-length", bond-length),
  ) {
    assert(
      type(value) == length and value > 0pt,
      message: name + " must be a positive length",
    )
  }
  assert(
    type(font) == str and font != "",
    message: "Route font must be a font family name",
  )
  (
    font: font,
    atom-size: atom-size,
    label-size: label-size,
    style: molecular-style
      + (
        font: font,
        "font-size": atom-size / 0.75pt,
        "bond-length": bond-length / 0.75pt,
      ),
    layout: molecular-layout,
    label-width: 5 * bond-length,
  )
}

#let measure-compound(input, options) = {
  let input = if type(input) == str { compound(input) } else { input }
  assert(
    type(input) == dictionary and input.at("kind", default: none) == "compound",
    message: "Expected compound(...) or a SMILES string",
  )
  let annotations = input
    .at("highlights", default: ())
    .map(region => mechanism.highlight("compound", ..region))
  let data = mechanism.mechanism-data(
    mechanism.mol(
      "compound",
      input.value,
      style: options.style,
      layout: options.layout,
    ),
    ..annotations,
  )
  let image = mechanism.paint-mechanism(data, padding: 0pt)
  let dimensions = measure(image)
  let name = if input.name == none { none } else {
    label(input.name, options.font, options.label-size, width: calc.max(
      dimensions.width,
      options.label-width,
    ))
  }
  let coefficient = if input.coefficient == none { none } else {
    label(input.coefficient, options.font, options.label-size)
  }
  let coefficient-space = if coefficient == none { 0pt } else {
    coefficient.width + 4pt
  }
  (
    input: input,
    image: image,
    scene: data.scene,
    image-width: dimensions.width,
    image-height: dimensions.height,
    coefficient: coefficient,
    coefficient-space: coefficient-space,
    name: name,
    width: calc.max(dimensions.width + coefficient-space, if name == none {
      0pt
    } else { name.width }),
  )
}

#let paint-compound(card, image-height, name-height, name-gap) = {
  let group-width = card.image-width + card.coefficient-space
  let image-left = (card.width - group-width) / 2
  box(
    width: card.width,
    height: image-height
      + name-height
      + if name-height > 0pt { name-gap } else { 0pt },
    {
      if card.coefficient != none {
        place(
          top + left,
          dx: image-left,
          dy: (image-height - card.coefficient.height) / 2,
          card.coefficient.body,
        )
      }
      place(
        top + left,
        dx: image-left + card.coefficient-space,
        dy: (image-height - card.image-height) / 2,
        card.image,
      )
      if card.name != none {
        place(
          top + left,
          dx: (card.width - card.name.width) / 2,
          dy: image-height + name-gap,
          card.name.body,
        )
      }
    },
  )
}

/// A named-molecule gallery with shared physical label size and bond length.
/// Natural molecular drawings are never resized to fit individual cells.
#let compound-grid(
  ..compounds,
  columns: 3,
  font: "Libertinus Serif",
  atom-size: 9pt,
  label-size: 10pt,
  bond-length: 18pt,
  gutter: 18pt,
  row-gap: 18pt,
  name-gap: 5pt,
  molecular-style: (:),
  molecular-layout: (:),
) = context {
  assert(compounds.named().len() == 0, message: "Unknown compound-grid option")
  assert(
    type(columns) == int and columns > 0 and columns <= 128,
    message: "Gallery columns must be in 1..128",
  )
  assert(
    compounds.pos().len() > 0 and compounds.pos().len() <= 128,
    message: "Gallery requires 1..128 compounds",
  )
  for distance in (gutter, row-gap, name-gap) {
    assert(distance >= 0pt, message: "Gallery gaps must be nonnegative")
  }
  let options = settings(
    font,
    atom-size,
    label-size,
    bond-length,
    molecular-style,
    molecular-layout,
  )
  let cards = compounds.pos().map(value => measure-compound(value, options))
  let image-height = cards.map(card => card.image-height).fold(0pt, calc.max)
  let name-height = cards
    .map(card => if card.name == none { 0pt } else { card.name.height })
    .fold(0pt, calc.max)
  grid(
    columns: (auto,)
      * calc.min(
        columns,
        cards.len(),
      ), column-gutter: gutter, row-gutter: row-gap,
    ..cards.map(card => paint-compound(
      card,
      image-height,
      name-height,
      name-gap,
    ))
  )
}
