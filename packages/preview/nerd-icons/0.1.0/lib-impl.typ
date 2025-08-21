#let nerd-font = state("nerd-font", "symbols nerd font mono")

#let change-nerd-font(font) = {
  nerd-font.update(font)
}

#let nf-icon-raw(name, ..args) = {
  return context text(font: nerd-font.get(), name, ..args)
}

#let nf-icon(name, icon-map : (:), ..args) = {
  return nf-icon-raw(icon-map.at(name), ..args)
}
