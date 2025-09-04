#let wasm-path = "/sicons.wasm"

#let p = plugin(wasm-path)

#let sicon = (slug: "typst", size: 1em, icon-color: "default") => {
  image(p.simple_icons_slug_colored(bytes(slug), bytes(icon-color)), width: size)
}

#let stitle = (slug: "typst", size: 1em, text-color: "#000000") => text(
  str(p.simple_icons_title(bytes(slug))),
  size: size,
  fill: rgb(text-color),
)

#let sicon-label = (slug: "typst", size: 1em, icon-color: "default", text-color: "#000000") => {
  let resolvedTextColor = if text-color == "default" {
    rgb(str(p.simple_icons_color(bytes(slug))))
  } else {
    rgb(text-color)
  }

  grid(
    columns: (auto, auto),
    align: center + horizon,
    gutter: size / 3,
    sicon(slug: slug, size: size, icon-color: icon-color), stitle(slug: slug, size: size, text-color: resolvedTextColor),
  )
}

#let sicon-raw = (slug: "typst") => raw(str(p.simple_icons_slug(bytes(slug))), lang: "xml")
