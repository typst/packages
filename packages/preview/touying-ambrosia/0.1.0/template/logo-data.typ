#import "@preview/touying-ambrosia:0.1.0": assets
#let _viewports = (
  "touying-ambrosia-dark.svg": (150.48, 213.18, 959.31, 858.99),
  "touying-ambrosia.svg": (150.48, 213.18, 959.31, 858.99),
)
#let display-data(name, dark: false) = {
  let file = name + if dark { "-dark.svg" } else { ".svg" }
  let data = str(assets.read-asset(assets.asset-paths.showcase.at(name).at(if dark { "dark" } else { "light" })))
  let (x, y, w, h) = _viewports.at(file)
  let viewport = (x, y, w, h).map(str).join(" ")
  data.replace(regex("viewBox=\"[^\"]*\""), "viewBox=\"" + viewport + "\"")
    .replace(regex("(<svg[^>]*?)\\bwidth=\"[^\"]*\""), match => match.captures.first() + "width=\"" + str(w) + "\"")
    .replace(regex("(<svg[^>]*?)\\bheight=\"[^\"]*\""), match => match.captures.first() + "height=\"" + str(h) + "\"")
}
