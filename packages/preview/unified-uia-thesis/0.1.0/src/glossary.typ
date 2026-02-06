#let GLOSSARY = state("glossary", (:))

#let capitalize(text) = upper(text.at(0)) + text.slice(1)

#let render-glossary(glossary-dict, t) = {
  let alphabetical-keys = glossary-dict.keys().sorted(key: item => capitalize(item))
  let alphabetical-terms = (:)
  for key in alphabetical-keys {
    alphabetical-terms.insert(capitalize(key), glossary-dict.at(key))
  }

  [= #t.glossary]
  table(
    columns: (0.6fr, 1fr),
    stroke: none,
    row-gutter: 0.2em,
    table.header[*#t.term*][*#t.definition*],
    table.hline(),
    ..for (term, def) in alphabetical-terms {
      let glossary-label = "glossary-" + lower(term)
      let definition-label = "definition-" + lower(term)
      (
        [#link(label(definition-label))[#strong(term)#label(glossary-label)]],
        [#def],
      )
    },
  )
}

#let define(term, definition) = context {
  let glossary = GLOSSARY.get()
  let term-copy = term // visual copy lolol
  let term = term // own

  if term in glossary {
    term = term + "-duplicate"
  }

  GLOSSARY.update(terms => {
    if term not in terms {
      terms.insert(term, definition)
    }
    terms
  })

  let glossary-label = "glossary-" + lower(term)
  let definition-label = "definition-" + lower(term)
  [#link(label(glossary-label))[#emph(term-copy)]#label(definition-label)]
}
