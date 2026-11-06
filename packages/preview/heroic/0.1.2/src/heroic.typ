#import "index.typ": icon-names, index-outline, index-solid


#let icon(name, height: 1em, solid: true, color: auto) = {
  let color = if color in (none, auto) { "currentColor" } else { color.to-hex() }

  let icon-data = if solid {
    assert(
      name in index-solid,
      message: "Solid icon " + name + " does not exists. See https://heroicons.com/ for valid icon names.",
    )
    index-solid.at(
      name,
    )
  } else {
    assert(
      name in index-outline,
      message: "Outline icon " + name + " does not exists. See https://heroicons.com/ for valid icon names.",
    )
    index-outline.at(name)
  }

  icon-data = (
    "<?xml version=\"1.0\" encoding=\"utf-8\"?><svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" "
      + if solid {
        "stroke=\"none\" fill=\""
      } else { "fill=\"none\" stroke=\"" }
      + color
      + "\" xmlns=\"http://www.w3.org/2000/svg\">"
      + icon-data
      + "</svg>"
  )

  image(
    bytes(icon-data),
    alt: name,
    format: "svg",
    fit: "contain",
    height: height,
  )
}

#let hi(name, baseline: 20%, ..icon-args) = {
  if "color" in icon-args.named() {
    box(baseline: baseline, icon(name, ..icon-args))
  } else {
    context box(baseline: baseline, icon(name, color: text.fill, ..icon-args))
  }
}


#let list-icons(sort: k => k, columns: 1, ..grid-args) = grid(
  columns: 4 * columns,
  align: (right + horizon, center + horizon, center + horizon, left + horizon),
  inset: .5em,
  stroke: (y: .75pt),
  ..grid-args,
  ..for (i, name) in icon-names.sorted(key: sort).enumerate() {
    (
      grid.cell(stroke: if columns > 1 and calc.rem(i, columns) > 0 { (left: .75pt) } + (y: .75pt))[#{ i + 1 }.],
      icon(name, height: 10pt),
      icon(name, height: 10pt, solid: false),
      raw(block: false, name),
    )
  }
)
