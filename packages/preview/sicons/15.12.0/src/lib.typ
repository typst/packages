#let wasm-path = "/sicons.wasm"

#let p = plugin(wasm-path)

#let sIcon = (slug: "typst", size: 1em, iconColor: "default") => {
  image(p.simple_icons_slug_colored(bytes(slug), bytes(iconColor)), width: size)
}

#let sTitle = (slug: "typst", size: 1em, textColor: "#000000") => text(
  str(p.simple_icons_title(bytes(slug))),
  size: size,
  fill: rgb(textColor),
)

#let sIconLabel = (slug: "typst", size: 1em, iconColor: "default", textColor: "#000000") => {
  let resolvedTextColor = if textColor == "default" {
    rgb(str(p.simple_icons_color(bytes(slug))))
  } else {
    rgb(textColor)
  }

  grid(
    columns: (auto, auto),
    align: center + horizon,
    gutter: size / 3,
    sIcon(slug: slug, size: size, iconColor: iconColor), sTitle(slug: slug, size: size, textColor: resolvedTextColor),
  )
}

#let sIconRaw = (slug: "typst") => raw(str(p.simple_icons_slug(bytes(slug))), lang: "xml")
