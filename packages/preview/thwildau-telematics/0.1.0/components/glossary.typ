#import "../utils/translation.typ": translation

#let glossary-state = state("glossary", (:))

#let define-glossary(term, description) = {
  // TODO: duplicates error handling
  let id = str("glossary-" + term)
  // Store full info in state
  glossary-state.update(state => state + (str(id): (term, description)))
  // Create link to later entry
  show link: set text(fill: black)
  link(label(id))[#emph[#term]]
}

#let glossary(term) = {
  let id = str("glossary-" + term)
  show link: set text(fill: black)

  link(label(id))[#emph[#term]]
}

