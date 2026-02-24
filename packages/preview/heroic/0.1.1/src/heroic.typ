#import "index.typ": icon-names, icon-sprites


#let icon(name, height: 1em, solid: true, color: none) = {
  if name not in icon-names {
    panic("Icon " + name + " does not exists. See https://heroicons.com/ for valid icon names.")
  }


  let color = if color == none { "currentColor" } else { color.to-hex() }

  let icon-data = if solid {
    icon-sprites.solid + "<use href=\"#" + name + "\" fill=\"" + color + "\" />" + "</svg>"
  } else {
    icon-sprites.outline + "<use href=\"#" + name + "\" stroke=\"" + color + "\" />" + "</svg>"
  }

  image(
    bytes(icon-data),
    alt: name,
    format: "svg",
    fit: "contain",
    height: height,
  )
}

#let hi(name, baseline: 20%, ..icon-args) = context {
  box(
    baseline: baseline,
    icon(name, color: text.fill, ..icon-args),
  )
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
