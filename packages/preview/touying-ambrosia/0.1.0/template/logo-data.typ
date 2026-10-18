#import "@preview/touying-ambrosia:0.1.0": assets
#let _viewports = (
  "delphi-forum-dark.svg": (220.82, 94.12, 1006.36, 897.76),
  "delphi-forum.svg": (220.82, 94.12, 1006.36, 897.76),
  "helios-polytechnic-dark.svg": (217.2, 39.82, 1013.6, 991.88),
  "helios-polytechnic.svg": (217.2, 39.82, 1013.6, 991.88),
  "kyklo-logo-dark.svg": (47.06, 333.04, 1346.64, 401.82),
  "kyklo-logo.svg": (47.06, 333.04, 1346.64, 401.82),
  "kyklo-mark-dark.svg": (103.455, 94.05, 1047.09, 1053.36),
  "kyklo-mark.svg": (103.455, 94.05, 1047.09, 1053.36),
  "nectarion-college-dark.svg": (101.36, 97.74, 1248.9, 883.28),
  "nectarion-college.svg": (101.36, 97.74, 1248.9, 883.28),
  "olympus-institute-dark.svg": (130.32, 68.78, 1183.74, 930.34),
  "olympus-institute.svg": (130.32, 68.78, 1183.74, 930.34),
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
