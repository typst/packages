#let units-state = state("units", (:))

#let define-unit(symbol, unit, name, description) = {
  // TODO: duplicates error handling
  let id = str("unit-" + symbol)
  // Store full info in state
  units-state.update(state => state + (str(id): (symbol, unit, name, description)))
  // Create link to later entry
  show link: set text(fill: black)
  link(label(id))[#emph[#symbol]]
}

#let unit(symbol) = {
  // TODO: make this work with either symbol or name. Error handling
  let id = str("unit-" + symbol)
  show link: set text(fill: black)

  link(label(id))[#emph[#symbol]]
}
