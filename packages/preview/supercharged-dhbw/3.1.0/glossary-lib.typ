#import "locale.typ": GLOSSARY

#let prefix = "glossary-state-"
#let glossary-state = state("glossary", none)

#let init-glossary(glossary) = {
  glossary-state.update(glossary)
}

// Check if an acronym exists
#let is-valid(element) = {
  glossary-state.display(glossary => {
    if element not in glossary {
      panic(element + " is not a key in the glossary dictionary.")
      return false
    }
  })
  return true
}

// Display acronym as clickable link
#let display-link(element, text) = {
  if is-valid(element) {
    link(label("glossary-" + element), text)
  }
}

// Display acronym
#let display(element, text, link: true) = {
  if link {
    display-link(element, text)
  } else {
    text
  }
}

// Display acronym. Expands it if used for the first time
#let gls(element, link: true) = {
  display(element, element, link: link)
}

// Print an index of all the acronyms and their definitions.
#let print-glossary(language, glossary-spacing) = {
  heading(level: 1, outlined: false, numbering: none)[#GLOSSARY.at(language)]

  glossary-state.display(glossary => {
    let glossary-keys = glossary.keys()

    let max-width = 0pt
    for key in glossary-keys {
      let result = measure(key).width

      if (result > max-width) {
        max-width = result
      }
    }

    let glossary-list = glossary-keys.sorted()

    for element in glossary-list {
      grid(
        columns: (max-width + 1em, auto),
        gutter: glossary-spacing,
        [*#element#label("glossary-" + element)*], [#glossary.at(element)],
      )
    }
  })
}