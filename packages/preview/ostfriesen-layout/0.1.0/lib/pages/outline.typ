#import "../translations.typ": translations

#let create_outline(title: "Table of Contents", lang: "en", frontmatter_style: "i") = {
  // Localization
  let t = translations.at(if lang in translations.keys() { lang } else { "en" })

  // Add the heading for the TOC
  heading(title, numbering: none, outlined: false)

  // Custom rendering for all outline entries
  show outline.entry: it => {
    // For level 1, don't use dots (fill: none)
    // For other levels, use dots (default fill behavior)
    if it.level == 1 {
      set text(weight: "bold")
      box(it.body(), width: auto)
      h(1fr)
      if it.element.location().page-numbering() == "i" {
        [*#numbering("i", counter(page).at(it.element.location()).first())*]
      } else {
        [*#counter(page).at(it.element.location()).first()*]
      }
      v(1.25mm)
    } else {
      // Use default outline entry with dots
      it
    }
  }

  // Generate the outline with dots for all entries except level 1
  outline(
    depth: 3,
    indent: auto,
    title: none
  )
}

