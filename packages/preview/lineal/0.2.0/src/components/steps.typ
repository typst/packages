#import "../brand.typ": colour

#let step-item(item) = {
  if type(item) != dictionary { return (title: item, description: none) }
  assert("title" in item, message: "each steps dictionary needs a title")
  assert(item.keys().all(key => key in ("title", "description")), message: "steps items accept only title and description")
  (title: item.title, description: item.at("description", default: none))
}

/// A numbered process. Items are content or (title:, description:) dictionaries.
#let steps(
  items,
  direction: "vertical",
  start: 1,
  accent: colour.primary,
  ink: colour.neutral-dark,
  muted: rgb("#626b73"),
  marker-ink: white,
  size: 1em,
  marker-size: 1.65em,
  gap: .85em,
  inset: 0pt,
) = {
  assert(type(items) == array and items.len() > 0, message: "steps needs a non-empty array of items")
  assert(direction in ("vertical", "horizontal"), message: "steps direction must be vertical or horizontal")
  assert(type(start) == int and start >= 1, message: "steps start must be a positive integer")
  let items = items.map(step-item)
  let marker(number) = circle(width: marker-size, height: marker-size, fill: accent,
    align(center + horizon, text(fill: marker-ink, size: .75em, weight: "semibold", str(number))),
  )
  let description(item) = {
    let detail = if item.description == none { () } else { (text(size: .85em, fill: muted, item.description),) }
    stack(dir: ttb, spacing: .3em, text(weight: "semibold", item.title), ..detail)
  }
  block(width: 100%, inset: inset, {
    set text(size: size, fill: ink)
    set par(spacing: .55em, leading: .4em)
    if direction == "horizontal" {
      grid(columns: (1fr,) * items.len(), column-gutter: gap, align: top,
        ..items.enumerate().map(((index, item)) => block(breakable: false, {
          stack(dir: ttb, spacing: .55em, marker(start + index), description(item))
        })),
      )
    } else {
      grid(columns: (auto, 1fr), column-gutter: .6em, row-gutter: gap, align: top,
        ..items.enumerate().map(((index, item)) => (
          marker(start + index),
          pad(top: (marker-size - .65em) / 2, description(item)),
        )).flatten(),
      )
    }
  })
}
