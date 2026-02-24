#let env-colors-list  = ("bootstrap", "bw", "gruvbox-dark", "ayu-light")
#let env-colors       = state("theme", "bootstrap")
#let colors-dict      = (:)

#for colors-name in env-colors-list {
  colors-dict.insert(colors-name, json(colors-name + ".json"))
}

#let valid-colors(colors) = {
  return colors in env-colors-list
}

#let get-ratio(theme-name, env-name, parameter-name) = {
  return float(colors-dict.at(theme-name).at(env-name).at(parameter-name)) * 100%
}

#let get-colors(theme-name, env-name) = {
  return colors-dict.at(theme-name).at(env-name, default: none)
}

#let get-opts-colors(theme-name) = {
  let opts = get-colors(theme-name, "opts")

  let filled-opts = (:)

  if (opts != none) {
    filled-opts.insert("fill",   opts.at("fill",   default: "#ffffff"))
    filled-opts.insert("text1",  opts.at("text1",  default: "#000000"))
    filled-opts.insert("text2",  opts.at("text2",  default: "#ffffff"))
    filled-opts.insert("h1",     opts.at("h1",     default: "#020004"))
    filled-opts.insert("h2",     opts.at("h2",     default: "#16428e"))
    filled-opts.insert("strong", opts.at("strong", default: "#020004"))
  } else {
    filled-opts.insert("fill",   "#ffffff")
    filled-opts.insert("text1",  "#000000")
    filled-opts.insert("text2",  "#ffffff")
    filled-opts.insert("h1",     "#020004")
    filled-opts.insert("h2",     "#16428e")
    filled-opts.insert("strong", "#020004")
  }

  return filled-opts
}
