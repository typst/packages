#let env_colors_list  = ("bootstrap", "bw", "gruvbox_dark", "ayu_light")
#let env_colors       = state("theme", "bootstrap")
#let colors_dict      = (:)

#for colors_name in env_colors_list {
  colors_dict.insert(colors_name, json(colors_name + ".json"))
}

#let valid_colors(colors) = {
  return colors in env_colors_list
}

#let get_ratio(theme_name, env_name, parameter_name) = {
  return float(colors_dict.at(theme_name).at(env_name).at(parameter_name)) * 100%
}

#let get_colors(theme_name, env_name) = {
  return colors_dict.at(theme_name).at(env_name, default: none)
}

#let get_opts_colors(theme_name) = {
  let opts = get_colors(theme_name, "opts")

  let filled_opts = (:)

  if (opts != none) {
    filled_opts.insert("fill",   opts.at("fill",   default: "#ffffff"))
    filled_opts.insert("text1",  opts.at("text1",  default: "#000000"))
    filled_opts.insert("text2",  opts.at("text2",  default: "#ffffff"))
    filled_opts.insert("h1",     opts.at("h1",     default: "#020004"))
    filled_opts.insert("h2",     opts.at("h2",     default: "#16428e"))
    filled_opts.insert("strong", opts.at("strong", default: "#020004"))
  } else {
    filled_opts.insert("fill",   "#ffffff")
    filled_opts.insert("text1",  "#000000")
    filled_opts.insert("text2",  "#ffffff")
    filled_opts.insert("h1",     "#020004")
    filled_opts.insert("h2",     "#16428e")
    filled_opts.insert("strong", "#020004")
  }

  return filled_opts
}
