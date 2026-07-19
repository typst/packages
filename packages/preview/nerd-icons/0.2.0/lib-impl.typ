#let prefixes = (
  "md", "fa", "dev", "cod", "linux", "oct", "weather", "fae", "seti",
  "custom", "ple", "pom", "pl", "iec"
)

#let nerd-font = state("nerd-font", "symbols nerd font mono")

#let change-nerd-font(font) = {
  nerd-font.update(font)
}

#let favorite = state("favorite", "md")

/// Set which icon prefix is your favorite
/// for fallback \
/// Possible values are: md, fa, dev, linux
#let set-favorite-nf-prefix(string) = {
  if prefixes.contains(string) {
    favorite.update(string)
  }
}

#let try-with-prefix-helper(name, icon-map) = {
  let fav = icon-map.at("nf-" + favorite.get() + "-" + name, default : none)
  if fav != none {return fav}

  for prefix in prefixes {
    let res = icon-map.at("nf-" + prefix + "-" + name, default : none)
    if res != none {return res}
  }

  panic("Tried every prefix with " + name + ", but it was not found")
}

#let try-with-prefix(name, icon-map) = {
  context try-with-prefix-helper(name, icon-map)
}

#let nf-icon-raw(name, ..args) = {
  context text(font: nerd-font.get(), name, ..args)
}

#let nf-icon-content(name, icon-map : (:)) = {
    let val = icon-map.at(name, default : none)

    if val == none {
      let val = try-with-prefix(name, icon-map)
      nf-icon-raw(val)
    }
    nf-icon-raw(val)
}

#let nf-icon(name, icon-map : (:), ..args) = {
  nf-icon-raw(nf-icon-content(name, icon-map : icon-map), ..args)
}

#let try-with-prefix-string(name, icon-map) = {
  for prefix in prefixes {
    let res = icon-map.at("nf-" + prefix + "-" + name, default : none)
    if res != none {return res}
  }

  panic("Tried every prefix with " + name + ", but it was not found")
}

#let nf-icon-string(name, icon-map : (:)) = {
    let val = icon-map.at(name, default : none)

    if val == none {
      let val = try-with-prefix-string(name, icon-map)
      val
    }
    val
}
