#import "index.typ": icon-names

#let _asset_path = "./heroicons"


#let icon(name, height: 1em, solid: true, color: auto) = {
  if name not in icon-names {
    panic("Icon " + name + " does not exists. See https://heroicons.com/ for valid icon names.")
  }

  let icon-path = _asset_path + "/" + if solid { "solid" } else { "outline" } + "/" + name + ".svg"
  let icon-data = read(icon-path)
  if color != auto {
    icon-data = icon-data.replace("currentColor", color.to-hex())
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


#let list-icons() = grid(
  columns: 3,
  align: (right + horizon, center + horizon, left + horizon),
  inset: .5em,
  stroke: (y: .75pt),
  ..for (i, name) in icon-names.enumerate() {
    (
      [#{ i + 1 }.],
      icon(name, height: 10pt),
      raw(block: false, name),
    )
  }
)
