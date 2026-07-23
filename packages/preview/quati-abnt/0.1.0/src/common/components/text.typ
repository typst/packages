// # Text. Texto.

#let capitalize_first_letter = text => {
  if text == none {
    none
  }
  upper(text.at(0)) + text.slice(1)
}
